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
        
    private var context: NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        return appDelegate.persistentContainer.viewContext
    }
    
    private let entityName = "Article"
        
    private let selectedChannels: [Channel]?
    
    // MARK: - Internal Properties
    
    var articlesCount: Int {
        return articles.count
    }
    
    // MARK: - Lifecycle
    
    init(selectedChannels: [Channel]?) {
        self.articles = []
        self.selectedChannels = selectedChannels
        
        self.fetchArticles()
    }
    
    // MARK: - Private API
    
    private func deleteAllArticles(withCompletionHandler completion: (() -> ())) {
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
            print(error)
        }
        articles = []
        completion()
    }
    
    private func fetchArticles() {
        guard let selectedChannels = self.selectedChannels else {
            
            return
        }
        let articlesFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: self.entityName)
                    
        var predicates: [NSPredicate] = []
        
        for channel in selectedChannels {
            
            let predicate = NSPredicate(format: "\(ArticlesDataController.Keys.channel) = %@", channel)
            predicates.append(predicate)
        }
        
        articlesFetchRequest.predicate = NSCompoundPredicate(orPredicateWithSubpredicates: predicates)
                    
        do {
            
            guard let articles = try self.context.fetch(articlesFetchRequest) as? [Article] else {
                
                return
            }
                        
            for article in articles {
                
                self.articles.append(article)
            }
        }
        catch let error as NSError {
            
            print(error)
        }
    }
    
    private func importArticles(from articles: [ArticlesCoordinator.ArticleAlias]) -> Bool {
        if articles.isEmpty {
            return false
        }
        
        guard let articleEntity = NSEntityDescription.entity(forEntityName: entityName, in: context) else {
            return false
        }
        
        for article in articles {

            let newArticle = NSManagedObject(entity: articleEntity, insertInto: context)
            typealias keys = ArticlesDataController.Keys

            newArticle.setValue(article.articleDate, forKey: keys.articleDate)
            newArticle.setValue(article.articleDescription, forKey: keys.articleDescription)
            newArticle.setValue(article.articleTitle, forKey: keys.articleTitle)
            newArticle.setValue(article.channel, forKey: keys.channel)
            newArticle.setValue(article.imageUrlString, forKey: keys.imageUrlString)
            newArticle.setValue(article.thumbnailUrlString, forKey: keys.thumbnailUrlString)
            newArticle.setValue(article.urlString, forKey: keys.urlString)

            do {

                try context.save()
            }
            catch let error as NSError {

                print(error)
            }
        }
        return true
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
        deleteAllArticles {
            guard let selectedChannels = self.selectedChannels else {
                
                return
            }
            for channel in selectedChannels {
                
                var articlesCoordinator: ArticlesCoordinator
                
                switch channel.title {
                    
                case ChannelsDataController.Channels.lentaru.rawValue:
                    articlesCoordinator = LentaruArticlesCoordinator(channel: channel)
                    
                case ChannelsDataController.Channels.tutby.rawValue:
                    articlesCoordinator = TutbyArticlesCoordinator(channel: channel)
                    
                default:
                    articlesCoordinator = ArticlesCoordinator(channel: channel)
                }
                
                articlesCoordinator.fetchArticles { [weak self] (articles)  in
                    let isImported = self?.importArticles(from: articles)
                    if isImported == true
                    {
                        self?.fetchArticles()
                        completion()
                    }
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
