//
//  ChannelsViewController.swift
//  NewsReader
//
//  Created by Yury Beryla on 11/12/19.
//  Copyright © 2019 Yury Beryla. All rights reserved.
//

import UIKit

protocol ChannelsViewControllerDelegate: NSObjectProtocol {
    
    func signOut()
}

final class ChannelsViewController: UITableViewController {
    
    // MARK: - Private Properties
    
    let channelsDataController: ChannelsDataController
    
    var viewModel: ChannelsViewModel {
        
        didSet {
            
            self.refreshView()
        }
    }
    
    // MARK: - Internal Properties
    
    weak var delegate: ChannelsViewControllerDelegate?
    
    var usersDataController: UsersDataController?
    
    // MARK: - Lifecycle
    
    required init?(coder: NSCoder) {
        
        channelsDataController = ChannelsDataController()
        viewModel = ChannelsViewModel()
        
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        reloadViewModel()
    }
    
    // MARK: - Actions
    
    @IBAction func nextBarButtonItemTouchUpInside(_ sender: UIBarButtonItem) {
        // TODO: Show articles
    }
    @IBAction func signOutBarButtonItemTouchUpInside(_ sender: UIBarButtonItem) {
        
        usersDataController?.signOut()
        delegate?.signOut()
    }
    
    // MARK: - Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let articlesViewController = segue.destination as? ArticlesViewController else {
            
            return
        }
//        articlesViewController.navigationItemTitle = channelsDataController.channel(at: selectedIndex)?.title
        articlesViewController.selectedChannels = []
        
        for cell in tableView.visibleCells {
            guard let channelCell = cell as? ChannelReusableView else {
                return
            }
            if channelCell.channelSwitch.isOn {
                guard let indexPath = tableView.indexPath(for: channelCell),
                let channel = channelsDataController.channel(at: indexPath.item) else {
                    return
                }
                articlesViewController.selectedChannels?.append(channel)
            }
        }
        
//        for indexPath in indexPathsForSelectedRows {
//            if let channel = channelsDataController.channel(at: indexPath.item) {
//                articlesViewController.selectedChannels?.append(channel)
//            }
//        }
    }
    
    // MARK: - Private API
    
    private func refreshView() {
        
        self.navigationItem.title = viewModel.navigationItemTitle
        self.navigationItem.leftBarButtonItem?.title = viewModel.signOutButtonText
        self.navigationItem.rightBarButtonItem?.title = viewModel.nextButtonText
    }
    
    private func reloadViewModel() {
        
        viewModel = ChannelsViewModel()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return channelsDataController.channelsCount
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ChannelReusableView", for: indexPath) as? ChannelReusableView else {
            return UITableViewCell()
        }
        
        cell.channelTitleLabel.text = channelsDataController.channel(at: indexPath.item)?.title

        return cell
    }
    
    // MARK: - TableViewDelegate
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
}
