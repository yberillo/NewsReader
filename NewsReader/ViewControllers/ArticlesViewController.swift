//
//  ArticlesViewController.swift
//  NewsReader
//
//  Created by Yury Beryla on 11/13/19.
//  Copyright © 2019 Yury Beryla. All rights reserved.
//

import UIKit

class ArticlesViewController: UITableViewController {
    
    // MARK: - Private Properties
    
    let articleReusableViewIdentifier = "ArticleReusableView"
    
    let articlesDataController: ArticlesDataController
    
    // MARK: - Internal Properties
    
    var navigationItemTitle: String?
    
    // MARK: - Lifecycle
    
    required init?(coder: NSCoder) {
        articlesDataController = ArticlesDataController()
        
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = navigationItemTitle
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articlesDataController.articlesCount
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: articleReusableViewIdentifier, for: indexPath) as? ArticleReusableView,
            let article = articlesDataController.article(at: indexPath.item) else {
            
            return UITableViewCell()
        }
        
        cell.dateLabel.text = article.articleDate
        
        var image: UIImage?
        
        DispatchQueue.global().async {
            guard let imageUrlString = article.imageUrlString,
                let imageUrl = URL(string: imageUrlString),
                let imageData = try? Data(contentsOf: imageUrl) else {
                    
                    return
            }
              
            image = UIImage(data: imageData)
        }
        cell.articleImageView.image = image
        cell.titleLabel.text = article.articleTitle
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120.0
    }
}
