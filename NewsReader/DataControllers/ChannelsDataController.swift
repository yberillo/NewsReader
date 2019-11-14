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
        
//        loadChannels()
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
            
            print(error)
        }
    }
    
    func loadChannels() {
        guard let channelEntity = NSEntityDescription.entity(forEntityName: entityName, in: context) else {
            
            return
        }
        
        let channel1 = NSManagedObject(entity: channelEntity, insertInto: context)
        channel1.setValue("Tut.by", forKey: "title")
        channel1.setValue("https://news.tut.by/rss/index.rss", forKey: "url")
        
        let channel2 = NSManagedObject(entity: channelEntity, insertInto: context)
        channel2.setValue("Lenta.ru", forKey: "title")
        channel2.setValue("https://lenta.ru/rss", forKey: "url")

        do {
            
            try context.save()
        }
        catch let error as NSError {
            
            print(error)
        }
    }
}

extension ChannelsDataController {
    
    enum Channels: String {
        
        case lentaru = "Lenta.ru"

        case tutby = "Tut.by"
    }
}
