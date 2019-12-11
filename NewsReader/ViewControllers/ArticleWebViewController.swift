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
    
    // MARK: - Internal Properties
    
    var viewModel: ArticleWebViewModel?
    
    // MARK: - Outlets
    
    @IBOutlet weak var webView: WKWebView?
    
    // MARK: - Lifecycle
    
    init(nibName: String, viewModel: ArticleWebViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nibName, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let articleUrl = viewModel?.articleUrl else {
            return
        }
        webView?.load(URLRequest(url: articleUrl))
    }
}
