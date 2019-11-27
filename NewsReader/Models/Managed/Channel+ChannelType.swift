//
//  Channel+ChannelType.swift
//  NewsReader
//
//  Created by Yury Beryla on 11/27/19.
//  Copyright © 2019 Yury Beryla. All rights reserved.
//

import Foundation

extension Channel {
    
    enum ChannelType {
        
        case lentaru
        
        case tutby
    }
    
    var type: ChannelType? {
        switch self.title {
            
        case "Lenta.ru":
            return .lentaru
            
        case "Tut.by":
            return .tutby
            
        default:
            return nil
        }
    }
}
