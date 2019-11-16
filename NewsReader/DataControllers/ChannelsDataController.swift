//
//  ChannelsDataController.swift
//  NewsReader
//
//  Created by Yury Beryla on 11/12/19.
//  Copyright © 2019 Yury Beryla. All rights reserved.
//

import CoreData
import Foundation
import UIKit

final class ChannelsDataController {
    
    // MARK: - Private Properties
    
    private var channels: [Channel]
    
    private var context: NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        return appDelegate.persistentContainer.viewContext
    }
    
    private let entityName = "Channel"
    
    // MARK: - Internal Properties
    
    var channelsCount: Int {
        return channels.count
    }
    
    // MARK: - Lifecycle
    
    init() {
        channels = []
        fetchChannels()
        
        if channelsCount == 0 {
            loadChannels()
            fetchChannels()
        }
    }
    
    // MARK: - Internal API
    
    func channel(at index: Int) -> Channel? {
        if index < channels.count {
            return channels[index]
        }
        else {
            return nil
        }
    }
    
    func getSelectedChannels(for user: User) -> [Channel] {
        guard let channels = user.channels?.sortedArray(using: []) as? [Channel] else {
            return []
        }
        return channels
    }
    
    func save(selectedChannels: [Channel], for user: User) {
        user.channels = nil
        user.addToChannels(NSSet(array: selectedChannels))
        do {
            try context.save()
        }
        catch let error as NSError {
            ErrorManager.handle(error: error)
        }
    }
    
    // MARK: - Private API
    
    private func fetchChannels() {
        let channelFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: self.entityName)
                    
        do {
            guard let channelResult = try self.context.fetch(channelFetchRequest) as? [Channel] else {
                return
            }
            for channel in channelResult {
                self.channels.append(channel)
            }
        }
        catch let error as NSError {
            ErrorManager.handle(error: error)
        }
    }
    
    private func loadChannels() {
        let channel1 = Channel(context: context)
        channel1.setValue("Tut.by", forKey: "title")
        channel1.setValue("https://news.tut.by/rss/index.rss", forKey: "url")
        
        let channel2 = Channel(context: context)
        channel2.setValue("Lenta.ru", forKey: "title")
        channel2.setValue("https://lenta.ru/rss", forKey: "url")

        do {
            try context.save()
        }
        catch let error as NSError {
            ErrorManager.handle(error: error)
        }
    }
}

extension ChannelsDataController {
    
    enum Channels: String {
        
        case lentaru = "Lenta.ru"

        case tutby = "Tut.by"
    }
}
