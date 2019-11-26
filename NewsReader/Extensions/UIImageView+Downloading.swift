//
//  UIImageView+NewsReader.swift
//  NewsReader
//
//  Created by Yury Beryla on 11/21/19.
//  Copyright © 2019 Yury Beryla. All rights reserved.
//

import UIKit

extension UIImageView {
    func downloadImageFrom(url: URL) {
        DispatchQueue.global().async {
            URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) -> Void in
                DispatchQueue.main.async {
                    if let data = data {
                        self.image = UIImage(data: data)
                        self.backgroundColor = .clear
                    }
                }
            }).resume()
        }
    }
}
