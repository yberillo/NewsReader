//
//  ArticleReusableViewModel.swift
//  NewsReader
//
//  Created by Yury Beryla on 11/18/19.
//  Copyright © 2019 Yury Beryla. All rights reserved.
//

import UIKit

final class ArticleReusableViewModel {
    
    // MARK: - Internal Properties
    
    let articleImageViewBackgroundColor: UIColor
    
    let articleImageViewImageUrlString: String?
    
    let channelLabelText: String?
    
    let dateLabelText: String
    
    let titleLabelText: String?
    
    // MARK: - Lifecycle
    
    init(article: Article) {
        articleImageViewBackgroundColor = UIColor.gray.withAlphaComponent(0.3)
        articleImageViewImageUrlString = article.thumbnailUrlString

        channelLabelText = article.channel?.title
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy HH:mm:ss"
        dateLabelText = dateFormatter.string(from: article.articleDate ?? Date())
        
        titleLabelText = article.articleTitle
    }
}
