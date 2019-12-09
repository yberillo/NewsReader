//
//  ChannelsViewController.swift
//  NewsReader
//
//  Created by Yury Beryla on 11/12/19.
//  Copyright © 2019 Yury Beryla. All rights reserved.
//

import CoreData
import UIKit

protocol ChannelsViewControllerDelegate: NSObjectProtocol {
    
    func signOut()
}

final class ChannelsViewController: UITableViewController {
    
    // MARK: - Private Properties
        
    var selectedChannels:[Channel]?
    
    var viewModel: ChannelsViewModel?
    
    // MARK: - Internal Properties
    
    weak var delegate: ChannelsViewControllerDelegate?
        
    // MARK: - Lifecycle
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshView()
        reloadSelectedChannels()
        
        tableView.register(UINib(nibName: ChannelReusableViewModel.reusableIdentifier, bundle: nil), forCellReuseIdentifier: ChannelReusableViewModel.reusableIdentifier)
        
        NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name: UIApplication.willResignActiveNotification, object: nil)
    }
    
    // MARK: - Actions
    
    @objc
    func willResignActive() {
        saveSelectedChannels()
    }
    
    @IBAction func nextBarButtonItemTouchUpInside(_ sender: UIBarButtonItem) {
        saveSelectedChannels()
        let selectedChannels = getSelectedChannels()
        AppDelegate.mainCoordinator.pushArticlesViewController(selectedChannels: selectedChannels, channelsDataController: self.viewModel?.channelsDataController ?? ChannelsDataController())
    }
    @IBAction func signOutBarButtonItemTouchUpInside(_ sender: UIBarButtonItem) {
        viewModel?.signOut()
        delegate?.signOut()
    }
    
    // MARK: - Private API
    
    private func apply(viewModel: ChannelReusableViewModel, to cell: ChannelReusableView) {
        cell.channelSwitch?.isOn = viewModel.channelSwitchIsOn
        cell.channelTitleLabel?.text = viewModel.channelTitleLabelText
    }
    
    private func getSelectedChannels() -> [Channel] {
        var selectedChannels: [Channel] = []
        for cell in tableView.visibleCells {
            guard let channelCell = cell as? ChannelReusableView, let channelSwitch = channelCell.channelSwitch else {
                return []
            }
            if channelSwitch.isOn {
                guard let indexPath = tableView.indexPath(for: channelCell),
                    let channel = viewModel?.channel(at: indexPath.item) else {
                    return []
                }
                selectedChannels.append(channel)
            }
        }
        return selectedChannels
    }
    
    private func refreshView() {
        self.navigationItem.title = viewModel?.navigationItemTitle
        self.navigationItem.leftBarButtonItem?.title = viewModel?.signOutButtonText
        self.navigationItem.rightBarButtonItem?.title = viewModel?.nextButtonText
    }
    
    private func reloadSelectedChannels() {
        guard let usersDataController = viewModel?.usersDataController, let currentUser = usersDataController.currentUser else {
            return
        }
        selectedChannels = viewModel?.getSelectedChannels(for: currentUser)
        tableView.reloadData()
    }
    
    private func saveSelectedChannels() {
        let selectedChannels = getSelectedChannels()
        guard let usersDataController = viewModel?.usersDataController, let currentUser = usersDataController.currentUser else {
            return
        }
        viewModel?.save(selectedChannels: selectedChannels, for: currentUser)
    }

    // MARK: - UITableViewDataSource

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.channelsCount ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ChannelReusableViewModel.reusableIdentifier, for: indexPath) as? ChannelReusableView,
            let channel = viewModel?.channel(at: indexPath.item) else {
                return UITableViewCell()
        }
        let channelReusableViewModel = ChannelReusableViewModel(channel: channel, selectedChannels: selectedChannels)
        apply(viewModel: channelReusableViewModel, to: cell)

        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
}
