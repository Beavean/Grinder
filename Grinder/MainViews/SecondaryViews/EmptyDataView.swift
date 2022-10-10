//
//  EmptyDataView.swift
//  Grinder
//
//  Created by Beavean on 10.10.2022.
//

import UIKit

class EmptyDataView: UIView {
    
    //MARK: - IBOutlets
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var reloadButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    
    //MARK: - Initialiser
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
    }
    
    @IBAction func reloadButtonPressed(_ sender: UIButton) {
        
    }
    
}
