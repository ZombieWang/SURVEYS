//
//  RoundedButton.swift
//  SnopChat
//
//  Created by PC9630 on 2017/6/30.
//  Copyright © 2017年 Frank. All rights reserved.
//

import UIKit

@IBDesignable
class RoundedButton: UIButton {
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = cornerRadius > 0
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        didSet {
            layer.borderColor = borderColor?.cgColor
        }
    }
    
    @IBInspectable var bgColor: UIColor? {
        didSet {
            layer.backgroundColor = bgColor?.cgColor
        }
    }
    
    private let _shadowGray: CGFloat = 120.0 / 255.0
    private let _alpha: CGFloat = 0.6
    private let _weight: CGFloat = 1.0
    private let _height: CGFloat = 1.0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.shadowColor = UIColor(red: _shadowGray, green: _shadowGray, blue: _shadowGray, alpha: _alpha).cgColor
        layer.shadowOpacity = 0.8
        layer.shadowRadius = 5.0
        layer.shadowOffset = CGSize(width: _weight, height: _height)
    }
}
