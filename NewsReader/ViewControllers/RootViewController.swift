//
//  RootViewController.swift
//  NewsReader
//
//  Created by Yury Beryla on 11/13/19.
//  Copyright © 2019 Yury Beryla. All rights reserved.
//

import UIKit

final class RootViewController: UIViewController, LoginViewControllerDelegate, ChannelsViewControllerDelegate {
    
    // MARK: - Private Properties
    
    private let usersDataController: UsersDataController
    
    // MARK: - Internal Properties
    
    var currentViewController: UIViewController? {
        
        didSet {
            
            oldValue?.view.removeFromSuperview()
            oldValue?.removeFromParent()
            
            if let currentViewController = self.currentViewController {
                
                self.view.addSubview(currentViewController.view)
                self.addChild(currentViewController)
                currentViewController.didMove(toParent: self)
            }
        }
    }
    
    // MARK: - Lifecycle
    
    init() {
        usersDataController = UsersDataController()
        super.init(nibName: nil, bundle: nil)
        
        reloadCurrentViewController()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    // MARK: - Private API
    
    private func reloadCurrentViewController() {
        if let _ = usersDataController.restoreUser() {
            let channelsNavigationController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "ChannelsNavigationController") as? UINavigationController
            let channelsViewController = channelsNavigationController?.viewControllers.first as? ChannelsViewController
            channelsViewController?.usersDataController = usersDataController
            channelsViewController?.delegate = self
            currentViewController = channelsNavigationController
            
        }
        else {
            let loginViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "LoginViewController") as? LoginViewController
            loginViewController?.delegate = self
            loginViewController?.usersDataController = usersDataController
            currentViewController = loginViewController
            
        }
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
