//
//  AppDelegate.swift
//  NewsReader
//
//  Created by Yury Beryla on 11/12/19.
//  Copyright © 2019 Yury Beryla. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    static let mainCoordinator: MainCoordinator = {
        return MainCoordinator()
    }()
    
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        
        window?.rootViewController = AppDelegate.mainCoordinator.rootViewController
        window?.makeKeyAndVisible()
        
        return true
    }
}
