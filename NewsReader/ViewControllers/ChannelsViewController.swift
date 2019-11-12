//
//  ChannelsViewController.swift
//  NewsReader
//
//  Created by Yury Beryla on 11/12/19.
//  Copyright © 2019 Yury Beryla. All rights reserved.
//

import UIKit

class ChannelsViewController: UITableViewController {
    
    // MARK: - Private Properties
    
    let channelsDataController: ChannelsDataController
    
    var viewModel: ChannelsViewModel {
        
        didSet {
            
            self.refreshView()
        }
    }
    
    // MARK: - Lifecycle
    
    required init?(coder: NSCoder) {
        
        channelsDataController = ChannelsDataController()
        viewModel = ChannelsViewModel()
        
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationItem.setHidesBackButton(true, animated: false)
        
        reloadViewModel()
    }
    
    // MARK: - Private API
    
    private func refreshView() {
        
        self.navigationItem.title = viewModel.navigationItemTitle
    }
    
    private func reloadViewModel() {
        
        viewModel = ChannelsViewModel()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return channelsDataController.channelsCount
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChannelReusableView", for: indexPath)
        
        cell.textLabel?.text = channelsDataController.channel(at: indexPath.item)?.title

        return cell
    }
}
