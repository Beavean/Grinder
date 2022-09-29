//
//  LikeTableViewCell.swift
//  Grinder
//
//  Created by Beavean on 29.09.2022.
//

import UIKit

class LikeTableViewCell: UITableViewCell {
    
    //MARK: - IBOulets
    
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func setupCell(user: FirebaseUser) {
        usernameLabel.text = user.username
        setAvatar(avatarLink: user.avatarLink)
    }
    
    private func setAvatar(avatarLink: String) {
        FileStorage.downloadImage(imageURL: avatarLink) { image in
            self.avatarImageView.image = image?.circleMasked
        }
    }
    
}
