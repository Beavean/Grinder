//
//  NewMatchCollectionViewCell.swift
//  Grinder
//
//  Created by Beavean on 30.09.2022.
//

import UIKit

class NewMatchCollectionViewCell: UICollectionViewCell {
    
    //MARK: - IBOutlets
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    //MARK: - Lifecycle
    
    override func awakeFromNib() {
        hideActivityIndicator()
    }
    
    func setupCell(avatarLink: String) {
        showActivityIndicator()
        self.avatarImageView.image = UIImage(named: "avatar")
        FileStorage.downloadImage(imageURL: avatarLink) { avatarImage in
            self.hideActivityIndicator()
            self.avatarImageView.image = avatarImage?.circleMasked
        }
    }
    
    private func showActivityIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    private func hideActivityIndicator() {
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }
}
