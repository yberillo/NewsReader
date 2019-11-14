//
//  RSSParserKeys.swift
//  NewsReader
//
//  Created by Yury Beryla on 11/14/19.
//  Copyright © 2019 Yury Beryla. All rights reserved.
//

import Foundation

protocol RSSParserKeys: NSObjectProtocol {
    
    static var author: String { get }
    
    static var content: String { get }
    
    static var description: String { get }
    
    static var enclosure: String { get }
    
    static var item: String { get }
    
    static var link: String { get }
    
    static var pubDate: String { get }
    
    static var title: String { get }
    
    static var url: String { get }
}
