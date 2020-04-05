//
//  UiView+Extension.swift
//  DemoControlSegment
//
//  Created by Mr Ích on 4/5/20.
//  Copyright © 2020 Mr Ích. All rights reserved.
//

import UIKit

extension UIView {
    func constraintToAllSides(of container: UIView, leftOffset: CGFloat = 0, rightOffset: CGFloat = 0, topOffset: CGFloat = 0, bottomOffset: CGFloat = 0) {
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: container.topAnchor, constant: topOffset),
            leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: leftOffset),
            trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: rightOffset),
            bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: bottomOffset)
        ])
    }
}
