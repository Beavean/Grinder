//
//  RecentTableViewCell.swift
//  Grinder
//
//  Created by Beavean on 30.09.2022.
//

import UIKit

class RecentTableViewCell: UITableViewCell {
    
    //MARK: - IBOutlets
    
    @IBOutlet weak var lastMessageLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var unreadMessageBackgroundView: UIView!
    @IBOutlet weak var unreadMessageCountLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        unreadMessageBackgroundView.layer.cornerRadius = unreadMessageBackgroundView.frame.width / 2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func generateCell() {
        
    }
    
    private func setAvatar(avatarLink: String) {
        
    }
}
