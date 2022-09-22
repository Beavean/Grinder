//
//  ProfileTableViewController.swift
//  Grinder
//
//  Created by Beavean on 22.09.2022.
//

import UIKit

class ProfileTableViewController: UITableViewController {
    
    //MARK: - IBOutlets
    
    @IBOutlet weak var aboutMeBackgroundView: UIView!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var profileCellBackgroundView: UIView!
    @IBOutlet weak var nameAgeLabel: UILabel!
    @IBOutlet weak var cityCountryLabel: UILabel!
    @IBOutlet weak var aboutMeTextView: UITextView!
    @IBOutlet weak var jobTextField: UITextField!
    @IBOutlet weak var professionTextField: UITextField!
    @IBOutlet weak var genderTextField: UITextField!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var countryTextField: UITextField!
    @IBOutlet weak var heightTextField: UITextField!
    @IBOutlet weak var lookingForTextField: UITextField!
    
    //MARK: - Variables
    
    var editingMode = false {
        didSet {
            updateEditingMode()
            editingMode ? showKeyboard() : hideKeyboard()
            showSaveButton()
            loadUserData()
        }
    }
    
    var avatarImage: UIImage?
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackgrounds()
        if FirebaseUser.currentUser() != nil {
            loadUserData()
            updateEditingMode()
        }
        overrideUserInterfaceStyle = .light
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    //MARK: - IBActions
    
    @IBAction func settingsButtonPressed(_ sender: UIButton) {
        showEditOptions()
    }
    
    @IBAction func cameraButtonPressed(_ sender: UIButton) {
        showPictureOptions()
    }
    
    @IBAction func editButtonPressed(_ sender: UIButton) {
        editingMode.toggle()
    }
    
    //MARK: - Selectors
    
    @objc func editUserData() {
        guard let user = FirebaseUser.currentUser() else { return }
        user.about = aboutMeTextView.text
        user.jobTitle = jobTextField.text ?? ""
        user.profession = professionTextField.text ?? ""
        user.isMale = genderTextField.text == "Male"
        user.city = cityTextField.text ?? ""
        user.country = countryTextField.text ?? ""
        user.lookingFor = lookingForTextField.text ?? ""
        user.height = Double(heightTextField.text ?? "0") ?? 0.0
        if let avatarImage = avatarImage {
            
            saveUserData(user: user)
        } else {
            saveUserData(user: user)
        }
        editingMode = false
        showSaveButton()
    }
    
    //MARK: - Setup
    
    private func setupBackgrounds() {
        profileCellBackgroundView.clipsToBounds = true
        profileCellBackgroundView.layer.cornerRadius = profileCellBackgroundView.frame.height * 0.1
        profileCellBackgroundView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        aboutMeBackgroundView.layer.cornerRadius = 10
    }
    
    private func showSaveButton() {
        let saveButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(editUserData))
        navigationItem.rightBarButtonItem = editingMode ? saveButton : nil
    }
    
    //MARK: - Helpers
    
    private func loadUserData() {
        guard let currentUser = FirebaseUser.currentUser() else { return }
        nameAgeLabel.text = currentUser.username + ", " + "\(abs(currentUser.dateOfBirth.interval(ofComponent: .year, fromDate: Date())))"
        cityCountryLabel.text = currentUser.country + ", " + currentUser.city
        aboutMeTextView.text = currentUser.about.isEmpty ? "Some information about me..." : currentUser.about
        jobTextField.text = currentUser.jobTitle
        professionTextField.text = currentUser.profession
        genderTextField.text = currentUser.isMale ? "Male" : "Female"
        cityTextField.text = currentUser.city
        countryTextField.text = currentUser.country
        heightTextField.text = "\(currentUser.height)"
        lookingForTextField.text = currentUser.lookingFor
        avatarImageView.image = UIImage(named: "avatar")
    }
    
    private func updateEditingMode() {
        aboutMeTextView.isUserInteractionEnabled = editingMode
        jobTextField.isUserInteractionEnabled = editingMode
        professionTextField.isUserInteractionEnabled = editingMode
        genderTextField.isUserInteractionEnabled = editingMode
        cityTextField.isUserInteractionEnabled = editingMode
        countryTextField.isUserInteractionEnabled = editingMode
        heightTextField.isUserInteractionEnabled = editingMode
        lookingForTextField.isUserInteractionEnabled = editingMode
    }
    
    private func showKeyboard() {
        self.aboutMeTextView.becomeFirstResponder()
    }
    
    private func hideKeyboard() {
        self.view.endEditing(false)
    }
    
    private func saveUserData(user: FirebaseUser) {
        user.saveUserLocally()
        user.saveUserToFireStore()
    }
    
    //MARK: - Alert controller
    
    private func showPictureOptions() {
        let alertController = UIAlertController(title: "Upload picture", message: "Change avatar or upload more pictures", preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Change Avatar", style: .default, handler: { alert in
            
        }))
        alertController.addAction(UIAlertAction(title: "Upload pictures", style: .default, handler: { alert in
            
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        self.present(alertController, animated: true)
    }
    
    private func showEditOptions() {
        let alertController = UIAlertController(title: "Edit Account", message: "Edit information about you", preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Change Email", style: .default, handler: { alert in
            
        }))
        alertController.addAction(UIAlertAction(title: "Change Name", style: .default, handler: { alert in
            
        }))
        alertController.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { alert in
            
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        self.present(alertController, animated: true)
    }
}
