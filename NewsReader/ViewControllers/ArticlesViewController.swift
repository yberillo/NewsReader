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
    
    var maxDisplayedCellIndexPath: IndexPath
    
    let refetchingTimeout = 5.0
    
    var refetchTimer = Timer()
    
    var tableViewShouldAnimateCells: Bool
            
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
        maxDisplayedCellIndexPath = IndexPath(item: -1, section: 0)
        tableViewShouldAnimateCells = false
        viewModel = ArticlesViewModel()
        
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = navigationItemTitle
        articlesDataController = ArticlesDataController(selectedChannels: self.selectedChannels)
        articlesDataController?.delegate = self
        articlesDataController?.refetchArticles()
                
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshTableView(_:)), for: .valueChanged)
        tableView.refreshControl = refreshControl
        tableView.register(UINib(nibName: ArticleReusableViewModel.reusableIdentifier, bundle: nil), forCellReuseIdentifier: ArticleReusableViewModel.reusableIdentifier)
    }
    
    // MARK: - Private API
    
    fileprivate static func animate(cell: UITableViewCell, delay: Double? = nil) {
        let originalCellOriginX = cell.frame.origin.x
        cell.frame.origin.x = cell.bounds.width
        let delay = delay ?? 0.0
        UIView.animate(withDuration: 0.5, delay: delay, options: [], animations: {
            cell.frame.origin.x = originalCellOriginX
        })
    }
    
    private func apply(viewModel: ArticleReusableViewModel, to cell: ArticleReusableView) {
        cell.articleImageView.backgroundColor = viewModel.articleImageViewBackgroundColor
        cell.channelLabel.text = viewModel.channelLabelText
        
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
    
    // MARK: - Actions
    
    @objc
    func refreshTableView(_ refreshControl: UIRefreshControl) {
        refetchTimer = Timer.scheduledTimer(timeInterval: refetchingTimeout, target: self, selector: #selector(timerFired), userInfo: nil, repeats: false)
        articlesDataController?.refetchArticles(completion: { [weak self] in
            refreshControl.endRefreshing()
            self?.refetchTimer.invalidate()
        })
    }
    
    @objc
    func timerFired() {
        refetchTimer.invalidate()
        tableView.refreshControl?.endRefreshing()
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
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.item > maxDisplayedCellIndexPath.item {
            maxDisplayedCellIndexPath = indexPath
            if tableViewShouldAnimateCells {
                ArticlesViewController.animate(cell: cell)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.item < maxDisplayedCellIndexPath.item {
            maxDisplayedCellIndexPath = indexPath
        }
    }
    
    // MARK: - ArticlesDataControllerDelegate
    
    func articlesDidChange() {
        tableViewShouldAnimateCells = true
        tableView.reloadDataWithAnimation()
    }
}

private extension UITableView {
    
    func reloadDataWithAnimation() {
        self.reloadData()
        
        var delay = 0
        let cells = self.visibleCells
        for cell in cells {
            ArticlesViewController.animate(cell: cell, delay: 0.1 * Double(delay))

            delay += 1
        }
    }
}
