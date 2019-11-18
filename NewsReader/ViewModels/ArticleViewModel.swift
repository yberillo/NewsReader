//
//  ArticleViewModel.swift
//  NewsReader
//
//  Created by Yury Beryla on 11/18/19.
//  Copyright © 2019 Yury Beryla. All rights reserved.
//

import UIKit
final class ArticleViewModel {
    
    // MARK: - Internal Properties
    
    let dateLabelText: String?
    
    let linkLabelText: String?
        
    let imageViewBackgroundColor: UIColor
    
    let imageViewImageUrlString: String?
    
    let textLabelText: String?
    
    let titleLabelText: String?
    
    // MARK: - Lifecycle
    
    init(article: Article) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy HH:mm:ss"
        dateLabelText = dateFormatter.string(from: article.articleDate ?? Date())
        
        imageViewBackgroundColor = UIColor.gray.withAlphaComponent(0.3)
        imageViewImageUrlString = article.imageUrlString
        
        linkLabelText = article.urlString
        textLabelText = article.articleDescription
        titleLabelText = article.articleTitle
    }
}
