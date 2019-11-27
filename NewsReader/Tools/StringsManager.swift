//
//  StringsManager.swift
//  NewsReader
//
//  Created by Yury Beryla on 11/21/19.
//  Copyright © 2019 Yury Beryla. All rights reserved.
//

import Foundation

final class StringsManager {
    
    // MARK: - ArticlesViewController
    
    static let articlesViewControllerAlertCancel = NSLocalizedString("articles.alert.cancel", comment: "Cancel")
    
    static let articlesViewControllerAlertDelete = NSLocalizedString("articles.alert.delete", comment: "DELETE")

    static let articlesViewControllerAlertMessage = NSLocalizedString("articles.alert.message", comment: "Are you shure you want detete %@?")
        
    static let articlesViewControllerAlertTitle = NSLocalizedString("articles.alert.title", comment: "Warning")

    static let articlesViewControllerSignOutButtonTitle = NSLocalizedString("articles.button.sign_out", comment: "Sign out")
    
    // MARK: - ChannelsViewController
    
    static let channelsViewControllerNavigationItemTitle = NSLocalizedString("channels.label.title", comment: "Channels")
    
    static let channelsViewControllerNextButtonText = NSLocalizedString("channels.button.next", comment: "Next")
        
    // MARK: - LoginViewController
    
    static let loginViewControllerAlertMessageText = NSLocalizedString("login.label.user_exists", comment: "User with this username already exists")
    
    static let loginViewControllerAlertOkButtonText = NSLocalizedString("login.button.ok", comment: "OK")
    
    static let loginViewControllerAlertTitleText = NSLocalizedString("login.label.registration_failed", comment: "Registration failed")
    
    static let loginViewControllerInvalidLabelText = NSLocalizedString("login.label.invalid", comment: "Username or password is invalid")
    
    static let loginViewControllerPasswordLabelText = NSLocalizedString("login.label.password", comment: "Password")
    
    static let loginViewControllerRegisterButtonText = NSLocalizedString("login.button.register", comment: "Register")
    
    static let loginViewControllerSignInButtonText = NSLocalizedString("login.button.sign_in", comment: "Sign in")
    
    static let loginViewControllerUsernameLabelText = NSLocalizedString("login.label.username", comment: "Username")
}
