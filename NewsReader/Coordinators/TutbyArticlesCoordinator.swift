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
    
    override func fetchArticles(coordinator:ArticlesCoordinator, parseDescription: ((String) -> (String, String))? = nil, completion: @escaping([ArticleAlias]) -> ()) {
        super.fetchArticles(coordinator: coordinator, parseDescription: self.parseDescription(descriptionString:), completion: completion)
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
