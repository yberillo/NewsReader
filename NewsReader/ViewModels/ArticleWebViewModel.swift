//
//  ArticleWebViewModel.swift
//  NewsReader
//
//  Created by Yury Beryla on 12/9/19.
//  Copyright © 2019 Yury Beryla. All rights reserved.
//

import Foundation

struct ArticleWebViewModel {
    
    // MARK: - Internal Properties
    
    let articleUrl: URL
    
    // MARK: - Lifecycle
    
    init(articleUrl: URL) {
        self.articleUrl = articleUrl
    }
}
