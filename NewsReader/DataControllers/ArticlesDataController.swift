//
//  ArticlesDataController.swift
//  NewsReader
//
//  Created by Yury Beryla on 11/13/19.
//  Copyright © 2019 Yury Beryla. All rights reserved.
//

import CoreData
import UIKit

final class ArticlesDataController: NSObject, NSFetchedResultsControllerDelegate {
    
    // MARK: - Strings
    
    private let brOpeningString = "<br"
        
    private let imageUrlStringClosingString = "\""
    
    private let imgClosingString = "/>"
    
    private let imgOpeningString = "<img src=\""
    
    // MARK: - Private Properties
        
    private var channelsLoadedCount: Int
        
    private var context: NSManagedObjectContext = {
        return CoreDataManager.shared.persistentContainer.viewContext
    }()
    
    private let entityName = "Article"
                
    private var shouldDeleteArticles: Bool {
        return self.channelsLoadedCount == 1 ? true : false
    }
    
    // MARK: - Internal Properties
    
    var articlesCount: Int {
        return self.articlesFetchedResultsController.fetchedObjects?.count ?? 0
    }
    
    let articlesFetchedResultsController: NSFetchedResultsController<Article>
    
    let selectedChannels: [Channel]?
        
    // MARK: - Lifecycle
    
    init(selectedChannels: [Channel]?) {
        self.channelsLoadedCount = 0
        self.selectedChannels = selectedChannels
        
        let articlesFetchRequest = NSFetchRequest<Article>(entityName: self.entityName)
        let sortDescriptor = NSSortDescriptor(key: Keys.articleDate, ascending: false)
        articlesFetchRequest.sortDescriptors = [sortDescriptor]

        articlesFetchedResultsController = NSFetchedResultsController<Article>(fetchRequest: articlesFetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)

        super.init()
        
        self.fetchArticles()
    }
    
    // MARK: - Private API
    
    private func deleteAllArticlesIfNeeded(withCompletionHandler completion: (() -> ())) {
        if !shouldDeleteArticles {
            completion()
            return
        }
        let articlesFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: self.entityName)
        let articlesDeleteRequest = NSBatchDeleteRequest(fetchRequest: articlesFetchRequest)
        articlesDeleteRequest.resultType = .resultTypeObjectIDs
        do {
            guard let batchRequestResult = try context.execute(articlesDeleteRequest) as? NSBatchDeleteResult,
                let deletedObjectsKey = batchRequestResult.result as? [NSManagedObjectID] else {
                    return
            }
            let changes: [AnyHashable: Any] = [NSDeletedObjectsKey: deletedObjectsKey]
            context.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
            NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [context])

