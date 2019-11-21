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
    
    override func fetchArticles(coordinator: ArticlesCoordinator, parseDescription: ((String) -> (String, String))? = nil, completion: @escaping([ArticleAlias]) -> ()) {
        super.fetchArticles(coordinator: coordinator, completion: completion)
    }
}
