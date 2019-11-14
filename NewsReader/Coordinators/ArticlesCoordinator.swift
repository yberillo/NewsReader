//
//  ArticlesCoordinator.swift
//  NewsReader
//
//  Created by Yury Beryla on 11/13/19.
//  Copyright © 2019 Yury Beryla. All rights reserved.
//

import CoreData
import Foundation

class ArticlesCoordinator: NSObject {
    
    // MARK: - Internal Properties
    
    let channel: Channel
    
    // MARK: - Lifecycle
    
    init(channel: Channel) {
        self.channel = channel
    }
    
    // MARK: - Internal API
    
    func fetchArticles(context: NSManagedObjectContext, completion: @escaping([ArticleAlias]) -> ()) {}
}

extension ArticlesCoordinator {
    
    class ArticleAlias {
        
        var articleDate: Date?
        var articleDescription: String?
        var articleTitle: String?
        var imageUrlString: String?
        var urlString: String?
        var thumbnailUrlString: String?
        var channel: Channel?
    }
}
