//
//  RSSParser.swift
//  NewsReader
//
//  Created by Yury Beryla on 11/13/19.
//  Copyright © 2019 Yury Beryla. All rights reserved.
//

import Foundation

final class RSSParser: NSObject, XMLParserDelegate {
    
    // MARK: - Private Properties
    
    private var currentData: [String: String]

    private var currentElement: String
    
    private var foundCharacters: String

    private var isHeader: Bool
        
    private var parser: XMLParser
    
    private let rssParseKeys: RSSParserKeys.Type
    
    // MARK: - Internal Properties
    
    var parsedData: [[String: String]]
    
    // MARK: - Lifecycle
    
    init(rssParseKeys: RSSParserKeys.Type) {
        currentData = [:]
        currentElement = ""
        foundCharacters = ""
        isHeader = true
        parsedData = []
        parser = XMLParser()
        self.rssParseKeys = rssParseKeys
        
        super.init()
    }
    
    // MARK: - Internal API
    
    func parseFrom(url: URL, completionHandler: (Bool) -> ()) {
        
        let parser = XMLParser(contentsOf: url)
        parser?.delegate = self
        if let parsed = parser?.parse() {
            
            parsedData.append(currentData)
            completionHandler(parsed)
        }
    }
    
    // MARK: - XMLParserDelegate
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        
        currentElement = elementName
        
        if currentElement == rssParseKeys.item {
            
            if isHeader == false {
                parsedData.append(currentData)
            }
            
            isHeader = false
        }
        
        if isHeader == false {
            
            if currentElement == rssParseKeys.enclosure {
                
                foundCharacters += attributeDict[rssParseKeys.url]!
            }
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        
        if isHeader == false {
            if currentElement == rssParseKeys.author
                || currentElement == rssParseKeys.content
                || currentElement == rssParseKeys.description
                || currentElement == rssParseKeys.item
                || currentElement == rssParseKeys.link
                || currentElement == rssParseKeys.pubDate
                || currentElement == rssParseKeys.title {
                
                foundCharacters += string
            }
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        
        if !foundCharacters.isEmpty {
            
            foundCharacters = foundCharacters.trimmingCharacters(in: .whitespacesAndNewlines)
            currentData[currentElement] = foundCharacters
            foundCharacters = ""
        }
    }
}
