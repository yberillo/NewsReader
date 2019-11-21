//
//  LoginViewModel.swift
//  NewsReader
//
//  Created by Yury Beryla on 11/12/19.
//  Copyright © 2019 Yury Beryla. All rights reserved.
//

import Foundation

struct LoginViewModel {
    
    // MARK: - Internal Properties
    
    let alertMessageText: String
    
    let alertOkButtonText: String

    let alertTitleText: String
            
    let invalidLabelText: String
    
    let passwordLabelText: String
    
    let registerButtonText: String
    
    let signInButtonText: String
    
    let usernameLabelText: String
    
    // MARK: - Lifecycle
    
    init() {
        alertMessageText = StringsManager.loginViewControllerAlertMessageText
        alertOkButtonText = StringsManager.loginViewControllerAlertOkButtonText
        alertTitleText = StringsManager.loginViewControllerAlertTitleText
        invalidLabelText = StringsManager.loginViewControllerInvalidLabelText
        passwordLabelText = StringsManager.loginViewControllerPasswordLabelText
        registerButtonText = StringsManager.loginViewControllerRegisterButtonText
        signInButtonText = StringsManager.loginViewControllerSignInButtonText
        usernameLabelText = StringsManager.loginViewControllerUsernameLabelText
    }
}
