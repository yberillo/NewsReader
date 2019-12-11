//
//  ViewControllerManager.swift
//  NewsReader
//
//  Created by Yury Beryla on 12/11/19.
//  Copyright © 2019 Yury Beryla. All rights reserved.
//

import Foundation
import UIKit

final class ViewControllerManager {
    
    // MARK: - Internal API
    
    func makeViewController(_ viewControllerType: MainCoordinator.ViewController, data: [DataKey : Any]? = nil) -> UIViewController? {
        let viewController: UIViewController
        
        switch viewControllerType {
            
        case .article:
            guard let article = data?[.article] as? Article else {
                return nil
            }
            let articleViewModel = ArticleViewModel(article: article)
            viewController = ArticleViewController(nibName: nibNameForViewController(.article), viewModel: articleViewModel)
            
        case .articles:
            guard let selectedChannels = data?[.selectedChannels] as? [Channel] else {
                return nil
            }
            let articlesDataController = ArticlesDataController(selectedChannels: selectedChannels)
            let articlesViewModel = ArticlesViewModel(articlesDataController: articlesDataController)
            let articlesViewController = ArticlesViewController(nibName: nibNameForViewController(.articles), viewModel: articlesViewModel)
            articlesDataController.articlesFetchedResultsController.delegate = articlesViewController
            
            viewController = articlesViewController
            
        case .articleWeb:
            guard let articleUrl = data?[.articleUrl] as? URL else {
                return nil
            }
            let articleWebViewModel = ArticleWebViewModel(articleUrl: articleUrl)
            viewController = ArticleWebViewController(nibName: nibNameForViewController(.articleWeb), viewModel: articleWebViewModel)
            
        case .channels:
            guard let usersDataController = data?[.usersDataController] as? UsersDataController else {
                return nil
            }
            let channelsDataController = ChannelsDataController()
            let channelsViewModel = ChannelsViewModel(channelsDataController: channelsDataController, usersDataController: usersDataController)
            viewController = ChannelsViewController(nibName: nibNameForViewController(.channels), viewModel: channelsViewModel)
            
        case .login:
            guard let usersDataController = data?[.usersDataController] as? UsersDataController else {
                return nil
            }
            let loginViewModel = LoginViewModel(usersDataController: usersDataController)
            viewController = LoginViewController(nibName: nibNameForViewController(.login), viewModel: loginViewModel)

        }
        return viewController
    }
    
    // MARK: - Private API
    
    private func nibNameForViewController(_ viewController: MainCoordinator.ViewController) -> String {
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
}

extension ViewControllerManager {
    enum DataKey {
        
        case article
        
        case articleUrl
                        
        case selectedChannels
        
        case usersDataController
    }
}
