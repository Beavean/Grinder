//
//  UserCardFooterView.swift
//  Grinder
//
//  Created by Beavean on 24.09.2022.
//

import UIKit

class UserCardFooterView: UIView {

  private var label = UILabel()

  private var gradientLayer: CAGradientLayer?

  init(withTitle title: String?, subtitle: String?) {
    super.init(frame: CGRect.zero)
    backgroundColor = .clear
    layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
    layer.cornerRadius = 10
    clipsToBounds = true
    isOpaque = false
    initialise(title: title, subtitle: subtitle)
  }

  required init?(coder aDecoder: NSCoder) {
    return nil
  }

  private func initialise(title: String?, subtitle: String?) {
    let attributedText = NSMutableAttributedString(string: (title ?? "") + "\n",
                                                   attributes: NSAttributedString.Key.titleAttributes)
    if let subtitle = subtitle, !subtitle.isEmpty {
      attributedText.append(NSMutableAttributedString(string: subtitle,
                                                      attributes: NSAttributedString.Key.subtitleAttributes))
      let paragraphStyle = NSMutableParagraphStyle()
      paragraphStyle.lineSpacing = 4
      paragraphStyle.lineBreakMode = .byTruncatingTail
      attributedText.addAttributes([NSAttributedString.Key.paragraphStyle: paragraphStyle],
                                   range: NSRange(location: 0, length: attributedText.length))
      label.numberOfLines = 2
    }

    label.attributedText = attributedText
    addSubview(label)
  }

  override func layoutSubviews() {
    let padding: CGFloat = 20
    label.frame = CGRect(x: padding,
                         y: bounds.height - label.intrinsicContentSize.height - padding,
                         width: bounds.width - 2 * padding,
                         height: label.intrinsicContentSize.height)
  }
}
