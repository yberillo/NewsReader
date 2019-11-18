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
    
    var selectedChannels:[Channel]?
    
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
        reloadSelectedChannels()
        
        NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name: UIApplication.willResignActiveNotification, object: nil)
    }
    
    // MARK: - Actions
    
    @objc
    func willResignActive() {
        saveSelectedChannels()
    }
    
    @IBAction func nextBarButtonItemTouchUpInside(_ sender: UIBarButtonItem) {
        saveSelectedChannels()
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
        saveSelectedChannels()
        articlesViewController.selectedChannels = getSelectedChannels()
    }
    
    // MARK: - Private API
    
    private func apply(viewModel: ChannelReusableViewModel, to cell: ChannelReusableView) {
        cell.channelSwitch.isOn = viewModel.channelSwitchIsOn
        cell.channelTitleLabel.text = viewModel.channelTitleLabelText
    }
    
    private func getSelectedChannels() -> [Channel] {
        var selectedChannels: [Channel] = []
        for cell in tableView.visibleCells {
            guard let channelCell = cell as? ChannelReusableView else {
                return []
            }
            if channelCell.channelSwitch.isOn {
                guard let indexPath = tableView.indexPath(for: channelCell),
                let channel = channelsDataController.channel(at: indexPath.item) else {
                    return []
                }
                selectedChannels.append(channel)
            }
        }
        return selectedChannels
    }
    
    private func refreshView() {
        self.navigationItem.title = viewModel.navigationItemTitle
        self.navigationItem.leftBarButtonItem?.title = viewModel.signOutButtonText
        self.navigationItem.rightBarButtonItem?.title = viewModel.nextButtonText
    }
    
    private func reloadSelectedChannels() {
        guard let currentUser = usersDataController?.currentUser else {
            return
        }
        selectedChannels = channelsDataController.getSelectedChannels(for: currentUser)
        tableView.reloadData()
    }
    
    private func reloadViewModel() {
        viewModel = ChannelsViewModel()
    }
    
    private func saveSelectedChannels() {
        let selectedChannels = getSelectedChannels()
        guard let currentUser = usersDataController?.currentUser else {
            return
        }
        channelsDataController.save(selectedChannels: selectedChannels, for: currentUser)
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return channelsDataController.channelsCount
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ChannelReusableView", for: indexPath) as? ChannelReusableView,
            let channel = channelsDataController.channel(at: indexPath.item) else {
                return UITableViewCell()
        }
        let channelReusableViewModel = ChannelReusableViewModel(channel: channel, selectedChannels: selectedChannels)
        apply(viewModel: channelReusableViewModel, to: cell)

        return cell
    }
    
    // MARK: - TableViewDelegate
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
}
