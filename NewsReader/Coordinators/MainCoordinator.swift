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
            
            let channelsDataController = ChannelsDataController()
            let channelsViewModel = ChannelsViewModel(channelsDataController: channelsDataController, usersDataController: usersDataController)
            let channelsViewController = ChannelsViewController(nibName: nibNameForViewController(.channels), viewModel: channelsViewModel)
            let channelsNavigationController = UINavigationController(rootViewController: channelsViewController)

            channelsViewController.viewModel = channelsViewModel
            channelsViewController.delegate = self
            currentViewController = channelsNavigationController
            navigationController = channelsViewController.navigationController
        }
        else {
            let loginViewModel = LoginViewModel(usersDataController: usersDataController)
            let loginViewController = LoginViewController(nibName: nibNameForViewController(.login), viewModel: loginViewModel)
            loginViewController.delegate = self
            currentViewController = loginViewController
        }
    }
    
    // MARK: - Internal API
    
    func presentAlertController(alertController: UIAlertController, from viewController: UIViewController) {
        viewController.present(alertController, animated: true)
    }
    
    func pushArticlesViewController(selectedChannels: [Channel], channelsDataController: ChannelsDataController) {
        let articlesDataController = ArticlesDataController(selectedChannels: selectedChannels)
        let articlesViewModel = ArticlesViewModel(articlesDataController: articlesDataController)
        let articlesViewController = ArticlesViewController(nibName: nibNameForViewController(.articles), viewModel: articlesViewModel)
        articlesDataController.articlesFetchedResultsController.delegate = articlesViewController
        
        navigationController?.pushViewController(articlesViewController, animated: true)
    }
    
    func pushArticleViewController(article: Article?) {
        guard let article = article else {
            return
        }
        let articleViewModel = ArticleViewModel(article: article)
        let articleViewController = ArticleViewController(nibName: nibNameForViewController(.article), viewModel: articleViewModel)
        
        navigationController?.pushViewController(articleViewController, animated: true)
    }
    
    func pushArticleWebViewController(articleUrl: URL) {
        let articleWebViewModel = ArticleWebViewModel(articleUrl: articleUrl)
        let articleWebViewController = ArticleWebViewController(nibName: nibNameForViewController(.articleWeb), viewModel: articleWebViewModel)
        
        self.navigationController?.pushViewController(articleWebViewController, animated: true)
    }
    
    // MARK: - Private API
    
    private func nibNameForViewController(_ viewController: ViewController) -> String {
        let nibName: String
        switch viewController {
            
        case .article:
            nibName = "ArticleViewController"
            
        case .articles:
            nibName = "ArticlesViewController"
            
        case .articleWeb:
            nibName = "ArticleWebViewController"
            
        case .channels:
            nibName = "ChannelsViewController"
            
        case .login:
            nibName = "LoginViewController"
        }

        return nibName
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

fileprivate extension MainCoordinator {
    
    enum ViewController {
        
        case article

        case articles
        
        case articleWeb

        case channels
        
        case login
    }
}
