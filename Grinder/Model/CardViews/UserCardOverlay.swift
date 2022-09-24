//
//  UserCardOverlay.swift
//  Grinder
//
//  Created by Beavean on 24.09.2022.
//

import UIKit
import Shuffle_iOS

class UserCardOverlay: UIView {

  init(direction: SwipeDirection) {
    super.init(frame: .zero)
    switch direction {
    case .left:
      createLeftOverlay()
    case .right:
      createRightOverlay()
    default:
      break
    }
  }

  required init?(coder: NSCoder) {
    return nil
  }

  private func createLeftOverlay() {
    let leftTextView = UserCardOverlayLabelView(withTitle: "NOPE", color: .dislikeRed, rotation: CGFloat.pi / 10)
    addSubview(leftTextView)
    leftTextView.anchor(top: topAnchor,
                        right: rightAnchor,
                        paddingTop: 30,
                        paddingRight: 14)
  }

  private func createRightOverlay() {
    let rightTextView = UserCardOverlayLabelView(withTitle: "LIKE",
                                                   color: .likeGreen,
                                                   rotation: -CGFloat.pi / 10)
    addSubview(rightTextView)
    rightTextView.anchor(top: topAnchor,
                         left: leftAnchor,
                         paddingTop: 26,
                         paddingLeft: 14)
  }
}

private class UserCardOverlayLabelView: UIView {

  private let titleLabel: UILabel = {
    let label = UILabel()
    label.textAlignment = .center
    return label
  }()

  init(withTitle title: String, color: UIColor, rotation: CGFloat) {
    super.init(frame: CGRect.zero)
    layer.borderColor = color.cgColor
    layer.borderWidth = 4
    layer.cornerRadius = 4
    transform = CGAffineTransform(rotationAngle: rotation)

    addSubview(titleLabel)
    titleLabel.textColor = color
    titleLabel.attributedText = NSAttributedString(string: title,
                                                   attributes: NSAttributedString.Key.overlayAttributes)
    titleLabel.anchor(top: topAnchor,
                      left: leftAnchor,
                      bottom: bottomAnchor,
                      right: rightAnchor,
                      paddingLeft: 8,
                      paddingRight: 3)
  }

  required init?(coder aDecoder: NSCoder) {
    return nil
  }
}

