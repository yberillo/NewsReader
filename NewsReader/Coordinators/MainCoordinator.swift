//
//  MainCoordinator.swift
//  NewsReader
//
//  Created by Yury Beryla on 12/9/19.
//  Copyright © 2019 Yury Beryla. All rights reserved.
//

import Foundation
import UIKit

final class MainCoordinator: NSObject, ChannelsViewControllerDelegate, LoginViewControllerDelegate {
    
    // MARK: - Internal Properties
    
    let rootViewController: UIViewController
    
    // MARK: - Private Properties
    
    var currentViewController: UIViewController? {
        
        didSet {
            
            if oldValue is UINavigationController {
                let childViewController = oldValue?.children.first
                childViewController?.view.removeFromSuperview()
                childViewController?.removeFromParent()
            }
            else {
                oldValue?.view.removeFromSuperview()
                oldValue?.removeFromParent()
            }
            
            if let currentViewController = self.currentViewController {
                self.rootViewController.view.addSubview(currentViewController.view)
                self.rootViewController.addChild(currentViewController)
                currentViewController.didMove(toParent: rootViewController)
            }
        }
    }
    
    var navigationController: UINavigationController?
    
    let usersDataController: UsersDataController
    
    let viewControllerManager: ViewControllerManager
    
    // MARK: - Lifecycle
    
    override init() {
        self.rootViewController = UIViewController()
        self.usersDataController = UsersDataController()
        self.viewControllerManager = ViewControllerManager()
        
        super.init()
        
        self.reloadCurrentViewController()
    }
        
    // MARK: - Private API
    
    private func reloadCurrentViewController() {
        usersDataController.restoreUser()
        if usersDataController.currentUser != nil {
            guard let channelsViewController = viewControllerManager.makeViewController(.channels, data: [ViewControllerManager.DataKey.usersDataController: usersDataController]) as? ChannelsViewController else {
                return
            }
            let channelsNavigationController = UINavigationController(rootViewController: channelsViewController)
            channelsViewController.delegate = self
            currentViewController = channelsNavigationController
            navigationController = channelsViewController.navigationController
        }
        else {
            guard let loginViewController = viewControllerManager.makeViewController(.login, data: [ViewControllerManager.DataKey.usersDataController: usersDataController]) as? LoginViewController else {
                return
            }
            loginViewController.delegate = self
            currentViewController = loginViewController
        }
    }
    
    // MARK: - Internal API
    
    func presentAlertController(alertController: UIAlertController, from viewController: UIViewController) {
        viewController.present(alertController, animated: true)
    }
    
    func pushViewController(_ viewController: MainCoordinator.ViewController, data: [ViewControllerManager.DataKey : Any]? = nil) {
        guard let viewController = viewControllerManager.makeViewController(viewController, data: data) else {
            return
        }
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    // MARK: - LoginViewControllerDelegate
    
    func signIn() {
        reloadCurrentViewController()
    }
    
    // MARK: - ChannelsViewControllerDelegate
    
    func signOut() {
        reloadCurrentViewController()
    }
}

extension MainCoordinator {
    
    enum ViewController {
        
        case article

        case articles
        
        case articleWeb

        case channels
        
        case login
    }
}
