//
//  CardLayout.swift
//  SURVEYS
//
//  Created by Frank on 18/09/2017.
//  Copyright © 2017 Frank. All rights reserved.
//

import UIKit

struct DeviceVariable {
	static let standardHeight: CGFloat = 100
	static let windowHeight: CGFloat = UIScreen.main.bounds.height
}

protocol CollectionViewCellDelegate: class {
    func didCellIndexChange(index: CGFloat)
}

class CardLayout: UICollectionViewLayout {
    weak var collectionViewCellDelegate: CollectionViewCellDelegate?
    
    // MARK: Variables
    // The amount the user needs to scroll before the featured cell changes
    let dragOffset: CGFloat = 180.0
    
    private var cache = [UICollectionViewLayoutAttributes]()
    
    // Returns the item index of the currently featured cell
    private var featuredItemIndex: Int {
        get {
            // Use max to make sure the featureItemIndex is never < 0
            return max(0, Int(collectionView!.contentOffset.y / dragOffset))
        }
    }
    
    // Returns a value between 0 and 1 that represents how close the next cell is to becoming the featured cell
    private var nextItemPercentageOffset: CGFloat {
        get {
            return (collectionView!.contentOffset.y / dragOffset) - CGFloat(featuredItemIndex)
        }
    }
    
    // Returns the width of the collection view
    private var width: CGFloat {
        get {
            return collectionView!.bounds.width
        }
    }
    
    // Returns the height of the collection view
    private var height: CGFloat {
        get {
            return collectionView!.bounds.height
        }
    }
    
    // Returns the number of items in the collection view
    private var numberOfItems: Int {
        get {
            return collectionView!.numberOfItems(inSection: 0)
        }
    }
    
    // MARK: UICollectionViewLayout
    // Return the size of all the content in the collection view
    override var collectionViewContentSize: CGSize {
        let contentHeight = (CGFloat(numberOfItems) * dragOffset) + (height - dragOffset)
        return CGSize(width: width, height: contentHeight)
    }
	
    override func prepare() {
        cache.removeAll(keepingCapacity: false)
        
        let standardHeight = DeviceVariable.standardHeight
        let featuredHeight = DeviceVariable.windowHeight
        
        var frame = CGRect.zero
        var y: CGFloat = 0
        
        for item in 0..<numberOfItems {
            let indexPath = IndexPath(item: item, section: 0)
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            
            attributes.zIndex = item
            var height = standardHeight
            
            if indexPath.item == featuredItemIndex {
                let yOffset = standardHeight * nextItemPercentageOffset
                y = collectionView!.contentOffset.y - yOffset
                height = featuredHeight
            } else if indexPath.item == (featuredItemIndex + 1) && indexPath.item != numberOfItems {
                let maxY = y + standardHeight
                height = standardHeight + max((featuredHeight - standardHeight) * nextItemPercentageOffset, 0)
                y = maxY - height
            }
            
            frame = CGRect(x: 0, y: y, width: width, height: height)
            attributes.frame = frame
            cache.append(attributes)
            y = frame.maxY
        }
    }
    
    // Return all attributes in the cache whose frame intersects with the rect passed to the method
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var layoutAttributes = [UICollectionViewLayoutAttributes]()
        for attributes in cache {
            if attributes.frame.intersects(rect) {
                layoutAttributes.append(attributes)
            }
        }
        return layoutAttributes
    }
    
    // Return true so that the layout is continuously invalidated as the user scrolls
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        let itemIndex = round(proposedContentOffset.y / dragOffset)
        let yOffset = itemIndex * dragOffset
        
        collectionViewCellDelegate?.didCellIndexChange(index: itemIndex)
        
        return CGPoint(x: 0, y: yOffset)
    }
}
