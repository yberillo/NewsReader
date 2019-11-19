//
//  CoreDataManager.swift
//  NewsReader
//
//  Created by Yury Beryla on 11/19/19.
//  Copyright © 2019 Yury Beryla. All rights reserved.
//

import CoreData

final class CoreDataManager {
    
    // MARK: - Internal Properties
    
    static var shared = CoreDataManager()
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "NewsReader")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Lifecycle
    
    private init() {}
    
    // MARK: - Internal API

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
