//
//  ArticleViewController.swift
//  NewsReader
//
//  Created by Yury Beryla on 11/14/19.
//  Copyright © 2019 Yury Beryla. All rights reserved.
//

import UIKit

final class ArticleViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var linkLabel: UILabel!
    
    @IBOutlet weak var textLabel: UILabel!
        
    @IBOutlet weak var titleLabel: UILabel!
    
    // MARK: - Private Properties
    
    private let gestureRecognizer: UITapGestureRecognizer
    
    // MARK: - Internal Properties
    
    var article: Article?
    
    // MARK: - Lifecycle
    
    required init?(coder: NSCoder) {
        
        gestureRecognizer = UITapGestureRecognizer()
        
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let article = self.article else {
            return
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy HH:mm:ss"
        dateLabel.text = dateFormatter.string(from: article.articleDate ?? Date())
        var image: UIImage?
        
        DispatchQueue.global().async { [weak self] in
            guard let imageUrlString = article.imageUrlString,
                let imageUrl = URL(string: imageUrlString),
                let imageData = try? Data(contentsOf: imageUrl) else {
                    
                    return
            }
              
            image = UIImage(data: imageData)
            DispatchQueue.main.async {
                
                self?.imageView.image = image
            }
        }
        
        linkLabel.text = article.urlString
        linkLabel.isUserInteractionEnabled = true
        textLabel.text = article.articleDescription
        titleLabel.text = article.articleTitle
        
        linkLabel.addGestureRecognizer(gestureRecognizer)
        
        gestureRecognizer.addTarget(self, action: #selector(self.gestureRecognizerTap))
    }
    
    // MARK: - Actions
    
    @objc
    private func gestureRecognizerTap() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        guard let articleWebViewController = storyboard.instantiateViewController(identifier: "ArticleWebViewController") as? ArticleWebViewController,
            let article = self.article,
            let articleUrlString = article.urlString,
            let articleUrl = URL(string: articleUrlString) else {
            return
        }
        articleWebViewController.articleUrl = articleUrl
        
        self.navigationController?.pushViewController(articleWebViewController, animated: true)
    }
}