            try context.save()
            completion()
        }
        catch let error as NSError {
            ErrorManager.handle(error: error)
        }
    }
    
    private func importArticles(from articles: [ArticleAlias], completion: @escaping (() -> ())) {
        if articles.isEmpty {
            return
        }
        for article in articles {
            let newArticle = Article(context: context)
            typealias keys = ArticlesDataController.Keys

            newArticle.setValue(article.articleDate, forKey: keys.articleDate)
            newArticle.setValue(article.articleDescription, forKey: keys.articleDescription)
            newArticle.setValue(article.articleTitle, forKey: keys.articleTitle)
            newArticle.setValue(article.channel, forKey: keys.channel)
            newArticle.setValue(article.imageUrlString, forKey: keys.imageUrlString)
            newArticle.setValue(article.thumbnailUrlString, forKey: keys.thumbnailUrlString)
            newArticle.setValue(article.urlString, forKey: keys.urlString)
        }
        do {
            try context.save()
            completion()
        }
        catch let error as NSError {
            ErrorManager.handle(error: error)
        }
    }
    
    private func loadArticles(rssParserKeys: RSSParserKeys, channel: Channel, completion: @escaping([ArticleAlias]) -> ()) {
        guard let rssUrlString = channel.url, let rssUrl = URL(string: rssUrlString), let channelType = channel.type else {
                return
        }
        let parser = RSSParser(rssParserKeys: rssParserKeys)
        DispatchQueue.global().async {
            parser.parseFrom(url: rssUrl) { [weak self] (parsed) in
                if parsed {
                    var articles: [ArticleAlias] = []
                    for element in parser.parsedData {
                        let article = ArticleAlias()
                        if let articleDateString = element[rssParserKeys.pubDate] {
                            article.articleDate = articleDateString.dateFromRssDateString
                        }
                        
                        switch channelType {
                            
                        case .lentaru:
                            article.articleDescription = element[rssParserKeys.description]
                            article.thumbnailUrlString = element[rssParserKeys.enclosure]
                            
                        case .tutby:
                            let (thumbnailUrlString, descriptionTextString) = self?.parseDescription(descriptionString: element[rssParserKeys.description]) ?? (element[rssParserKeys.enclosure], element[rssParserKeys.description])
                            
                            article.articleDescription = descriptionTextString
                            article.thumbnailUrlString = thumbnailUrlString
                            
                        @unknown default:
                            assertionFailure("Unknown channel")
                        }
                        article.articleTitle = element[rssParserKeys.title]
                        article.imageUrlString = element[rssParserKeys.enclosure]
                        article.channel = channel
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
        
    // MARK: - Internal API
    
    func article(at index: Int) -> Article? {
        guard let articles = articlesFetchedResultsController.fetchedObjects else {
            return nil
        }
        if index < articles.count {
            return articles[index]
        }
        else {
            return nil
        }
    }
    
    func deleteArticle(at index: Int) {
        guard let article = article(at: index) else {
            return
        }
        context.delete(article)
        do {
            try context.save()
        }
        catch let error as NSError {
            ErrorManager.handle(error: error)
        }
    }
    
    func fetchArticles(of channels: [Channel]? = nil, completion: (() -> ())? = nil) {
        if let channels = channels {
            var predicates: [NSPredicate] = []
            for channel in channels {
                let predicate = NSPredicate(format: "\(ArticlesDataController.Keys.channel) = %@", channel)
                predicates.append(predicate)
            }
            articlesFetchedResultsController.fetchRequest.predicate = NSCompoundPredicate(orPredicateWithSubpredicates: predicates)
        }
        
        do {
            try articlesFetchedResultsController.performFetch()
            if let completion = completion {
                completion()
            }
        }
        catch let error as NSError {
            ErrorManager.handle(error: error)
        }
    }
    
    func refetchArticles(completion: (() -> ())? = nil) {
        self.channelsLoadedCount = 0
        guard let selectedChannels = self.selectedChannels else {
            return
        }
        for channel in selectedChannels {
            loadArticles(rssParserKeys: RSSParserKeys(), channel: channel) { [weak self] (articles)  in
                if !articles.isEmpty {
                    self?.channelsLoadedCount += 1
                }
                self?.deleteAllArticlesIfNeeded {
                    self?.importArticles(from: articles, completion: {
                        if let completion = completion {
                            completion()
                        }
                    })
                }
            }
        }
    }
}

fileprivate extension ArticlesDataController {
        
    class ArticleAlias {
        
        var articleDate: Date?
        
        var articleDescription: String?
        
        var articleTitle: String?
        
        var imageUrlString: String?
        
        var urlString: String?
        
        var thumbnailUrlString: String?
        
        var channel: Channel?
    }
    
    struct Keys {
        
        static var articleDate: String {
            return "articleDate"
        }
        
        static var articleDescription: String {
            return "articleDescription"
        }
        
        static var articleTitle: String {
            return "articleTitle"
        }
        
        static var channel: String {
            return "channel"
        }
        
        static var imageUrlString: String {
            return "imageUrlString"
        }
        
        static var thumbnailUrlString: String {
            return "thumbnailUrlString"
        }
        
        static var urlString: String {
            return "urlString"
        }
    }
}
