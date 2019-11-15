//
//  ArticleReusableView.swift
//  NewsReader
//
//  Created by Yury Beryla on 11/13/19.
//  Copyright © 2019 Yury Beryla. All rights reserved.
//

import UIKit

final class ArticleReusableView: UITableViewCell {
    
    // MARK: - Outlets
    
    @IBOutlet weak var articleImageView: UIImageView!
    
    @IBOutlet weak var channelLabel: UILabel!
    
    @IBOutlet weak var dateLabel: UILabel!
        
    @IBOutlet weak var titleLabel: UILabel!
}
