//
//  ChannelReusableViewModel.swift
//  NewsReader
//
//  Created by Yury Beryla on 11/18/19.
//  Copyright © 2019 Yury Beryla. All rights reserved.
//

import UIKit

final class ChannelReusableViewModel {
    
    // MARK: - Internal Properties
    
    let channelSwitchIsOn: Bool

    let channelTitleLabelText: String?
    
    // MARK: - Internal Static Properties
    
    static let reusableIdentifier = "ChannelReusableView"
        
    // MARK: - Lifecycle
    
    init(channel: Channel, selectedChannels: [Channel]?) {
        channelSwitchIsOn = selectedChannels?.contains(channel) ?? false
        channelTitleLabelText = channel.title
    }
}
