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
    
    //MARK: - Properties
    
    private let cardStack = SwipeCardStack()
    private var initialCardModels = [UserCardModel]()
    private var secondCardModels = [UserCardModel]()
    private var userObject = [FirebaseUser]()
    var lastDocumentSnapshot: DocumentSnapshot?
    var isInitialLoad = true
    var showReserve = false
    var numberOfCardsAdded = 0
    var initialLoadNumber = 4
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //        createUsers()
        downloadInitialUsers()
        
        //        let user = FirebaseUser.currentUser()!
        //        let cardModel = UserCardModel(id: user.objectID,
        //                                      name: user.username,
        //                                      age: user.dateOfBirth.interval(ofComponent: .year, fromDate: Date()),
        //                                      occupation: user.profession,
        //                                      image: user.avatar)
        //        initialCardModels.append(cardModel)
        //        layoutCardStackView()
    }
    
    //MARK: - Layout cards
    
    private func layoutCardStackView() {
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
    }
    
    func cardStack(_ cardStack: SwipeCardStack, didSwipeCardAt index: Int, with direction: SwipeDirection) {
        print("DEBUG: Swipe to  \(direction)")
    }
    
    func cardStack(_ cardStack: SwipeCardStack, didSelectCardAt index: Int) {
        print("DEBUG: Selected card at \(index)")
    }
}
