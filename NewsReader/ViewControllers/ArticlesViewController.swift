//
//  ArticlesViewController.swift
//  NewsReader
//
//  Created by Yury Beryla on 11/13/19.
//  Copyright © 2019 Yury Beryla. All rights reserved.
//

import CoreData
import UIKit

final class ArticlesViewController: UITableViewController, ArticlesDataControllerDelegate {
    
    // MARK: - Private Properties
        
    var articlesDataController: ArticlesDataController?
    
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
        viewModel = ArticlesViewModel()
        
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = navigationItemTitle
        articlesDataController = ArticlesDataController(selectedChannels: self.selectedChannels)
        articlesDataController?.delegate = self
        articlesDataController?.refetchArticles()
        tableView.register(UINib(nibName: ArticleReusableViewModel.reusableIdentifier, bundle: nil), forCellReuseIdentifier: ArticleReusableViewModel.reusableIdentifier)
    }
    
    // MARK: - Private API
    
    private func apply(viewModel: ArticleReusableViewModel, to cell: ArticleReusableView) {
        cell.articleImageView.backgroundColor = viewModel.articleImageViewBackgroundColor
        cell.channelLabel.text = viewModel.channelLabelText
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy HH:mm:ss"
        cell.dateLabel.text = viewModel.dateLabelText
        
        if let imageUrlString = viewModel.articleImageViewImageUrlString,
            let imageUrl = URL(string: imageUrlString) {
            cell.articleImageView.downloadImageFrom(url: imageUrl)
        }
        cell.titleLabel.text = viewModel.titleLabelText
    }
    
    private func refreshView() {
        
        self.navigationItem.rightBarButtonItem?.title = viewModel.signOutButtonTitle
    }
    
    private func reloadViewModel() {
        
        viewModel = ArticlesViewModel()
    }
    
    // MARK: - Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let articleViewController = segue.destination as? ArticleViewController,
            let selectedIndexPath = tableView.indexPathForSelectedRow,
            let article = articlesDataController?.article(at: selectedIndexPath.item) else {
            return
        }
        articleViewController.viewModel = ArticleViewModel(article: article)
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articlesDataController?.articlesCount ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ArticleReusableViewModel.reusableIdentifier, for: indexPath) as? ArticleReusableView,
            let article = articlesDataController?.article(at: indexPath.item) else {
            
            return UITableViewCell()
        }
        let articleReusableViewModel = ArticleReusableViewModel(article: article)
        apply(viewModel: articleReusableViewModel, to: cell)
        
        return cell
    }
        
    // MARK: - TableViewDelegate
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120.0
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let articleViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "ArticleViewController") as? ArticleViewController,
            let selectedIndexPath = tableView.indexPathForSelectedRow,
            let article = articlesDataController?.article(at: selectedIndexPath.item) else {
            return
        }
        articleViewController.viewModel = ArticleViewModel(article: article)
        
        navigationController?.pushViewController(articleViewController, animated: true)
    }
    
    // MARK: - ArticlesDataControllerDelegate
    
    func articlesDidChange() {
        tableView.reloadData()
    }
}
