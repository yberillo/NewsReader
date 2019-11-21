//
//  ArticlesDataController.swift
//  NewsReader
//
//  Created by Yury Beryla on 11/13/19.
//  Copyright © 2019 Yury Beryla. All rights reserved.
//

import CoreData
import UIKit

protocol ArticlesDataControllerDelegate: NSObjectProtocol {
    func articlesDidChange()
}

final class ArticlesDataController: NSObject, NSFetchedResultsControllerDelegate {
    
    // MARK: - Private Properties
    
    private lazy var articlesFetchedResultsController: NSFetchedResultsController<Article> = {
        let articlesFetchRequest = NSFetchRequest<Article>(entityName: self.entityName)
        let sortDescriptor = NSSortDescriptor(key: Keys.articleDate, ascending: false)
        articlesFetchRequest.sortDescriptors = [sortDescriptor]
        
        let fetchedResultsController = NSFetchedResultsController<Article>(fetchRequest: articlesFetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
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
        return self.articlesFetchedResultsController.fetchedObjects?.count ?? 0
    }
    
    weak var delegate: ArticlesDataControllerDelegate?
    
    // MARK: - Lifecycle
    
    init(selectedChannels: [Channel]?) {
        self.channelsLoadedCount = 0
        self.selectedChannels = selectedChannels
        
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
        completion()
    }
    
    private func fetchArticles() {
        do {
            try articlesFetchedResultsController.performFetch()
        }
        catch let error as NSError {
            ErrorManager.handle(error: error)
        }
    }
    
    private func importArticles(from articles: [ArticlesCoordinator.ArticleAlias]) {
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
    
    func refetchArticles(completion: @escaping (() -> ())) {
        self.channelsLoadedCount = 0
        guard let selectedChannels = self.selectedChannels else {
            return
        }
        for channel in selectedChannels {
            let articlesCoordinator = ArticlesCoordinator.getCoordinatorFor(channel: channel)
            articlesCoordinator.fetchArticles(rssParserKeys: articlesCoordinator.rssParserKeys) { [weak self] (articles)  in
                if !articles.isEmpty {
                    self?.channelsLoadedCount += 1
                }
                self?.deleteAllArticlesIfNeeded {
                    self?.importArticles(from: articles)
                }
            }
        }
    }
    
    // MARK: - NSFetchedResultsControllerDelegate
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.delegate?.articlesDidChange()
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
