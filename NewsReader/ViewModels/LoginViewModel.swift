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
        
    let invalidLabelText: String
    
    let passwordLabelText: String
    
    let signInButtonText: String
    
    let usernameLabelText: String
    
    // MARK: - Lifecycle
    
    init() {
        invalidLabelText = NSLocalizedString("login.label.invalid", comment: "Username or password is invalid")
        passwordLabelText = NSLocalizedString("login.label.password", comment: "Username")
        signInButtonText = NSLocalizedString("login.button.sign_in", comment: "Sign in")
        usernameLabelText = NSLocalizedString("login.label.username", comment: "Username")
    }
}
