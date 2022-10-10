//
//  ProfileTableViewController.swift
//  Grinder
//
//  Created by Beavean on 22.09.2022.
//

import UIKit
import Gallery
import ProgressHUD

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
    @IBOutlet weak var ageFromSlider: UISlider!
    @IBOutlet weak var ageToSlider: UISlider!
    @IBOutlet weak var ageToLabel: UILabel!
    @IBOutlet weak var ageFromLabel: UILabel!
    //MARK: - Properties
    
    var uploadingAvatar = true
    var avatarImage: UIImage?
    var gallery: GalleryController!
    
    var alertTextField: UITextField!
    
    var genderPickerView: UIPickerView!
    var genderOptions = ["Male", "Female"]
    
    var editingMode = false {
        didSet {
            updateEditingMode()
            showSaveButton()
            loadUserData()
        }
    }
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPickerView()
        setupBackgrounds()
        setAgeLabels()
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
        editingMode ? showKeyboard() : hideKeyboard()
    }
    
    @IBAction func ageFromSliderValueChanged(_ sender: UISlider) {
        self.ageFromLabel.text = "Age from " + String(format: "%.0f", sender.value)
        saveAgeSettings()
    }
    
    @IBAction func ageToSliderValueChanged(_ sender: UISlider) {
        self.ageToLabel.text = "Age to " + String(format: "%.0f", sender.value)
        saveAgeSettings()
    }
    
    private func saveAgeSettings() {
        K.userDefaults.setValue(ageFromSlider.value, forKey: K.ageFrom)
        K.userDefaults.setValue(ageToSlider.value, forKey: K.ageTo)
        K.userDefaults.synchronize()
    }
    
    private func setAgeLabels() {
        let ageFrom = K.userDefaults.object(forKey: K.ageFrom) as? Float ?? 20.0
        let ageTo = K.userDefaults.object(forKey: K.ageTo) as? Float ?? 50.0
        ageFromSlider.value = ageFrom
        ageToSlider.value = ageTo
        self.ageFromLabel.text = "Age from " + String(format: "%.0f", ageFrom)
        self.ageToLabel.text = "Age to " + String(format: "%.0f", ageTo)
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
            uploadAvatar(avatarImage) { avatarLink in
                user.avatarLink = avatarLink ?? ""
                user.avatar = self.avatarImage
                self.saveUserData(user: user)
                self.loadUserData()
            }
        } else {
            saveUserData(user: user)
            loadUserData()
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
    
    private func setupPickerView() {
        genderPickerView = UIPickerView()
        genderPickerView.delegate = self
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor().primary()
        toolBar.sizeToFit()
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(dismissKeyboard))
        doneButton.tintColor = .black
        toolBar.setItems([spaceButton, doneButton], animated: true)
        toolBar.isUserInteractionEnabled = true
        lookingForTextField.inputAccessoryView = toolBar
        lookingForTextField.inputView = genderPickerView
    }
    
    @objc func dismissKeyboard() {
        self.view.endEditing(false)
    }
    
    //MARK: - Helpers
    
    private func loadUserData() {
        guard let currentUser = FirebaseUser.currentUser() else { return }
        FileStorage.downloadImage(imageURL: currentUser.avatarLink) { image in
            
        }
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
        avatarImageView.image = UIImage(named: "avatar")?.circleMasked
        avatarImageView.image = currentUser.avatar?.circleMasked
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
    
    //MARK: - File Storage
    
    private func uploadAvatar(_ image: UIImage, completion: @escaping (_ avatarLink: String?) -> Void) {
        ProgressHUD.show()
        let fileDirectory = "Avatars/_" + FirebaseUser.currentID() + ".jpg"
        FileStorage.uploadImage(image, directory: fileDirectory) { avatarLink in
            ProgressHUD.dismiss()
            guard let image = image.jpegData(compressionQuality: 0.8) as? NSData else { return }
            FileStorage.saveImageLocally(imageData: image, fileName: FirebaseUser.currentID())
            completion(avatarLink)
        }
    }
    
    private func uploadImages(images: [UIImage?]) {
        ProgressHUD.show()
        FileStorage.uploadImages(images) { imageLinks in
            ProgressHUD.dismiss()
            guard let currentUser = FirebaseUser.currentUser() else { return }
            currentUser.imageLinks = imageLinks
            self.saveUserData(user: currentUser)
        }
    }
    
    //MARK: - Gallery
    
    private func showGallery(forAvatar: Bool) {
        uploadingAvatar = forAvatar
        self.gallery = GalleryController()
        self.gallery.delegate = self
        Config.tabsToShow = [.imageTab, .cameraTab]
        Config.Camera.imageLimit = forAvatar ? 1 : 10
        Config.initialTab = .imageTab
        self.present(gallery, animated: true)
    }
    
    //MARK: - Alert controller
    
    private func showPictureOptions() {
        let alertController = UIAlertController(title: "Upload picture", message: "Change avatar or upload more pictures", preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Change Avatar", style: .default, handler: { alert in
            self.showGallery(forAvatar: true)
        }))
        alertController.addAction(UIAlertAction(title: "Upload pictures", style: .default, handler: { alert in
            self.showGallery(forAvatar: false)
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        self.present(alertController, animated: true)
    }
    
    private func showEditOptions() {
        let alertController = UIAlertController(title: "Edit Account", message: "Edit information about you", preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Change Email", style: .default, handler: { alert in
            self.showChangesField(value: "Email")
        }))
        alertController.addAction(UIAlertAction(title: "Change Name", style: .default, handler: { alert in
            self.showChangesField(value: "Name")
        }))
        alertController.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { alert in
            self.logOutUser()
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        self.present(alertController, animated: true)
    }
    
    private func showChangesField(value: String) {
        let alertController = UIAlertController(title: "Updating \(value)", message: "Please enter your \(value)", preferredStyle: .alert)
        alertController.addTextField { textField in
            self.alertTextField = textField
            self.alertTextField.placeholder = "New \(value)"
        }
        alertController.addAction(UIAlertAction(title: "Update", style: .destructive, handler: { action in
            self.updateUserWith(value: value)
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        self.present(alertController, animated: true)
    }
    
    //MARK: - Change User info
    
    private func updateUserWith(value: String) {
        if alertTextField.text != "" {
            value == "Email" ? changeEmail() : changeUserName()
        } else {
            ProgressHUD.showError("\(value) is empty")
        }
    }
    
    private func changeEmail() {
        guard let newEmail = alertTextField.text else { return }
        FirebaseUser.currentUser()?.updateUserEmail(newEmail: newEmail, completion: { error in
            if let error = error {
                ProgressHUD.showError(error.localizedDescription)
            } else {
                guard let currentUser = FirebaseUser.currentUser() else { return }
                currentUser.email = newEmail
                self.saveUserData(user: currentUser)
                self.loadUserData()
                ProgressHUD.showSuccess("Success!")
            }
        })
    }
    
    private func changeUserName() {
        guard let currentUser = FirebaseUser.currentUser(), let newUsername = alertTextField.text else { return }
        currentUser.username = newUsername
        saveUserData(user: currentUser)
        loadUserData()
    }
    
    //MARK: - Logout
    
    private func logOutUser() {
        FirebaseUser.logOutCurrentUser { error in
            if let error = error {
                ProgressHUD.showError(error.localizedDescription)
            } else {
                let loginView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: K.loginViewIdentifier)
                DispatchQueue.main.async {
                    loginView.modalPresentationStyle = .fullScreen
                    self.present(loginView, animated: true, completion: nil)
                }
            }
        }
    }
}

extension ProfileTableViewController: GalleryControllerDelegate {
    
    func galleryController(_ controller: Gallery.GalleryController, didSelectImages images: [Gallery.Image]) {
        if !images.isEmpty {
            if uploadingAvatar {
                images.first!.resolve { icon in
                    if let icon = icon {
                        self.editingMode = true
                        self.showSaveButton()
                        self.avatarImageView.image = icon.circleMasked
                        self.avatarImage = icon
                    } else {
                        ProgressHUD.showError("Could not select image")
                    }
                }
            } else {
                Image.resolve(images: images) { resolvedImages in
                    self.uploadImages(images: resolvedImages)
                }
            }
        }
        controller.dismiss(animated: true)
    }
    
    func galleryController(_ controller: Gallery.GalleryController, didSelectVideo video: Gallery.Video) {
        controller.dismiss(animated: true)
    }
    
    func galleryController(_ controller: Gallery.GalleryController, requestLightbox images: [Gallery.Image]) {
        controller.dismiss(animated: true)
    }
    
    func galleryControllerDidCancel(_ controller: Gallery.GalleryController) {
        controller.dismiss(animated: true)
    }
}

extension ProfileTableViewController: UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return genderOptions.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return genderOptions[row]
    }
}

extension ProfileTableViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        lookingForTextField.text = genderOptions[row]
    }
}

