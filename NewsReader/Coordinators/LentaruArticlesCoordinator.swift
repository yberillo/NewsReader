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
    
    override func fetchArticles(completion: @escaping([ArticleAlias]) -> ()) {
        guard let rssUrlString = self.channel.url, let rssUrl = URL(string: rssUrlString) else {
            
            return
        }
        let parser = RSSParser(rssParseKeys: TutbyArticlesCoordinator.Keys.self)
        DispatchQueue.global().async {
            parser.parseFrom(url: rssUrl) { [weak self] (parsed) in
                if parsed {
                    var articles: [ArticleAlias] = []
                    for element in parser.parsedData {
                        guard let strongSelf = self else {
                            return
                        }
                        let article = ArticleAlias()
                        typealias keys = Keys
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "E, d MMM yyyy HH:mm:ss Z"
                        let date = dateFormatter.date(from: element[keys.pubDate] ?? "")
                        article.articleDate = date
                        article.articleDescription = element[keys.description]
                        article.articleTitle = element[keys.title]
                        article.imageUrlString = element[keys.enclosure]
                        article.channel = strongSelf.channel
                        article.urlString = element[keys.link]
                        article.thumbnailUrlString = element[keys.enclosure]
                       
                        articles.append(article)
                    }
                    DispatchQueue.main.async {
                        completion(articles)
                    }
                }
            }
        }
    }
}

extension LentaruArticlesCoordinator {
    
    class Keys: NSObject, RSSParserKeys {
        
        static var description: String {
           return "description"
        }
        
        static var enclosure: String {
            return "enclosure"
        }
        
        static var item: String {
            return"item"
        }
        
        static var link: String {
            return "link"
        }
        
        static var pubDate: String {
            return "pubDate"
        }
        
        static var title: String {
            return "title"
        }
        
        static var url: String {
            return "url"
        }
    }
}
