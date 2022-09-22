//
//  WelcomeViewController.swift
//  Grinder
//
//  Created by Beavean on 21.09.2022.
//

import UIKit
import ProgressHUD

class WelcomeViewController: UIViewController {
    
    //MARK: - IBOutlets

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    //MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .dark
        setupBackgroundTouch()
    }
    
    //MARK: - IBActions
    
    @IBAction func forgotPasswordButtonPressed(_ sender: Any) {
        if emailTextField.text != "", let email = emailTextField.text {
            FirebaseUser.resetPasswordFor(email: email) { error in
                if let error = error {
                    ProgressHUD.showError(error.localizedDescription)
                } else {
                    ProgressHUD.showSucceed("Please check your email!")
                }
            }
        } else {
            ProgressHUD.showError("Please enter your email address")
        }
    }
    
    @IBAction func loginButtonPressed(_ sender: Any) {
        if emailTextField.text != "" && passwordTextField.text != "" {
            ProgressHUD.show()
            guard let email = emailTextField.text, let password = passwordTextField.text else { return }
            FirebaseUser.loginUserWith(email: email, password: password) { error, isEmailVerified in
                if let error = error {
                    ProgressHUD.showError(error.localizedDescription)
                } else if isEmailVerified {
                    ProgressHUD.dismiss()
                    self.enterApplication()
                } else {
                    ProgressHUD.showError("Please verify your email")
                }
            }
        } else {
            ProgressHUD.showError("All fields are required")
        }
    }
    
    //MARK: - Setup
    
    private func setupBackgroundTouch() {
        backgroundImageView.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(backgroundTap))
        backgroundImageView.addGestureRecognizer(tapGesture)
    }
    
    //MARK: - Selectors
    
    @objc func backgroundTap() {
        dismissKeyboard()
    }
    
    //MARK: - Helpers
    
    private func dismissKeyboard() {
        self.view.endEditing(false)
    }
    
    //MARK: - Navigation
    
    private func enterApplication() {
        guard let mainView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: K.mainViewIdentifier) as? UITabBarController else { return }
        mainView.modalPresentationStyle = .fullScreen
        self.present(mainView, animated: true)
    }
}

