//
//  CardViewController.swift
//  Grinder
//
//  Created by Beavean on 24.09.2022.
//

import UIKit
import Shuffle_iOS
import FirebaseCore

class CardViewController: UIViewController {
    
    //MARK: - Properties
    
    private let cardStack = SwipeCardStack()
    private var initialCardModels = [UserCardModel]()

    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createUsers()
        downloadInitialUser()
        
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
    
    private func downloadInitialUser() {
        
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
        card.configure(withModel: initialCardModels[index])
        return card
    }
    
    func numberOfCards(in cardStack: Shuffle_iOS.SwipeCardStack) -> Int {
        return initialCardModels.count
    }
    
    func didSwipeAllCards(_ cardStack: SwipeCardStack) {
        print("DEBUG: Finished swiping all cards.")
    }
    
    func cardStack(_ cardStack: SwipeCardStack, didSwipeCardAt index: Int, with direction: SwipeDirection) {
        print("DEBUG: Swipe to  \(direction)")
    }
    
    func cardStack(_ cardStack: SwipeCardStack, didSelectCardAt index: Int) {
        print("DEBUG: Selected card at \(index)")
    }
}
