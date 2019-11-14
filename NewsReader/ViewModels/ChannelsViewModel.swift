//
//  ChannelsViewModel.swift
//  NewsReader
//
//  Created by Yury Beryla on 11/12/19.
//  Copyright © 2019 Yury Beryla. All rights reserved.
//

import Foundation

struct ChannelsViewModel {
    
    // MARK: - Internal Properties
    
    let navigationItemTitle: String
    
    let signOutButtonText: String
    
    // MARK: - Lifecycle
    
    init() {
        navigationItemTitle = NSLocalizedString("channels.label.title", comment: "Channels")
        signOutButtonText = NSLocalizedString("channels.button.sign_out", comment: "Sign out")
    }
}
