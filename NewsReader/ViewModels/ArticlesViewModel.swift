//
//  ArticlesViewModel.swift
//  NewsReader
//
//  Created by Yury Beryla on 11/14/19.
//  Copyright © 2019 Yury Beryla. All rights reserved.
//

import Foundation
struct ArticlesViewModel {
    
    // MARK: - Internal Properties
    
    let alertCancelButtonTitle: String
    
    let alertDeleteButtonTitle: String
    
    let alertMessageText: String
        
    let alertTitleText: String
    
    let filterAllText: String
    
    let filterCancelButtonTitle: String
    
    let filterDoneButtonTitle: String
    
    let signOutButtonTitle: String
    
    // MARK: - Lifecycle
    
    init() {
        alertCancelButtonTitle = StringsManager.articlesViewControllerAlertCancel
        alertDeleteButtonTitle = StringsManager.articlesViewControllerAlertDelete
        alertMessageText = StringsManager.articlesViewControllerAlertMessage
        alertTitleText = StringsManager.articlesViewControllerAlertTitle
        filterAllText = StringsManager.articlesViewControllerFilterAll
        filterCancelButtonTitle = StringsManager.articlesViewControllerAlertCancel
        filterDoneButtonTitle = StringsManager.articlesViewControllerFilterDone
        signOutButtonTitle = StringsManager.articlesViewControllerSignOutButtonTitle
    }
}
