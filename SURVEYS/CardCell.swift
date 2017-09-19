//
//  CardCell.swift
//  SURVEYS
//
//  Created by Frank on 18/09/2017.
//  Copyright © 2017 Frank. All rights reserved.
//

import UIKit

class CardCell: UICollectionViewCell {
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var descriptionLbl: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageCoverView: UIView!
    @IBOutlet weak var takeSurveyBtn: RoundedButton!
    
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        
        let standardHeight = DeviceVariable.standardHeight
        let featuredHeight = DeviceVariable.windowHeight
        
        let delta = 1 - ((featuredHeight - frame.height) / (featuredHeight - standardHeight))
        
        let minAlpha: CGFloat = 0.3
        let maxAlpha: CGFloat = 0.75
        imageCoverView.alpha = maxAlpha - (delta * (maxAlpha - minAlpha))
        
        let scale = max(delta, 0.5)
        
        titleLbl.transform = CGAffineTransform(scaleX: scale, y: scale)
        descriptionLbl.alpha = delta
        takeSurveyBtn.transform = CGAffineTransform(scaleX: scale, y: scale)
    }
}
