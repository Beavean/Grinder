//
//  ImageCollectionViewCell.swift
//  Grinder
//
//  Created by Beavean on 27.09.2022.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
    
    //MARK: - IBOutlets
    
    @IBOutlet weak var backgroundPlaceholder: UIView!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var cityCountryLabel: UILabel!
    @IBOutlet weak var nameAgeLabel: UILabel!
    
    //MARK: - Properties
    
    let gradientLayer = CAGradientLayer()
    var indexPath: IndexPath!
    
    override func awakeFromNib() {
        avatarImageView.layer.cornerRadius = 5
        avatarImageView.clipsToBounds = true
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        if indexPath.row == 0 {
            backgroundPlaceholder.isHidden = false
            setGradientBackground()

        } else {
            backgroundPlaceholder.isHidden = true
        }
        
    }
    
    func setupCell(image: UIImage, country: String, nameAge: String, indexPath: IndexPath) {
        self.indexPath = indexPath
        avatarImageView.image = image
        cityCountryLabel.text = indexPath.row == 0 ? country : ""
        nameAgeLabel.text = indexPath.row == 0 ? nameAge : ""
    }
    
    func setGradientBackground() {
        gradientLayer.removeFromSuperlayer()
        let colorForTop = UIColor.clear.cgColor
        let colorForBottom = UIColor.black.cgColor
        gradientLayer.colors = [colorForTop, colorForBottom]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.cornerRadius = 5
        gradientLayer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        gradientLayer.frame = self.backgroundPlaceholder.bounds
        self.backgroundPlaceholder.layer.insertSublayer(gradientLayer, at: 0)
    }
}
