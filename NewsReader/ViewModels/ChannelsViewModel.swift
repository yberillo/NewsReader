//
//  ChannelsViewModel.swift
//  NewsReader
//
//  Created by Yury Beryla on 11/12/19.
//  Copyright © 2019 Yury Beryla. All rights reserved.
//

import Foundation

struct ChannelsViewModel {
    
    // MARK: - Internal Properties
    
    let navigationItemTitle: String
    
    let nextButtonText: String
    
    let signOutButtonText: String
    
    // MARK: - Lifecycle
    
    init() {
        navigationItemTitle = StringsManager.channelsViewControllerNavigationItemTitle
        nextButtonText = StringsManager.channelsViewControllerNextButtonText
        signOutButtonText = StringsManager.articlesViewControllerSignOutButtonTitle
    }
}
