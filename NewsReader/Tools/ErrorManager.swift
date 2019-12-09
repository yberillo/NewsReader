//
//  ErrorManager.swift
//  NewsReader
//
//  Created by Yury Beryla on 11/16/19.
//  Copyright © 2019 Yury Beryla. All rights reserved.
//

import UIKit

final class ErrorManager {
    
    // MARK: - Internal Static API
    
    static func handle(error: Error) {
        let alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(okAction)
        
        AppDelegate.mainCoordinator.presentAlertController(alertController: alertController, from: AppDelegate.mainCoordinator.rootViewController)
    }
}
