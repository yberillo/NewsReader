//
//  ChannelsViewModel.swift
//  NewsReader
//
//  Created by Yury Beryla on 11/12/19.
//  Copyright © 2019 Yury Beryla. All rights reserved.
//

import Foundation

struct ChannelsViewModel {
    
    // MARK: - DataControllers
    
    let channelsDataController: ChannelsDataController

    let usersDataController: UsersDataController
    
    // MARK: - Internal Properties
    
    var channelsCount: Int {
        return channelsDataController.channelsCount
    }
    
    let navigationItemTitle: String
    
    let nextButtonText: String
    
    let signOutButtonText: String
    
    // MARK: - Lifecycle
    
    init(channelsDataController: ChannelsDataController, usersDataController: UsersDataController) {
        self.channelsDataController = channelsDataController
        self.usersDataController = usersDataController
        navigationItemTitle = StringsManager.channelsViewControllerNavigationItemTitle
        nextButtonText = StringsManager.channelsViewControllerNextButtonText
        signOutButtonText = StringsManager.articlesViewControllerSignOutButtonTitle
    }
    
    // MARK: - Internal Properties
    
    func channel(at index: Int) -> Channel? {
        return channelsDataController.channel(at: index)
    }
    
    func getSelectedChannels(for user: User) -> [Channel]? {
        return channelsDataController.getSelectedChannels(for: user)
    }
    
    func save(selectedChannels:[Channel], for user: User) {
        channelsDataController.save(selectedChannels: selectedChannels, for: user)
    }
    
    func signOut() {
        usersDataController.signOut()
    }
}
