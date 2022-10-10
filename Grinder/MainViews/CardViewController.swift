//
//  CardViewController.swift
//  Grinder
//
//  Created by Beavean on 24.09.2022.
//

import UIKit
import Shuffle_iOS
import FirebaseCore
import FirebaseFirestore
import ProgressHUD

class CardViewController: UIViewController {
    
    //MARK: - IBOutlets
    
    @IBOutlet weak var emptyDataView: EmptyDataView!
    
    //MARK: - Properties
    
    private let cardStack = SwipeCardStack()
    private var initialCardModels = [UserCardModel]()
    private var secondCardModels = [UserCardModel]()
    private var userObject = [FirebaseUser]()
    var lastDocumentSnapshot: DocumentSnapshot?
    var isInitialLoad = true
    var showReserve = false
    var numberOfCardsAdded = 0
    var initialLoadNumber = 20
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        downloadInitialUsers()
        showEmptyDataView(loading: true)
        emptyDataView.delegate = self
        downloadInitialUsers()
    }
    
    private func showEmptyDataView(loading: Bool) {
        emptyDataView.isHidden = false
        emptyDataView.reloadButton.isEnabled = true
        let imageName = loading ? "searchingBackground" : "completed"
        let title = loading ? "Searching for users..." : "You have swiped all users"
        let subtitle = loading ? "Please wait" : "Please change the search parameters"
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.view.bringSubviewToFront(self.emptyDataView)
        }
        emptyDataView.imageView.image = UIImage(named: imageName)
        emptyDataView.titleLabel.text = title
        emptyDataView.subTitleLabel.text = subtitle
        emptyDataView.reloadButton.isHidden = loading
    }
    
    private func hideEmptyDataView() {
        emptyDataView.isHidden = true
    }
    
    private func resetLoadCount() {
        isInitialLoad = true
        showReserve = false
        lastDocumentSnapshot = nil
        numberOfCardsAdded = 0
    }
    
    //MARK: - Layout cards
    
    private func layoutCardStackView() {
        hideEmptyDataView()
        cardStack.delegate = self
        cardStack.dataSource = self
        view.addSubview(cardStack)
        cardStack.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.safeAreaLayoutGuide.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.safeAreaLayoutGuide.rightAnchor)
    }
    
    //MARK: - Download users
    
    private func downloadInitialUsers() {
        ProgressHUD.show()
        FirebaseListener.shared.downloadUsersFromFirebase(isInitialLoad: isInitialLoad, limit: initialLoadNumber, lastDocumentSnapshot: lastDocumentSnapshot) { allUsers, snapshot in
            if allUsers.isEmpty {
                ProgressHUD.dismiss()
            }
            self.lastDocumentSnapshot = snapshot
            self.isInitialLoad = false
            self.initialCardModels = []
            self.userObject = allUsers
            for user in allUsers {
                user.getUserAvatarFromFirestore { didSetValue in
                    let cardModel = UserCardModel(id: user.objectID,
                                                  name: user.username,
                                                  age: abs(user.dateOfBirth.interval(ofComponent: .year, fromDate: Date())),
                                                  occupation: user.profession,
                                                  image: user.avatar)
                    self.initialCardModels.append(cardModel)
                    self.numberOfCardsAdded += 1
                    if self.numberOfCardsAdded == allUsers.count {
                        print("DEBUG: Reload")
                        DispatchQueue.main.async {
                            ProgressHUD.dismiss()
                            self.layoutCardStackView()
                        }
                    }
                }
            }
            print("DEBUG: Received users: \(allUsers.count)")
            self.downloadMoreUsersInBackground()
        }
    }
    
    private func downloadMoreUsersInBackground() {
        FirebaseListener.shared.downloadUsersFromFirebase(isInitialLoad: isInitialLoad, limit: 1000, lastDocumentSnapshot: lastDocumentSnapshot) { allUsers, snapshot in
            self.lastDocumentSnapshot = snapshot
            self.secondCardModels = []
            self.userObject += allUsers
            for user in allUsers {
                user.getUserAvatarFromFirestore { didSetAvatar in
                    let cardModel = UserCardModel(id: user.objectID,
                                                  name: user.username,
                                                  age: abs(user.dateOfBirth.interval(ofComponent: .year, fromDate: Date())),
                                                  occupation: user.profession,
                                                  image: user.avatar)
                    self.secondCardModels.append(cardModel)
                }
            }
        }
    }
    
    //MARK: - Navigation
    
    private func showUserProfileFor(userID: String) {
        let profileView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: K.userProfileControllerIdentifier) as! UserProfileTableViewController
        profileView.userObject = getUserWithId(userID: userID)
        profileView.delegate = self
        self.present(profileView, animated: true)
    }
    
    private func showMatchView(userID: String) {
        let matchView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: K.matchViewIdentifier) as! MatchViewController
        matchView.user = getUserWithId(userID: userID)
        matchView.delegate = self
        self.present(matchView, animated: true)
    }
    
    //MARK: - Helpers
    
    private func getUserWithId(userID: String) -> FirebaseUser? {
        for user in userObject {
            if user.objectID == userID {
                return user
            }
        }
        return nil
    }
    
    private func checkForLikesWith(userID: String) {
        print("DEBUG: Checking for like with user \(userID)")
        if !didLikeUserWith(userID: userID) {
            saveLikeToUser(userID: userID)
        }
        FirebaseListener.shared.checkIfUserLikedUs(userID: userID) { didLike in
            if didLike {
                FirebaseListener.shared.saveMatch(userID: userID)
                self.showMatchView(userID: userID)
            }
        }
    }
    
    private func goToChat(user: FirebaseUser) {
        let chatRoomID = startChat(user1: FirebaseUser.currentUser()!, user2: user)
        let chatView = ChatViewController(chatID: chatRoomID, recipientID: user.objectID, recipientName: user.username)
        chatView.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(chatView, animated: true)
    }
}

