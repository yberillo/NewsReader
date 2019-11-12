//
//  LoginViewController.swift
//  NewsReader
//
//  Created by Yury Beryla on 11/12/19.
//  Copyright © 2019 Yury Beryla. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var invalidLabel: UILabel!
    
    @IBOutlet weak var loginView: UIView!
    
    @IBOutlet weak var passwordLabel: UILabel!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var signInButton: UIButton!
    
    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet weak var usernameTextField: UITextField!
    
    // MARK: - Private Properties
    
    private var user: User?
    
    private let usersDataController: UsersDataController
    
    private var viewModel: LoginViewModel {
        
        didSet {
            
            refreshView()
        }
    }
    
    // MARK: - Lifecycle
    
    required init?(coder: NSCoder) {
        usersDataController = UsersDataController()
        viewModel = LoginViewModel()
        
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginView.layer.cornerRadius = loginView.frame.size.height / 10.0
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        refreshView()
    }
    
    // MARK: - Actions
    
    @IBAction func signInButtonTouchUpInside(_ sender: UIButton) {
        guard let username = usernameTextField.text, let password = passwordTextField.text else {
            
            return
        }
        user = usersDataController.authenticateUser(with: username, password: password)
        
        if user == nil {
            
            invalidLabel.isHidden = false
        }
        else {
            
            invalidLabel.isHidden = true
            
            if let channelsViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "ChannelsViewController") as? ChannelsViewController {

                self.navigationController?.pushViewController(channelsViewController, animated: true)
                self.navigationController?.viewControllers.remove(at: 0)
            }
        }
    }
    
    // MARK: - Private API
    
    private func refreshView() {
        invalidLabel.text = viewModel.invalidLabelText
        passwordLabel.text = viewModel.passwordLabelText
        signInButton.setTitle(viewModel.signInButtonText, for: .normal)
        usernameLabel.text = viewModel.usernameLabelText
    }
    
    private func reloadViewModel() {
        viewModel = LoginViewModel()
    }
}
