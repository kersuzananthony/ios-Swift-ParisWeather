//
//  AppDelegate.swift
//  ParisWeather
//
//  Created by Kersuzan on 17/11/2016.
//  Copyright © 2016 com.kersuzan. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var applicationManager = ApplicationManager.getInstance

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        launchApplication()
        
        return true
    }

    // MARK: - AppDelegate custom methods
    func launchApplication() {
        self.applicationManager.coreDataManager = CoreDataManager(modelName: "ParisWeather", closure: {
            [unowned self] in
            self.setApplicationManagerInViews(completion: { (viewController) in
                self.window?.rootViewController = viewController
            })
        })
    }
    
    fileprivate func setApplicationManagerInViews(completion: @escaping (_ rootViewController: UIViewController) -> ()) {
        guard let _ = applicationManager.coreDataManager else {
            fatalError("No Core Data Stack initialized, cannot continue")
        }
        
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        
        guard let navigationViewController = mainStoryboard.instantiateViewController(withIdentifier: "MainNavigationController") as? UINavigationController, let mainViewController = navigationViewController.viewControllers.first as? MainViewController  else {
            fatalError("Cannot access initial view controller")
        }
        
        mainViewController.applicationManager = applicationManager
        
        // Return the navigationViewController to the closure
        completion(navigationViewController)
    }
}

