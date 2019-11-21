//
//  ArticleViewController.swift
//  NewsReader
//
//  Created by Yury Beryla on 11/14/19.
//  Copyright © 2019 Yury Beryla. All rights reserved.
//

import UIKit

final class ArticleViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var contentViewBottomEqualLinkLabelBottomVerticalSpace: NSLayoutConstraint!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var linkLabel: UILabel!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var textLabel: UILabel!
        
    @IBOutlet weak var titleLabel: UILabel!
    
    // MARK: - Private Properties
    
    private let gestureRecognizer: UITapGestureRecognizer
    
    // MARK: - Internal Properties
    
    var viewModel: ArticleViewModel?
    
    // MARK: - Lifecycle
    
    required init?(coder: NSCoder) {
        gestureRecognizer = UITapGestureRecognizer()
        
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let viewModel = self.viewModel {
            apply(viewModel: viewModel)
        }
        linkLabel.isUserInteractionEnabled = true
        linkLabel.addGestureRecognizer(gestureRecognizer)
        
        gestureRecognizer.addTarget(self, action: #selector(self.gestureRecognizerTap))
    }
    
    override func viewDidLayoutSubviews() {
        scrollView.contentSize.height = linkLabel.frame.maxY + contentViewBottomEqualLinkLabelBottomVerticalSpace.constant
    }
    
    // MARK: - Private API
    
    private func apply(viewModel: ArticleViewModel) {
        dateLabel.text = viewModel.dateLabelText
        
        imageView.backgroundColor = viewModel.imageViewBackgroundColor
        if let imageUrlString = viewModel.imageViewImageUrlString,
            let imageUrl = URL(string: imageUrlString) {
            imageView.downloadImageFrom(url: imageUrl)
        }
        linkLabel.text = viewModel.linkLabelText
        textLabel.text = viewModel.textLabelText
        titleLabel.text = viewModel.titleLabelText
    }
    
    // MARK: - Actions
    
    @objc
    private func gestureRecognizerTap() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        guard let articleWebViewController = storyboard.instantiateViewController(identifier: "ArticleWebViewController") as? ArticleWebViewController,
            let articleUrlString = viewModel?.linkLabelText,
            let articleUrl = URL(string: articleUrlString) else {
            return
        }
        articleWebViewController.articleUrl = articleUrl
        
        self.navigationController?.pushViewController(articleWebViewController, animated: true)
    }
}
