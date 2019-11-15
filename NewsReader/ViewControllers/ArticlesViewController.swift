//
//  ArticlesViewController.swift
//  NewsReader
//
//  Created by Yury Beryla on 11/13/19.
//  Copyright © 2019 Yury Beryla. All rights reserved.
//

import UIKit

final class ArticlesViewController: UITableViewController {
    
    // MARK: - Private Properties
    
    let articleReusableViewIdentifier = "ArticleReusableView"
    
    var articlesDataController: ArticlesDataController
    
    var viewModel: ArticlesViewModel {
        
        didSet {
            
            self.refreshView()
        }
    }
    
    // MARK: - Internal Properties
    
    var navigationItemTitle: String?
    
    var selectedChannels: [Channel]?
    
    // MARK: - Lifecycle
    
    required init?(coder: NSCoder) {
        articlesDataController = ArticlesDataController(selectedChannels: nil)
        viewModel = ArticlesViewModel()
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = navigationItemTitle
        articlesDataController = ArticlesDataController(selectedChannels: self.selectedChannels)
        articlesDataController.refetchArticles(completion: { [weak self] in
            self?.tableView.reloadData()
        })
        
        tableView.reloadData()
    }
    
    // MARK: - Private API
    
    private func refreshView() {
        
        self.navigationItem.rightBarButtonItem?.title = viewModel.signOutButtonTitle
    }
    
    private func reloadViewModel() {
        
        viewModel = ArticlesViewModel()
    }
    
    // MARK: - Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let articleViewController = segue.destination as? ArticleViewController,
        let selectedIndexPath = tableView.indexPathForSelectedRow else {
            return
        }
        
        articleViewController.article = articlesDataController.article(at: selectedIndexPath.item)
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
        cell.channelLabel.text = article.channel?.title
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy HH:mm:ss"
        cell.dateLabel.text = dateFormatter.string(from: article.articleDate ?? Date())
        
        var image: UIImage?
        
        DispatchQueue.global().async {
            guard let imageUrlString = article.thumbnailUrlString,
                let imageUrl = URL(string: imageUrlString),
                let imageData = try? Data(contentsOf: imageUrl) else {
                    
                    return
            }
              
            image = UIImage(data: imageData)
            DispatchQueue.main.async {
                
                cell.articleImageView.image = image
            }
        }
        cell.titleLabel.text = article.articleTitle
        
        return cell
    }
    
    // MARK: - TableViewDelegate
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120.0
    }
}
