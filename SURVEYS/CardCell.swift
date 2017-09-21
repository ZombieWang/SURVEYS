//
//  CardCell.swift
//  SURVEYS
//
//  Created by Frank on 18/09/2017.
//  Copyright © 2017 Frank. All rights reserved.
//

import UIKit

class CardCell: UICollectionViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageCoverView: UIView!
    @IBOutlet weak var takeSurveyButton: RoundedButton!
    
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        
        let standardHeight = DeviceVariable.standardHeight
        let featuredHeight = DeviceVariable.windowHeight
        
        let delta = 1 - ((featuredHeight - frame.height) / (featuredHeight - standardHeight))
        
        let minAlpha: CGFloat = 0.3
        let maxAlpha: CGFloat = 0.75
        imageCoverView.alpha = maxAlpha - (delta * (maxAlpha - minAlpha))
        
        let scale = max(delta, 0.5)
        
        titleLabel.transform = CGAffineTransform(scaleX: scale, y: scale)
        descriptionLabel.alpha = delta
        takeSurveyButton.transform = CGAffineTransform(scaleX: scale, y: scale)
    }
}
