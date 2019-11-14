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
    
    let signOutButtonTitle: String
    
    // MARK: - Lifecycle
    
    init() {
        signOutButtonTitle = NSLocalizedString("articles.button.sign_out", comment: "Sign out")
    }
}
