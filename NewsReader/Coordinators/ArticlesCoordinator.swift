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
    
    // MARK: - Lifecycle
    
    init(channel: Channel) {
        self.channel = channel
    }
    
    // MARK: - Internal API
    
    func fetchArticles(completion: @escaping([ArticleAlias]) -> ()) {}
    
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
