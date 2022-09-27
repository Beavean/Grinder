//
//  UserProfileTableViewController.swift
//  Grinder
//
//  Created by Beavean on 27.09.2022.
//

import UIKit
import SKPhotoBrowser

class UserProfileTableViewController: UITableViewController {
    
    //MARK: - IBOutlets
    
    @IBOutlet weak var sectionOneView: UIView!
    @IBOutlet weak var sectionTwoView: UIView!
    @IBOutlet weak var sectionThreeView: UIView!
    @IBOutlet weak var sectionFourView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var dislikeButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var jobLabel: UILabel!
    @IBOutlet weak var professionLabel: UILabel!
    @IBOutlet weak var aboutTextView: UITextView!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var lookingForLabel: UILabel!
    @IBOutlet weak var heightLabel: UILabel!
    
    //MARK: - Properties
    
    var userObject: FirebaseUser?
    var allImages = [UIImage]()
    private let sectionInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 5)
    
    //MARK: - Lifecycle
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        pageControl.hidesForSinglePage = true
        if let user = userObject {
            updateLikeButtonStatus()
            showUserDetails(user: user)
            loadImages()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackgrounds()
        hideActivityIndicator()
    }
    
    //MARK: - IBActions
    
    
    @IBAction func dislikeButtonPressed(_ sender: UIButton) {
        dismissView()
    }
    
    
    
    
    @IBAction func likeButtonPressed(_ sender: UIButton) {
        guard let objectID = userObject?.objectID else { return }
        saveLikeToUser(userID: objectID)
        dismissView()
    }
    
    //MARK: -  TableViewDelegate
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ""
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }
    
    //MARK: - Setup UI
    
    private func setupBackgrounds() {
        sectionOneView.clipsToBounds = true
        sectionOneView.layer.cornerRadius = 30
        sectionOneView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        sectionTwoView.clipsToBounds = true
        sectionTwoView.layer.cornerRadius = 10
        sectionThreeView.layer.cornerRadius = 10
        sectionFourView.layer.cornerRadius = 10
        pageControl.isHidden = true
    }
    
    //MARK: - Show user profile
    
    private func showUserDetails(user: FirebaseUser?) {
        guard let user = user else { return }
        aboutTextView.text = user.about
        professionLabel.text = user.profession
        jobLabel.text = user.jobTitle
        genderLabel.text = user.isMale ? "Male" : "Female"
        heightLabel.text = String(format: "%.2f", user.height)
        lookingForLabel.text = user.lookingFor
        
    }
    
    //MARK: - Activity indicator
    
    private func showActivityIndicator() {
        self.activityIndicator.startAnimating()
        self.activityIndicator.isHidden = false
    }
    
    private func hideActivityIndicator() {
        self.activityIndicator.stopAnimating()
        self.activityIndicator.isHidden = true
    }
    
    //MARK: - Load images
    
    private func loadImages() {
        guard let user = userObject else { return }
        let placeholder = user.isMale ? "mPlaceholder" : "fPlaceholder"
        let avatar = user.avatar ?? UIImage(named: placeholder)
        if let avatar = avatar {
            allImages = [avatar]
            self.setPageControlPages()
            self.collectionView.reloadData()
        }
        if let imageLinks = user.imageLinks, imageLinks.count > 0 {
            showActivityIndicator()
            FileStorage.downloadImages(imageURLs: imageLinks) { image in
                guard let image = image as? [UIImage] else { return }
                self.allImages += image
                DispatchQueue.main.async {
                    self.setPageControlPages()
                    self.hideActivityIndicator()
                    self.collectionView.reloadData()
                }
            }
        } else {
            hideActivityIndicator()
        }
    }
    
    //MARK: - PageControl
    
    private func setPageControlPages() {
        self.pageControl.numberOfPages = self.allImages.count
        pageControl.isHidden = false
    }
    
    private func setSelectedPageTo(page: Int) {
        self.pageControl.currentPage = page
    }
    
    //MARK: - SKPhotoBrowser
    
    private func showImages(_ images: [UIImage], startIndex: Int) {
        var SKImages = [SKPhoto]()
        for image in images {
            SKImages.append(SKPhoto.photoWithImage(image))
        }
        let browser = SKPhotoBrowser(photos: SKImages)
        browser.initializePageIndex(startIndex)
        self.present(browser, animated: true)
    }
    
    //MARK: - Update UI
    
    private func updateLikeButtonStatus() {
        guard let currentUser = FirebaseUser.currentUser(),
              let likedUserArray = currentUser.likedUsersArray,
              let objectID = userObject?.objectID else { return }
        likeButton.alpha = likedUserArray.contains(objectID) ? 0.5 : 1
        likeButton.isEnabled = !likedUserArray.contains(objectID)
    }
    
    //MARK: - Helpers
    
    private func dismissView() {
        self.dismiss(animated: true)
    }
    
    //MARK: - Like saving
    
    private func saveLikeToUser(userID: String?) {
        guard let userID = userID, let currentUserID = FirebaseUser.currentID() else { return }
        let like = LikedObject(id: UUID().uuidString, userID: currentUserID, likedUserID: userID, date: Date())
        like.saveToFirestore()
        if let currentUser = FirebaseUser.currentUser(), var likedArray = currentUser.likedUsersArray {
            if !likedArray.contains(userID) {
                likedArray.append(userID)
                currentUser.updateCurrentUserInFireStore(withValues: [K.likedUsersArray: likedArray]) { error in
                    print("DEBUG: Updated current with error: \(String(describing: error?.localizedDescription))")
                }
            }
        }
    }
}

extension UserProfileTableViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: K.imageCollectionViewCellIdentifier, for: indexPath) as? ImageCollectionViewCell, let user = userObject else { return UICollectionViewCell() }
        
        let countryCity = user.country + ", " + user.city
        let nameAge = user.username + ", \(abs(user.dateOfBirth.interval(ofComponent: .year, fromDate: Date())))"
        cell.setupCell(image: allImages[indexPath.row], country: countryCity, nameAge: nameAge, indexPath: indexPath)
        return cell
    }
}


extension UserProfileTableViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        showImages(allImages, startIndex: indexPath.row)
    }
}

extension UserProfileTableViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 473)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        setSelectedPageTo(page: indexPath.row)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
}
