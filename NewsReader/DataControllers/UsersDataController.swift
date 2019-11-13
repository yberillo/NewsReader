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
    
    // MARK: - Predicates
    
    private let isSignedInPredicateString = "isSignedIn"
    
    private let namePredicateString = "name"
    
    private let passwordPredicateString = "password"

    private let usernamePredicateString = "username"
    
    
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
        let usernamePredicate = NSPredicate(format: "\(usernamePredicateString) = %@", username)
        predicates.append(usernamePredicate)
        
        let passwordPredicate = NSPredicate(format: "\(passwordPredicateString) = %@", password)
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
        
        userFetchRequest.predicate = NSPredicate(format: "\(isSignedInPredicateString) = %@", "1")
                    
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
        
        userFetchRequest.predicate = NSPredicate(format: "\(isSignedInPredicateString) = %@", "1")
                    
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
        user.setValue("user", forKey: usernamePredicateString)
        user.setValue("Ivan Ivanov", forKey: namePredicateString)
        user.setValue("password", forKey: passwordPredicateString)

        do {
            
            try context.save()
        }
        catch let error as NSError {
            
            print(error)
        }
    }
}
