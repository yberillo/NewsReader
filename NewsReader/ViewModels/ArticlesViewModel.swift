//
//  ArticlesViewModel.swift
//  NewsReader
//
//  Created by Yury Beryla on 11/14/19.
//  Copyright © 2019 Yury Beryla. All rights reserved.
//

import Foundation

struct ArticlesViewModel {
    
    // MARK: - DataControllers
    
    let articlesDataController: ArticlesDataController
        
    // MARK: - Internal Properties
    
    let alertCancelButtonTitle: String
    
    let alertDeleteButtonTitle: String
    
    let alertMessageText: String
        
    let alertTitleText: String
    
    var articlesCount: Int {
        return articlesDataController.articlesCount
    }
    
    let filterAllText: String
    
    let filterCancelButtonTitle: String
    
    let filterDoneButtonTitle: String
    
    var filterSelectedChannel: Channel?
        
    let signOutButtonTitle: String
    
    // MARK: - Lifecycle
    
    init(articlesDataController: ArticlesDataController) {
        self.articlesDataController = articlesDataController
        
        alertCancelButtonTitle = StringsManager.articlesViewControllerAlertCancel
        alertDeleteButtonTitle = StringsManager.articlesViewControllerAlertDelete
        alertMessageText = StringsManager.articlesViewControllerAlertMessage
        alertTitleText = StringsManager.articlesViewControllerAlertTitle
        filterAllText = StringsManager.articlesViewControllerFilterAll
        filterCancelButtonTitle = StringsManager.articlesViewControllerAlertCancel
        filterDoneButtonTitle = StringsManager.articlesViewControllerFilterDone
        signOutButtonTitle = StringsManager.articlesViewControllerSignOutButtonTitle
    }
    
    // MARK: - Internal API
    
    func article(at index: Int) -> Article? {
        return articlesDataController.article(at: index)
    }
    
    func deleteArticle(at index: Int) {
        articlesDataController.deleteArticle(at: index)
    }
    
    func fetchArticles(of channels: [Channel]? = nil, completion: (() -> ())? = nil) {
        articlesDataController.fetchArticles(of: channels, completion: completion)
    }
    
    func refetchArticles(completion: (() -> ())? = nil) {
        articlesDataController.refetchArticles(completion: completion)
    }
}
