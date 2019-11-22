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
    
    let dateLabelText: String?
    
    let titleLabelText: String?
    
    // MARK: - Internal Static Properties
    
    static let reusableIdentifier = "ArticleReusableView"
    
    // MARK: - Lifecycle
    
    init(article: Article) {
        articleImageViewBackgroundColor = UIColor.gray.withAlphaComponent(0.3)
        articleImageViewImageUrlString = article.thumbnailUrlString

        channelLabelText = article.channel?.title
        
        dateLabelText = article.articleDate?.standardDateString
        
        titleLabelText = article.articleTitle
    }
}
