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
    
    let signOutButtonTitle: String
    
    // MARK: - Lifecycle
    
    init() {
        alertCancelButtonTitle = StringsManager.articlesViewControllerAlertCancel
        alertDeleteButtonTitle = StringsManager.articlesViewControllerAlertDelete
        alertMessageText = StringsManager.articlesViewControllerAlertMessage
        alertTitleText = StringsManager.articlesViewControllerAlertTitle
        signOutButtonTitle = StringsManager.articlesViewControllerSignOutButtonTitle
    }
}
