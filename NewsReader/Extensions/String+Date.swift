//
//  String+Date.swift
//  NewsReader
//
//  Created by Yury Beryla on 11/22/19.
//  Copyright © 2019 Yury Beryla. All rights reserved.
//

import Foundation

extension String {
    var dateFromRssDateString: Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E, d MMM yyyy HH:mm:ss Z"
        return dateFormatter.date(from: self) ?? Date()
    }
}
