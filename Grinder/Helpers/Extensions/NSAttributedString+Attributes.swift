//
//  NSAttributedString+Attributes.swift
//  Grinder
//
//  Created by Beavean on 22.09.2022.
//

import UIKit

extension NSAttributedString.Key {
    static var overlayAttributes: [NSAttributedString.Key: Any] = [
        NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-Bold", size: 42)!,
        NSAttributedString.Key.kern: 5.0
    ]
    
    static var shadowAttribute: NSShadow = {
      let shadow = NSShadow()
      shadow.shadowOffset = CGSize(width: 0, height: 1)
      shadow.shadowBlurRadius = 2
      shadow.shadowColor = UIColor.black.withAlphaComponent(0.3)
      return shadow
    }()

    static var titleAttributes: [NSAttributedString.Key: Any] = [
      NSAttributedString.Key.font: UIFont(name: "ArialRoundedMTBold", size: 24)!,
      NSAttributedString.Key.foregroundColor: UIColor.white,
      NSAttributedString.Key.shadow: NSAttributedString.Key.shadowAttribute
    ]

    static var subtitleAttributes: [NSAttributedString.Key: Any] = [
      NSAttributedString.Key.font: UIFont(name: "Arial", size: 17)!,
      NSAttributedString.Key.foregroundColor: UIColor.white,
      NSAttributedString.Key.shadow: NSAttributedString.Key.shadowAttribute
    ]
}
