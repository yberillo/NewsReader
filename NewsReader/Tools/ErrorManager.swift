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
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate,
            let rootViewController = appDelegate.window?.rootViewController else {
            return
        }
        let alertViewController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertViewController.addAction(okAction)
        
        rootViewController.present(alertViewController, animated: true)
    }
}
