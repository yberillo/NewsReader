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
    
    private let entityName = "User"
    
    // MARK: - Internal API
    
    func authenticateUser(with username: String, password: String) -> User? {
        let userFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: self.entityName)
        var predicates: [NSPredicate] = []
        let usernamePredicate = NSPredicate(format: "username = %@", username)
        predicates.append(usernamePredicate)
        
        let passwordPredicate = NSPredicate(format: "password = %@", password)
        predicates.append(passwordPredicate)
        
        userFetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
                    
        do {
            
            let userResult = try self.context.fetch(userFetchRequest)
            
            if userResult.isEmpty {
                return nil
            }
            else {
                return userResult.first as? User
            }
        }
        catch let error as NSError {
            
            print(error)
            return nil
        }
    }
    
    func loadUsers() {
        guard let userEntity = NSEntityDescription.entity(forEntityName: entityName, in: context) else {
            
            return
        }
        
        let user = NSManagedObject(entity: userEntity, insertInto: context)
        user.setValue("user", forKey: "username")
        user.setValue("Ivan Ivanov", forKey: "name")
        user.setValue("password", forKey: "password")

        do {
            
            try context.save()
        }
        catch let error as NSError {
            
            print(error)
        }
    }
}
