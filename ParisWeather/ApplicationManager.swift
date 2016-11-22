//
//  ApplicationManager.swift
//  ParisWeather
//
//  Created by Kersuzan on 17/11/2016.
//  Copyright © 2016 com.kersuzan. All rights reserved.
//

import Foundation
import ReachabilitySwift

enum NetworkConnectionType: Int {
    case wifi
    case wwan
    case noConnection
}

protocol ApplicationManagerDelegate: class {
    func applicationManager(manager: ApplicationManager, didReceiveNetworkReachabilityUpdate reachability: Reachability)
}

class ApplicationManager {
    
    // Singleton for application manager
    static let getInstance: ApplicationManager = ApplicationManager()
    
    // MARK: - ApplicationManager variables
    weak var delegate: ApplicationManagerDelegate?
    var coreDataManager: CoreDataManager?
    fileprivate var _apiClient: APIClient
    fileprivate var reachability: Reachability?
    fileprivate var _useClosures: Bool = false
    fileprivate var _networkIsReachable: Bool = false
    fileprivate var _reachabiltyNetworkType : NetworkConnectionType?
    
    // MARK: Getters
    var apiClient: APIClient {
        get { return self._apiClient }
    }
    
    public var networkIsReachable: Bool {
        get { return self._networkIsReachable }
    }
    
    var reachabilityNetworkType: NetworkConnectionType? {
        get { return self._reachabiltyNetworkType }
    }
    
    // MARK: - Deinitialization
    deinit {
        self.reachability?.stopNotifier()
        if (!self._useClosures) {
            NotificationCenter.default.removeObserver(self, name: ReachabilityChangedNotification, object: self.reachability)
        }
    }
    
    // MARK: - Initialization
    init() {
        self._apiClient = APIClient()
        self.initReachabilityMonitor()
    }
    
    // Network Reachability Methods
    private func initReachabilityMonitor() {
        print("ApplicationManager.initReachabilityMonitor()")
        
        self.reachability = Reachability()
        if self._useClosures {
            self.reachability?.whenReachable = {
                reachability in
                self.notifyReachability(reachability: reachability)
            }
            
            self.reachability?.whenUnreachable = {
                reachability in
                self.notifyReachability(reachability: reachability)
            }
        }
        
        do {
            try self.reachability?.startNotifier()
        } catch {
            print("ApplicationManager.initReachabilityMonitor() - Cannot start notifier")
            return
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged), name: ReachabilityChangedNotification, object: self.reachability)
    }
    
    private func notifyReachability(reachability: Reachability) {
        self.reachability = reachability
        if reachability.isReachable {
            self._networkIsReachable = true
            
            // Determine the Type of network
            if reachability.isReachableViaWiFi {
                self._reachabiltyNetworkType = NetworkConnectionType.wifi
            } else {
                self._reachabiltyNetworkType = NetworkConnectionType.wwan
            }
        } else {
            self._networkIsReachable = false
            self._reachabiltyNetworkType = NetworkConnectionType.noConnection
        }
    }
    
    @objc func reachabilityChanged(notification: Notification) {
        if let reachability = notification.object as? Reachability {
            DispatchQueue.main.async {
                self.notifyReachability(reachability: reachability)
            }
            
            // Informs the delegate that the network status changed
            self.delegate?.applicationManager(manager: self, didReceiveNetworkReachabilityUpdate: reachability)
        }
    }
}
