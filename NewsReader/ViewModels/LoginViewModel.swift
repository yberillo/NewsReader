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
        alertMessageText = NSLocalizedString("login.label.user_exists", comment: "User with this username already exists")
        alertOkButtonText = NSLocalizedString("login.button.ok", comment: "OK")
        alertTitleText = NSLocalizedString("login.label.registration_failed", comment: "Registration failed")
        invalidLabelText = NSLocalizedString("login.label.invalid", comment: "Username or password is invalid")
        passwordLabelText = NSLocalizedString("login.label.password", comment: "Username")
        registerButtonText = NSLocalizedString("login.button.register", comment: "Register")
        signInButtonText = NSLocalizedString("login.button.sign_in", comment: "Sign in")
        usernameLabelText = NSLocalizedString("login.label.username", comment: "Username")
    }
}