//MARK: - SwipeCardStackDelegate + DataSource

extension CardViewController: SwipeCardStackDelegate, SwipeCardStackDataSource {
    
    func cardStack(_ cardStack: Shuffle_iOS.SwipeCardStack, cardForIndexAt index: Int) -> Shuffle_iOS.SwipeCard {
        let card = UserCard()
        card.footerHeight = 80
        card.swipeDirections = [.left, .right]
        for direction in card.swipeDirections {
            card.setOverlay(UserCardOverlay(direction: direction), forDirection: direction)
        }
        card.configure(withModel: showReserve ? secondCardModels[index] : initialCardModels[index])
        return card
    }
    
    func numberOfCards(in cardStack: Shuffle_iOS.SwipeCardStack) -> Int {
        return showReserve ? secondCardModels.count : initialCardModels.count
    }
    
    func didSwipeAllCards(_ cardStack: SwipeCardStack) {
        print("DEBUG: Finished swiping all cards, show reserve: \(showReserve)")
        initialCardModels = []
        if showReserve {
            secondCardModels = []
        }
        showReserve = true
        layoutCardStackView()
        if secondCardModels.isEmpty {
            showEmptyDataView(loading: false)
        }
    }
    
    func cardStack(_ cardStack: SwipeCardStack, didSwipeCardAt index: Int, with direction: SwipeDirection) {
        if direction == .right {
            let user = getUserWithId(userID: showReserve ? self.secondCardModels[index].id : self.initialCardModels[index].id)
            guard let userID = user?.objectID else { return }
            checkForLikesWith(userID: userID)
        }
    }
    
    func cardStack(_ cardStack: SwipeCardStack, didSelectCardAt index: Int) {
        let userID = showReserve ? self.secondCardModels[index].id : self.initialCardModels[index].id
        showUserProfileFor(userID: userID)
    }
}

extension CardViewController: UserProfileTableViewControllerDelegate {
    
    func didLikeUser() {
        cardStack.swipe(.right, animated: true)
    }
    
    func didDislikeUser() {
        cardStack.swipe(.left, animated: true)
    }
}

extension CardViewController: MatchViewControllerDelegate {
    
    func didClickSendMessage(to user: FirebaseUser) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.goToChat(user: user)
        }
    }
    
    func didClickKeepSwiping() {
    }
}

extension CardViewController: EmptyDataViewDelegate {
    
    func didClickReloadButton() {
        resetLoadCount()
        downloadInitialUsers()
        emptyDataView.reloadButton.isEnabled = false
    }
}
