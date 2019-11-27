//
//  ArticleWebViewController.swift
//  NewsReader
//
//  Created by Yury Beryla on 11/14/19.
//  Copyright © 2019 Yury Beryla. All rights reserved.
//

import UIKit
import WebKit

class ArticleWebViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var webView: WKWebView?
    
    // MARK: - Internal Properties
    
    var articleUrl: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let articleUrl = self.articleUrl else {
            return
        }
        webView?.load(URLRequest(url: articleUrl))
    }
}
