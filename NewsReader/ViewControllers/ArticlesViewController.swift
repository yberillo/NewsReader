//
//  ArticlesViewController.swift
//  NewsReader
//
//  Created by Yury Beryla on 11/13/19.
//  Copyright © 2019 Yury Beryla. All rights reserved.
//

import CoreData
import UIKit

final class ArticlesViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
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
        articlesDataController?.articlesFetchedResultsController.delegate = self
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
        tableViewShouldAnimateCells = false
        refetchTimer = Timer.scheduledTimer(timeInterval: refetchingTimeout, target: self, selector: #selector(timerFired), userInfo: nil, repeats: false)
        articlesDataController?.refetchArticles(completion: { [weak self] in
            refreshControl.endRefreshing()
            self?.refetchTimer.invalidate()
            self?.tableViewShouldAnimateCells = true
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
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let alertMessageText = String(format: viewModel.alertMessageText, articlesDataController?.article(at: indexPath.item)?.articleTitle ?? "")
            let alertController = UIAlertController(title: viewModel.alertTitleText, message: alertMessageText, preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: viewModel.alertCancelButtonTitle, style: .cancel) { (_) in
                alertController.dismiss(animated: true)
            }
            let deleteAction = UIAlertAction(title: viewModel.alertDeleteButtonTitle, style: .destructive) { (_) in
                self.articlesDataController?.deleteArticle(at: indexPath)
            }
            alertController.addAction(cancelAction)
            alertController.addAction(deleteAction)
            
            present(alertController, animated: true)
        }
    }
    
    // MARK: - NSFetchedresultsControllerDelegate
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableViewShouldAnimateCells = false
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
            
        case .delete:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        case .insert:
            if let newIndexPath = newIndexPath {
                tableView.insertRows(at: [newIndexPath], with: .fade)
            }
        case .move:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
            if let newIndexPath = newIndexPath {
                tableView.insertRows(at: [newIndexPath], with: .automatic)
            }
        case .update:
            guard let indexPath = indexPath,
                let cell = tableView.cellForRow(at: indexPath) as? ArticleReusableView,
                let article = articlesDataController?.article(at: indexPath.item) else {
                return
            }
            let viewModel = ArticleReusableViewModel(article: article)
            apply(viewModel: viewModel, to: cell)
            
        @unknown default:
            assertionFailure("Unknown FetchedResultsControllerChangeType")
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableViewShouldAnimateCells = true
        tableView.endUpdates()
    }
}
