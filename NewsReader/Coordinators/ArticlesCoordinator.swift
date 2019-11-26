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
    
    // MARK: - Strings
    
    private let brOpeningString = "<br"
    
    private let entityName = "Article"
    
    private let imageUrlStringClosingString = "\""
    
    private let imgClosingString = "/>"
    
    private let imgOpeningString = "<img src=\""
    
    // MARK: - Internal Properties
    
    let channel: Channel
    
    var rssParserKeys: RSSParserKeys
    
    // MARK: - Lifecycle
    
    init(channel: Channel, rssParserKeys: RSSParserKeys = RSSParserKeys()) {
        self.channel = channel
        self.rssParserKeys = rssParserKeys
    }
    
    // MARK: - Internal API
    
    func fetchArticles(rssParserKeys: RSSParserKeys, completion: @escaping([ArticleAlias]) -> ()) {
        guard let rssUrlString = self.channel.url, let rssUrl = URL(string: rssUrlString) else {
                return
        }
        let parser = RSSParser(rssParserKeys: rssParserKeys)
        DispatchQueue.global().async {
            parser.parseFrom(url: rssUrl) { [weak self] (parsed) in
                if parsed {
                    var articles: [ArticleAlias] = []
                    for element in parser.parsedData {
                        guard let strongSelf = self else {
                            return
                        }
                        let article = ArticleAlias()
                        if let articleDateString = element[rssParserKeys.pubDate] {
                            article.articleDate = articleDateString.dateFromRssDateString
                        }
                        
                        switch self?.channel.title {
                            
                        case ChannelsDataController.Channels.lentaru.rawValue:
                            article.articleDescription = element[rssParserKeys.description]
                            article.thumbnailUrlString = element[rssParserKeys.enclosure]
                            
                        case ChannelsDataController.Channels.tutby.rawValue:
                            let (thumbnailUrlString, descriptionTextString) = self?.parseDescription(descriptionString: element[rssParserKeys.description]) ?? (element[rssParserKeys.enclosure], element[rssParserKeys.description])
                            
                            article.articleDescription = descriptionTextString
                            article.thumbnailUrlString = thumbnailUrlString
                            
                        default:
                            assertionFailure("Unknown channel")
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
    
    // MARK: - Private API
    
    private func parseDescription(descriptionString: String?) -> (imageUrlString: String, descriptionTextString: String) {
        
        guard let descriptionString = descriptionString else {
            return ("", "")
        }
        var tempString = descriptionString
        
        if let imgOpeningRange = tempString.range(of: imgOpeningString) {
            tempString = String(tempString.suffix(from: imgOpeningRange.upperBound))
        }
        let imageUrlString: String
        if let imageUrlStringClosingRange = tempString.range(of: imageUrlStringClosingString) {
            imageUrlString = String(tempString.prefix(upTo: imageUrlStringClosingRange.lowerBound))
        }
        else {
            imageUrlString = ""
        }
        if let imgClosingRange = tempString.range(of: imgClosingString) {
            tempString = String(tempString.suffix(from: imgClosingRange.upperBound))
        }
        let descriptionTextString: String
        if let brOpeningRange = tempString.range(of: brOpeningString) {
            descriptionTextString = String(tempString.prefix(upTo: brOpeningRange.lowerBound))
        }
        else {
            descriptionTextString = ""
        }
        
        return (imageUrlString, descriptionTextString)
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
