//
//  MatchViewController.swift
//  Grinder
//
//  Created by Beavean on 29.09.2022.
//

import UIKit

class MatchViewController: UIViewController {
    
    //MARK: - IBOUtlets

    @IBOutlet weak var cardBackgroundView: UIView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameAgeLabel: UILabel!
    @IBOutlet weak var countryCityLabel: UILabel!
    
    //MARK: - Properties
    
    var user: FirebaseUser?
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    //MARK: - IBActions
    
    @IBAction func sendMessageButtonPressed(_ sender: Any) {
        
    }
    
    @IBAction func keepSwipingButtonPressed(_ sender: Any) {
        
    }
    
    //MARK: - Setup
    
    private func setupUI() {
        cardBackgroundView.layer.cornerRadius = 10
        backgroundImageView.layer.cornerRadius = 10
        backgroundImageView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        cardBackgroundView.applyShadow(radius: 8, opacity: 0.2, offset: CGSize(width: 0, height: 2))
    }
    
    private func presentUserData() {
        guard let user = user else { return }
        avatarImageView.image = user.avatar?.circleMasked
        let cityCountry = user.city + ", " + user.country
        let nameAge = user.username + ", \(abs(user.dateOfBirth.interval(ofComponent: .year, fromDate: Date())))"
        nameAgeLabel.text = nameAge
        countryCityLabel.text = cityCountry
    }
}
