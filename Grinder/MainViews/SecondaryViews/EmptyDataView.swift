//
//  EmptyDataView.swift
//  Grinder
//
//  Created by Beavean on 10.10.2022.
//

import UIKit

protocol EmptyDataViewDelegate {
    func didClickReloadButton()
}

class EmptyDataView: UIView {
    
    //MARK: - IBOutlets
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var reloadButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    
    //MARK: - Properties
    
    var delegate: EmptyDataViewDelegate?
    
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
        Bundle.main.loadNibNamed(K.emptyDataViewIdentifier, owner: self)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    @IBAction func reloadButtonPressed(_ sender: UIButton) {
        delegate?.didClickReloadButton()
    }
}
