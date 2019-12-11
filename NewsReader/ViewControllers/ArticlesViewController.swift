//
//  ArticlesViewController.swift
//  NewsReader
//
//  Created by Yury Beryla on 11/13/19.
//  Copyright © 2019 Yury Beryla. All rights reserved.
//

import CoreData
import UIKit

final class ArticlesViewController: UITableViewController, NSFetchedResultsControllerDelegate, UIPickerViewDataSource,UIPickerViewDelegate {
    
    // MARK: - Private Properties
    
    var filterAllText: String?
    
    var filterBarButtonItem = UIBarButtonItem()
    
    let filterHiddenTextField = UITextField()
    
    let filterPickerView = UIPickerView()
            
    var maxDisplayedCellIndexPath: IndexPath = IndexPath(item: -1, section: 0)
    
    var maxVisibleCellsCount: Int = 0
    
    let refetchingTimeout = 5.0
    
    var refetchTimer = Timer()
        
    let tableViewRowHeight: CGFloat = 120.0
    
    var tableViewShouldAnimateCells: Bool = false
            
    var viewModel: ArticlesViewModel?
    
    // MARK: - Internal Properties
    
    var navigationItemTitle: String?
        
    // MARK: - Lifecycle
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    init(nibName: String, viewModel: ArticlesViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nibName, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        filterAllText = viewModel?.filterAllText
        navigationItem.title = navigationItemTitle
        viewModel?.refetchArticles()
        maxVisibleCellsCount = Int(tableView.frame.height / tableViewRowHeight)
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshTableView(_:)), for: .valueChanged)
        setUpFilter()
        view.addSubview(filterHiddenTextField)
        filterBarButtonItem = UIBarButtonItem(title: filterAllText, style: .plain, target: self, action: #selector(self.filterBarButtonItemTouchUpInside(_:)))
        navigationItem.setRightBarButton(filterBarButtonItem, animated: false)
        tableView.refreshControl = refreshControl
        tableView.register(UINib(nibName: ArticleReusableViewModel.reusableIdentifier, bundle: nil), forCellReuseIdentifier: ArticleReusableViewModel.reusableIdentifier)
        
        refreshView()
    }
    
    // MARK: - Private API
    
    private func animate(cell: UITableViewCell) {
        let originalCellOriginX = cell.frame.origin.x
        cell.frame.origin.x = cell.bounds.width
        UIView.animate(withDuration: 0.3, animations: {
            cell.frame.origin.x = originalCellOriginX
        })
    }
    
    private func apply(viewModel: ArticleReusableViewModel, to cell: ArticleReusableView) {
        cell.articleImageView?.backgroundColor = viewModel.articleImageViewBackgroundColor
        cell.channelLabel?.text = viewModel.channelLabelText
        
        cell.dateLabel?.text = viewModel.dateLabelText
        
        if let imageUrlString = viewModel.articleImageViewImageUrlString,
            let imageUrl = URL(string: imageUrlString) {
            cell.articleImageView?.downloadImageFrom(url: imageUrl)
        }
        cell.titleLabel?.text = viewModel.titleLabelText
    }
    
    private func refreshView() {
        navigationItem.leftBarButtonItem?.title = viewModel?.signOutButtonTitle
        filterAllText = viewModel?.filterAllText
    }
    
    private func setUpFilter() {
        filterPickerView.dataSource = self
        filterPickerView.delegate = self
        filterHiddenTextField.frame = CGRect(origin: .zero, size: .zero)
        filterHiddenTextField.isHidden = true
        filterHiddenTextField.inputView = filterPickerView
        
        let toolBar = UIToolbar(frame: CGRect(origin: .zero, size: CGSize(width: tableView.frame.width, height: 0.0)))
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.sizeToFit()

        let cancelButton = UIBarButtonItem(title: viewModel?.filterCancelButtonTitle, style: .plain, target: self, action: #selector(filterCancelButtonTouchUpInside))
        let doneButton = UIBarButtonItem(title: viewModel?.filterDoneButtonTitle, style: .done, target: self, action: #selector(filterDoneButtonTouchUpInside))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)

        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true

        filterHiddenTextField.inputAccessoryView = toolBar
    }
    
    // MARK: - Actions
    
    @IBAction func filterBarButtonItemTouchUpInside(_ sender: UIBarButtonItem) {
        filterHiddenTextField.becomeFirstResponder()
    }
    
    @objc
    func filterCancelButtonTouchUpInside() {
        filterHiddenTextField.resignFirstResponder()
    }
    
    @objc
    func filterDoneButtonTouchUpInside() {
        filterBarButtonItem.title = viewModel?.filterSelectedChannel != nil ? viewModel?.filterSelectedChannel?.title : filterAllText
        filterHiddenTextField.resignFirstResponder()
        
        var filterChannels: [Channel]?
        if let filterSelectedChannel = viewModel?.filterSelectedChannel {
            filterChannels = [filterSelectedChannel]
        }
        else {
            filterChannels = viewModel?.articlesDataController.selectedChannels
        }
        viewModel?.fetchArticles(of: filterChannels) { [weak self] in
            self?.tableView.reloadData()
        }
    }
    
    @objc
    func refreshTableView(_ refreshControl: UIRefreshControl) {
        tableViewShouldAnimateCells = false
        refetchTimer = Timer.scheduledTimer(timeInterval: refetchingTimeout, target: self, selector: #selector(timerFired), userInfo: nil, repeats: false)
        viewModel?.refetchArticles(completion: { [weak self] in
            refreshControl.endRefreshing()
            self?.refetchTimer.invalidate()
        })
    }
    
    @objc
    func timerFired() {
        refetchTimer.invalidate()
        tableView.refreshControl?.endRefreshing()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.articlesCount ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ArticleReusableViewModel.reusableIdentifier, for: indexPath) as? ArticleReusableView,
            let article = viewModel?.article(at: indexPath.item) else {
            
            return UITableViewCell()
        }
        let articleReusableViewModel = ArticleReusableViewModel(article: article)
        apply(viewModel: articleReusableViewModel, to: cell)
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableViewRowHeight
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        AppDelegate.mainCoordinator.pushViewController(.article, data: [.article: viewModel?.article(at: indexPath.item) as Any])
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.item > maxDisplayedCellIndexPath.item {
            maxDisplayedCellIndexPath = indexPath
            if tableViewShouldAnimateCells {
                animate(cell: cell)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.item < maxDisplayedCellIndexPath.item && indexPath.item >= maxVisibleCellsCount - 1 {
            maxDisplayedCellIndexPath = indexPath
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let alertMessageText = String(format: viewModel?.alertMessageText ?? "", viewModel?.article(at: indexPath.item)?.articleTitle ?? "")
            let alertController = UIAlertController(title: viewModel?.alertTitleText, message: alertMessageText, preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: viewModel?.alertCancelButtonTitle, style: .cancel) { (_) in
                alertController.dismiss(animated: true)
            }
            let deleteAction = UIAlertAction(title: viewModel?.alertDeleteButtonTitle, style: .destructive) { (_) in
                self.viewModel?.deleteArticle(at: indexPath.item)
            }
            alertController.addAction(cancelAction)
            alertController.addAction(deleteAction)
            
            AppDelegate.mainCoordinator.presentAlertController(alertController: alertController, from: self)
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
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            if let newIndexPath = newIndexPath {
                tableView.insertRows(at: [newIndexPath], with: .fade)
            }
        case .update:
            guard let indexPath = indexPath,
                let cell = tableView.cellForRow(at: indexPath) as? ArticleReusableView,
                let article = viewModel?.article(at: indexPath.item) else {
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
    
    // MARK: - UIPickerViewDataSource
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return (viewModel?.articlesDataController.selectedChannels?.count ?? 0) + 1
    }
    
    // MARK: - UIPickerViewDelegate
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if row == 0 {
            return filterAllText
        }
        else {
            return viewModel?.articlesDataController.selectedChannels?[row - 1].title
        }
    }
    
    internal func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if row == 0 {
            viewModel?.filterSelectedChannel = nil
            filterHiddenTextField.text = filterAllText
        }
        else {
            let currentFilterSelectedChannel = viewModel?.articlesDataController.selectedChannels?[row - 1]
            viewModel?.filterSelectedChannel = currentFilterSelectedChannel
            filterHiddenTextField.text = viewModel?.filterSelectedChannel?.title
        }
    }
}
