//
//  LentaruArticlesCoordinator.swift
//  NewsReader
//
//  Created by Yury Beryla on 11/13/19.
//  Copyright © 2019 Yury Beryla. All rights reserved.
//

import CoreData
import Foundation

final class LentaruArticlesCoordinator: ArticlesCoordinator {
    
    override func fetchArticles(rssParserKeys: RSSParserKeys, parseDescription: ((String) -> (String, String))? = nil, completion: @escaping([ArticleAlias]) -> ()) {
        super.fetchArticles(rssParserKeys: rssParserKeys, completion: completion)
    }
}
