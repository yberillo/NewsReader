//
//  UsersDataController.swift
//  NewsReader
//
//  Created by Yury Beryla on 11/12/19.
//  Copyright © 2019 Yury Beryla. All rights reserved.
//

import CoreData
import Foundation
import UIKit

final class UsersDataController {
    
    // MARK: - Private Properties
    
    private var context: NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        return appDelegate.persistentContainer.viewContext
    }
    
    private let userObjectIDKey = "userObjectID"
    
    private let entityName = "User"
    
    // MARK: Internal Properties
    
    private(set)var currentUser: User?
    
    // MARK: - Lifecycle
    
    init() {
        
//        loadUsers()
    }
    
    // MARK: - Internal API
    
    func authenticateUser(with username: String, password: String) -> User? {
        let userFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: self.entityName)
        var predicates: [NSPredicate] = []
        let usernamePredicate = NSPredicate(format: "\(UsersDataController.Keys.username) = %@", username)
        predicates.append(usernamePredicate)
        
        let passwordPredicate = NSPredicate(format: "\(UsersDataController.Keys.password) = %@", password)
        predicates.append(passwordPredicate)
        
        userFetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
                    
        do {
            
            let userResult = try self.context.fetch(userFetchRequest)
            
            if userResult.isEmpty {
                return nil
            }
            else {
                currentUser = userResult.first as? User
                currentUser?.isSignedIn = true
                try context.save()
                return currentUser
            }
        }
        catch let error as NSError {
            
            print(error)
            return nil
        }
    }
    
    func restoreUser() -> User? {
        
        let userFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: self.entityName)
        
        userFetchRequest.predicate = NSPredicate(format: "\(UsersDataController.Keys.isSignedIn) = %@", "1")
                    
        do {
            
            let userResult = try self.context.fetch(userFetchRequest)
            
            if userResult.isEmpty {
                return nil
            }
            else {
                currentUser = userResult.first as? User
                return currentUser
            }
        }
        catch let error as NSError {
            
            print(error)
            return nil
        }
    }
    
    func signOut() {
        
        let userFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: self.entityName)
        
        userFetchRequest.predicate = NSPredicate(format: "\(UsersDataController.Keys.isSignedIn) = %@", "1")
                    
        do {
            
            let userResult = try self.context.fetch(userFetchRequest)
            let currentUser = userResult.first as? User
            currentUser?.isSignedIn = false
            
            try context.save()
        }
        catch let error as NSError {
            
            print(error)
        }
    }
    
    // MARK: - Private API
    
    private func loadUsers() {
        guard let userEntity = NSEntityDescription.entity(forEntityName: entityName, in: context) else {
            
            return
        }
        
        let user = NSManagedObject(entity: userEntity, insertInto: context)
        user.setValue("user", forKey: UsersDataController.Keys.username)
        user.setValue("Ivan Ivanov", forKey: UsersDataController.Keys.name)
        user.setValue("password", forKey: UsersDataController.Keys.password)

        do {
            
            try context.save()
        }
        catch let error as NSError {
            
            print(error)
        }
    }
}

fileprivate extension UsersDataController {
        
    struct Keys {
        
        static var isSignedIn: String {
            return "isSignedIn"
        }
        
        static var name: String {
            return "name"
        }
        
        static var password: String {
            return "password"
        }

        static var username: String {
            return "username"
        }
    }
}
