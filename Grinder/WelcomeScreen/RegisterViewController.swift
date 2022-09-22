//
//  RegisterViewController.swift
//  Grinder
//
//  Created by Beavean on 21.09.2022.
//

import UIKit
import ProgressHUD

class RegisterViewController: UIViewController {
    
    //MARK: - IBOutlets
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var genderSegmentedControl: UISegmentedControl!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    //MARK: - Variables
    
    var isMale = true
    var birthDate: String?
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .dark
        setupBackgroundTouch()
    }
    
    //MARK: - IBActions
    
    @IBAction func backButtonPressed(_ sender: Any) {
        self.dismiss(animated: true)
        
    }
    
    @IBAction func registerButtonPressed(_ sender: Any) {
        if isTextDataInputed() {
            if passwordTextField.text! == confirmPasswordTextField.text! {
                registerUser()
            } else {
                ProgressHUD.showError("Passwords do not match")
            }
        } else {
            ProgressHUD.showError("All fields are required")
        }
    }
    
    @IBAction func loginButtonPressed(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func genderSegmentedControlChanged(_ sender: UISegmentedControl) {
        isMale = sender.selectedSegmentIndex == 0 ? true : false
    }
    
    //MARK: - Setup
    
    private func setupBackgroundTouch() {
        backgroundImageView.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(backgroundTap))
        backgroundImageView.addGestureRecognizer(tapGesture)
    }
    
    //MARK: - Selectors
    
    @objc func handleDatePicker() {
        birthDate = datePicker.date.getStringFromDate()
    }
    
    @objc func backgroundTap() {
        dismissKeyboard()
    }
    
    @objc func dismissKeyboard() {
        self.view.endEditing(false)
    }
    
    //MARK: - Helpers
    
    private func isTextDataInputed() -> Bool {
        return usernameTextField.text != ""
        && emailTextField.text != ""
        && cityTextField.text != ""
        && passwordTextField.text != ""
        && confirmPasswordTextField.text != ""
    }
    
    private func registerUser() {
        ProgressHUD.show()
        FirebaseUser.registerUserWith(email: emailTextField.text!, password: passwordTextField.text!, username: usernameTextField.text!, city: cityTextField.text!, isMale: isMale, dateOfBirth: datePicker.date) { error in
            if let error = error {
                ProgressHUD.showError(error.localizedDescription)
            } else {
                ProgressHUD.showSuccess("Verification email sent")
                self.dismiss(animated: true)
            }
        }
    }
}
