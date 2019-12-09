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
    
    // MARK: - Lifecycle
    
    override init() {
        self.rootViewController = UIViewController()
        self.usersDataController = UsersDataController()
        
        super.init()
        
        self.reloadCurrentViewController()
    }
        
    // MARK: - Private API
    
    private func reloadCurrentViewController() {
        usersDataController.restoreUser()
        if usersDataController.currentUser != nil {
            let channelsNavigationController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "ChannelsNavigationController") as? UINavigationController
            let channelsViewController = channelsNavigationController?.viewControllers.first as? ChannelsViewController
            let channelsDataController = ChannelsDataController()
            let channelsViewModel = ChannelsViewModel(channelsDataController: channelsDataController, usersDataController: usersDataController)
            channelsViewController?.viewModel = channelsViewModel
            channelsViewController?.delegate = self
            currentViewController = channelsNavigationController
            navigationController = channelsViewController?.navigationController
        }
        else {
            let loginViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "LoginViewController") as? LoginViewController
            let loginViewModel = LoginViewModel(usersDataController: usersDataController)
            loginViewController?.viewModel = loginViewModel
            loginViewController?.delegate = self
            currentViewController = loginViewController
        }
    }
    
    // MARK: - Internal API
    
    func presentAlertController(alertController: UIAlertController, from viewController: UIViewController) {
        viewController.present(alertController, animated: true)
    }
    
    func pushArticlesViewController(selectedChannels: [Channel], channelsDataController: ChannelsDataController) {
        guard let articlesViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "ArticlesViewController") as? ArticlesViewController else {
            return
        }
        let articlesDataController = ArticlesDataController(selectedChannels: selectedChannels)
        let articlesViewModel = ArticlesViewModel(articlesDataController: articlesDataController)
        articlesDataController.articlesFetchedResultsController.delegate = articlesViewController
        articlesViewController.viewModel = articlesViewModel
        
        navigationController?.pushViewController(articlesViewController, animated: true)
    }
    
    func pushArticleViewController(article: Article?) {
        guard let articleViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "ArticleViewController") as? ArticleViewController,
            let article = article else {
            return
        }
        articleViewController.viewModel = ArticleViewModel(article: article)
        
        navigationController?.pushViewController(articleViewController, animated: true)
    }
    
    func pushArticleWebViewController(articleUrl: URL) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        guard let articleWebViewController = storyboard.instantiateViewController(identifier: "ArticleWebViewController") as? ArticleWebViewController else {
            return
        }
        let articleWebViewModel = ArticleWebViewModel(articleUrl: articleUrl)
        articleWebViewController.viewModel = articleWebViewModel
        
        self.navigationController?.pushViewController(articleWebViewController, animated: true)
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
