//
//  LoginViewController.swift
//  NewsReader
//
//  Created by Yury Beryla on 11/12/19.
//  Copyright © 2019 Yury Beryla. All rights reserved.
//

import UIKit

protocol LoginViewControllerDelegate: NSObjectProtocol {
    
    func signIn()
}

final class LoginViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var invalidLabel: UILabel?
    
    @IBOutlet weak var loginView: UIView?
    
    @IBOutlet weak var passwordLabel: UILabel?
    
    @IBOutlet weak var passwordTextField: UITextField?
    
    @IBOutlet weak var registerButton: UIButton?
    
    @IBOutlet weak var signInButton: UIButton?
    
    @IBOutlet weak var usernameLabel: UILabel?
    
    @IBOutlet weak var usernameTextField: UITextField?
                
    // MARK: - Internal Properties
    
    weak var delegate: LoginViewControllerDelegate?
        
    var viewModel: LoginViewModel?
    
    // MARK: - Lifecycle
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    init(nibName: String, viewModel: LoginViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nibName, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginView?.layer.cornerRadius = (loginView?.frame.size.height ?? 0.0) / 10.0
                
        refreshView()
    }
    
    // MARK: - Actions
    
    @IBAction func registerButtonTouchUpInside(_ sender: UIButton) {
        guard let username = usernameTextField?.text, let password = passwordTextField?.text else {
            return
        }
        let isUserRegistered = viewModel?.registerUser(with: username, password: password)
        
        if isUserRegistered == true {
            _ = viewModel?.authenticateUser(with: username, password: password)
            self.delegate?.signIn()
        }
        else {
            let alertController = UIAlertController(title: viewModel?.alertTitleText, message: viewModel?.alertMessageText, preferredStyle: .alert)
            let okAction = UIAlertAction(title: viewModel?.alertOkButtonText, style: .cancel, handler: nil)
            
            alertController.addAction(okAction)
            
            AppDelegate.mainCoordinator.presentAlertController(alertController: alertController, from: self)
        }
    }
    
    @IBAction func signInButtonTouchUpInside(_ sender: UIButton) {
        guard let username = usernameTextField?.text, let password = passwordTextField?.text else {
            
            return
        }
        _ = viewModel?.authenticateUser(with: username, password: password)
        
        if viewModel?.usersDataController.currentUser == nil {
            invalidLabel?.isHidden = false
        }
        else {
            invalidLabel?.isHidden = true
            self.delegate?.signIn()
        }
    }
    
    // MARK: - Private API
    
    private func refreshView() {
        guard let viewModel = viewModel else {
            return
        }
        invalidLabel?.text = viewModel.invalidLabelText
        passwordLabel?.text = viewModel.passwordLabelText
        registerButton?.setTitle(viewModel.registerButtonText, for: .normal)
        signInButton?.setTitle(viewModel.signInButtonText, for: .normal)
        usernameLabel?.text = viewModel.usernameLabelText
    }
}
