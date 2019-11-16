//
//  UsersDataController.swift
//  NewsReader
//
//  Created by Yury Beryla on 11/12/19.
//  Copyright © 2019 Yury Beryla. All rights reserved.
//

import CryptoKit
import CoreData
import Foundation
import UIKit

final class UsersDataController {
    
    // MARK: - Private Properties
    
    private var context: NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        return appDelegate.persistentContainer.viewContext
    }
        
    private let entityName = "User"
        
    // MARK: Internal Properties
    
    private(set)var currentUser: User?
    
    // MARK: - Internal API
    
    func authenticateUser(with username: String, password: String) -> User? {
        let userFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: self.entityName)
        var predicates: [NSPredicate] = []
        let usernamePredicate = NSPredicate(format: "\(UsersDataController.Keys.username) = %@", username)
        predicates.append(usernamePredicate)
        
        let passwordHash = self.getHashFrom(string: password)
        let passwordPredicate = NSPredicate(format: "\(UsersDataController.Keys.password) = %@", passwordHash)
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
            ErrorManager.handle(error: error)
            return nil
        }
    }
    
    func registerUser(with username: String, password: String) -> Bool {
        let userFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: self.entityName)
        let predicate = NSPredicate(format: "\(UsersDataController.Keys.username) = %@", username)
        
        userFetchRequest.predicate = predicate
                    
        do {
            let userResult = try self.context.fetch(userFetchRequest)
            
            if userResult.isEmpty {
                let user = User(context: context)
                user.setValue(username, forKey: UsersDataController.Keys.username)
                user.setValue("Ivan Ivanov", forKey: UsersDataController.Keys.name)
                
                let passwordHash = getHashFrom(string: password)
                user.setValue(passwordHash, forKey: UsersDataController.Keys.password)

                do {
                    try context.save()
                }
                catch let error as NSError {
                    ErrorManager.handle(error: error)
                    return false
                }
                return true
            }
            else {
                return false
            }
        }
        catch let error as NSError {
            ErrorManager.handle(error: error)
            return false
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
            ErrorManager.handle(error: error)
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
            self.currentUser = nil
            
            try context.save()
        }
        catch let error as NSError {
            ErrorManager.handle(error: error)
        }
    }
    
    // MARK: - Private API
    
    private func getHashFrom(string: String) -> String {
        let stringData = Data(string.utf8)
        let hashData = SHA256.hash(data: stringData)

        return hashData.compactMap { String(format: "%02x", $0) }.joined()
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
