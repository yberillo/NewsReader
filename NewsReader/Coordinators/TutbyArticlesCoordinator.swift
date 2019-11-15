//
//  TutbyArticlesCoordinator.swift
//  NewsReader
//
//  Created by Yury Beryla on 11/13/19.
//  Copyright © 2019 Yury Beryla. All rights reserved.
//

import CoreData
import Foundation

final class TutbyArticlesCoordinator: ArticlesCoordinator {
    
    // MARK: - Strings
    
    private let brOpeningString = "<br"
    
    private let entityName = "Article"
    
    private let imageUrlStringClosingString = "\""
    
    private let imgClosingString = "/>"
    
    private let imgOpeningString = "<img src=\""
    
    // MARK: - Internal API
    
    override func fetchArticles(completion: @escaping([ArticleAlias]) -> ()) {
        
        guard let rssUrlString = self.channel.url, let rssUrl = URL(string: rssUrlString) else {
            
            return
        }
        let parser = RSSParser(rssParseKeys: TutbyArticlesCoordinator.Keys.self)
        DispatchQueue.global().async {
            parser.parseFrom(url: rssUrl) { [weak self] (_) in
                
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
                    let (thumbnailUrlString, descriptionTextString) = strongSelf.parseDescription(descriptionString: element[keys.description])
                    article.articleDescription = descriptionTextString
                    article.articleTitle = element[keys.title]
                    article.imageUrlString = element[keys.enclosure]
                    article.channel = strongSelf.channel
                    article.urlString = element[keys.link]
                    article.thumbnailUrlString = thumbnailUrlString
                   
                    articles.append(article)
                }
                DispatchQueue.main.async {
                    completion(articles)
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

extension TutbyArticlesCoordinator {
    
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
