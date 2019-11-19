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
    
    private lazy var articlesFetchedResultsController: NSFetchedResultsController<Article> = {
        let articlesFetchRequest = NSFetchRequest<Article>(entityName: self.entityName)
        let sortDescriptor = NSSortDescriptor(key: Keys.articleDate, ascending: false)
        articlesFetchRequest.sortDescriptors = [sortDescriptor]
        
        let fetchedResultsController = NSFetchedResultsController<Article>(fetchRequest: articlesFetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        
        return fetchedResultsController
    }()
    
    private var channelsLoadedCount: Int
        
    private var context: NSManagedObjectContext {
        return CoreDataManager.shared.persistentContainer.viewContext
    }
    
    private let entityName = "Article"
            
    private let selectedChannels: [Channel]?
    
    private var shouldDeleteArticles: Bool {
        return self.channelsLoadedCount == 1 ? true : false
    }
    
    // MARK: - Internal Properties
    
    var articlesCount: Int {
        return articles.count
    }
    
    // MARK: - Lifecycle
    
    init(selectedChannels: [Channel]?) {
        self.articles = []
        self.channelsLoadedCount = 0
        self.selectedChannels = selectedChannels
        
        self.fetchArticles()
    }
    
    // MARK: - Private API
    
    private func deleteAllArticlesIfNeeded(withCompletionHandler completion: (() -> ())) {
        if !shouldDeleteArticles {
            completion()
            return
        }
        let articlesFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: self.entityName)
        articlesFetchRequest.returnsObjectsAsFaults = false
        do {
            guard let articlesToDelete = try context.fetch(articlesFetchRequest) as? [Article] else {
                return
            }

            for article in articlesToDelete {
                context.delete(article)
            }
        }
        catch let error as NSError {
            ErrorManager.handle(error: error)
        }
        articles = []
        completion()
    }
    
    private func fetchArticles() {
        guard let selectedChannels = self.selectedChannels else {
            
            return
        }
        self.articles = []
        var predicates: [NSPredicate] = []
        
        for channel in selectedChannels {
            let predicate = NSPredicate(format: "\(ArticlesDataController.Keys.channel) = %@", channel)
            predicates.append(predicate)
        }
        
        articlesFetchedResultsController.fetchRequest.predicate = NSCompoundPredicate(orPredicateWithSubpredicates: predicates)
                    
        do {
            try articlesFetchedResultsController.performFetch()
            guard let articles = articlesFetchedResultsController.fetchedObjects else {
                return
            }
            for article in articles {
                self.articles.append(article)
            }
        }
        catch let error as NSError {
            ErrorManager.handle(error: error)
        }
    }
    
    private func importArticles(from articles: [ArticlesCoordinator.ArticleAlias], completion: (() -> ())) {
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
        if index < articles.count {
            return articles[index]
        }
        else {
            return nil
        }
    }
    
    func refetchArticles(completion: @escaping (() -> ())) {
        self.channelsLoadedCount = 0
        guard let selectedChannels = self.selectedChannels else {
            return
        }
        for channel in selectedChannels {
            let articlesCoordinator = ArticlesCoordinator.getCoordinatorFor(channel: channel)
            articlesCoordinator.fetchArticles { [weak self] (articles)  in
                if !articles.isEmpty {
                    self?.channelsLoadedCount += 1
                }
                self?.deleteAllArticlesIfNeeded {
                    self?.importArticles(from: articles, completion: {
                        self?.fetchArticles()
                        completion()
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
