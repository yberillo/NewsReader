//
//  ArticlesDataController.swift
//  NewsReader
//
//  Created by Yury Beryla on 11/13/19.
//  Copyright © 2019 Yury Beryla. All rights reserved.
//

import CoreData
import UIKit

final class ArticlesDataController {
    
    // MARK: - Private Properties
    
    private var articles: [Article]
    
    // MARK: - Internal Properties
    
    var articlesCount: Int {
        return articles.count
    }
    
    // MARK: - Lifecycle
    
    init() {
        
        articles = []
    }
    
    // MARK: - Internal API
    
    func article(at index: Int) -> Article? {
        
        if index < articles.count {
            return articles[index]
        }
        else {
            return nil
        }
    }
}
