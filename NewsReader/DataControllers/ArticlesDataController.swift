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
    
    // MARK: - Private Properties
        
    private var channelsLoadedCount: Int
        
    private var context: NSManagedObjectContext = {
        return CoreDataManager.shared.persistentContainer.viewContext
    }()
    
    private let entityName = "Article"
            
    private let selectedChannels: [Channel]?
    
    private var shouldDeleteArticles: Bool {
        return self.channelsLoadedCount == 1 ? true : false
    }
    
    // MARK: - Internal Properties
    
    var articlesCount: Int {
        return self.articlesFetchedResultsController.fetchedObjects?.count ?? 0
    }
    
    let articlesFetchedResultsController: NSFetchedResultsController<Article>
        
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
    
    private func fetchArticles() {
        do {
            try articlesFetchedResultsController.performFetch()
        }
        catch let error as NSError {
            ErrorManager.handle(error: error)
        }
    }
    
    private func importArticles(from articles: [ArticlesCoordinator.ArticleAlias], completion: @escaping (() -> ())) {
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
    
    func deleteArticle(at indexPath: IndexPath) {
        guard let article = article(at: indexPath.item) else {
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
    
    func refetchArticles(completion: (() -> ())? = nil) {
        self.channelsLoadedCount = 0
        guard let selectedChannels = self.selectedChannels else {
            return
        }
        for channel in selectedChannels {
            let articlesCoordinator = ArticlesCoordinator(channel: channel)
            articlesCoordinator.fetchArticles(rssParserKeys: articlesCoordinator.rssParserKeys) { [weak self] (articles)  in
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
