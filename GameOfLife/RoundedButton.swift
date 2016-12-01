//
//  RoundedButton.swift
//  GameOfLife
//
//  Created by Mattias Jähnke on 23/04/16.
//  Copyright © 2016 nearedge. All rights reserved.
//

import UIKit

class RoundedButton: UIButton {
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = 2.0
        layer.borderColor = UIColor.white.cgColor
        layer.borderWidth = 1
    }
}
