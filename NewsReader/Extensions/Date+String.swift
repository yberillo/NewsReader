//
//  Date+String.swift
//  NewsReader
//
//  Created by Yury Beryla on 11/22/19.
//  Copyright © 2019 Yury Beryla. All rights reserved.
//

import Foundation

extension Date {
    var standardDateString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy HH:mm:ss"
        return dateFormatter.string(from: self)
    }
}
