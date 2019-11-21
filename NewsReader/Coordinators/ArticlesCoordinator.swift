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
    
    var rssParserKeys: RSSParserKeys
    
    // MARK: - Lifecycle
    
    init(channel: Channel, rssParserKeys: RSSParserKeys = RSSParserKeys()) {
        self.channel = channel
        self.rssParserKeys = rssParserKeys
    }
    
    // MARK: - Internal API
    
    func fetchArticles(coordinator: ArticlesCoordinator, parseDescription: ((String?) -> (String, String))? = nil, completion: @escaping([ArticleAlias]) -> ()) {
        guard let rssUrlString = self.channel.url, let rssUrl = URL(string: rssUrlString) else {
                
                return
        }
        let rssParserKeys = coordinator.rssParserKeys
        let parser = RSSParser(rssParserKeys: coordinator.rssParserKeys)
        DispatchQueue.global().async {
            parser.parseFrom(url: rssUrl) { [weak self] (parsed) in
                if parsed {
                    var articles: [ArticleAlias] = []
                    for element in parser.parsedData {
                        guard let strongSelf = self else {
                            return
                        }
                        let article = ArticleAlias()
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "E, d MMM yyyy HH:mm:ss Z"
                        let date = dateFormatter.date(from: element[rssParserKeys.pubDate] ?? "")
                        article.articleDate = date
                        if let parseDescription = parseDescription {
                            let (thumbnailUrlString, descriptionTextString) = parseDescription(element[rssParserKeys.description])
                            
                            article.articleDescription = descriptionTextString
                            article.thumbnailUrlString = thumbnailUrlString
                        }
                        else {
                            article.articleDescription = element[rssParserKeys.description]
                            article.thumbnailUrlString = element[rssParserKeys.enclosure]
                        }
                        article.articleTitle = element[rssParserKeys.title]
                        article.imageUrlString = element[rssParserKeys.enclosure]
                        article.channel = strongSelf.channel
                        article.urlString = element[rssParserKeys.link]
                       
                        articles.append(article)
                    }
                    DispatchQueue.main.async {
                        completion(articles)
                    }
                }
            }
        }
    }
    
    // MARK: - Internal Static API
    
    static func getCoordinatorFor(channel: Channel) -> ArticlesCoordinator {
        switch channel.title {

        case ChannelsDataController.Channels.lentaru.rawValue:
            return LentaruArticlesCoordinator(channel: channel)

        case ChannelsDataController.Channels.tutby.rawValue:
            return TutbyArticlesCoordinator(channel: channel)

        default:
            return ArticlesCoordinator(channel: channel)
        }
    }
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
