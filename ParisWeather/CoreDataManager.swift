//
//  CoreDataManager.swift
//  ParisWeather
//
//  Created by Kersuzan on 17/11/2016.
//  Copyright © 2016 com.kersuzan. All rights reserved.
//

import Foundation
import CoreData

// For reporting errors
public let MyManagedObjectContextSaveDidFailNotification = "MyManagedObjectContextSaveDidFailNotification"

public func fatalCoreDataError(_ error: Error) {
    print("*** Fatal error \(error)")
    NotificationCenter.default.post(name: Notification.Name(rawValue: MyManagedObjectContextSaveDidFailNotification), object: nil)
}

public extension Notification.Name {
    public static let mainThreadManagedObjectContextDidUpdate = Notification.Name("mainThreadManagedObjectContextDidUpdate")
}

class CoreDataManager: NSObject {
    
    fileprivate let modelName: String
    public var mainThreadManagedObjectContext: NSManagedObjectContext
    fileprivate let coordinator: NSPersistentStoreCoordinator
    
    public init(modelName: String, closure: @escaping () -> ()) {
        self.modelName = modelName
        
        guard let modelURL = Bundle.main.url(forResource: modelName, withExtension: "momd"),
            let managedObjectModel = NSManagedObjectModel(contentsOf: modelURL)
            else {
                fatalError("CoreDataManager - COULD NOT INIT MANAGED OBJECT MODEL")
        }
        
        self.coordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        self.mainThreadManagedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        
        self.mainThreadManagedObjectContext.persistentStoreCoordinator = self.coordinator
        
        super.init()
        
        DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async {
            [unowned self] in
            
            let options: [String: Any] = [
                NSMigratePersistentStoresAutomaticallyOption: true,
                NSInferMappingModelAutomaticallyOption: true,
                NSSQLitePragmasOption: ["journal_mode": "DELETE"]
            ]
            
            let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            let storeURL = directory.first?.appendingPathComponent("\(self.modelName).sqlite")
            
            do {
                try self.coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: options)
                
                DispatchQueue.main.async(execute: {
                    closure()
                })
            } catch let error as NSError {
                fatalCoreDataError(error)
            }
            
        }
    }
    
    public func save() {
        if self.mainThreadManagedObjectContext.hasChanges {
            self.mainThreadManagedObjectContext.performAndWait({
                [unowned self] in
                do {
                    try self.mainThreadManagedObjectContext.save()
                } catch let error as NSError {
                    fatalCoreDataError(error)
                }
            })
        }
    }
}
