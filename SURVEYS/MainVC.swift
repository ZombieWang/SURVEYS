//
//  MainVC.swift
//  SURVEYS
//
//  Created by Frank on 18/09/2017.
//  Copyright © 2017 Frank. All rights reserved.
//

import UIKit

class MainVC: UIViewController {
    @IBOutlet weak var cardCollectionView: UICollectionView!
    @IBOutlet weak var pagerCollectionView: UICollectionView!
    
    var items = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 10.0, *) {
            cardCollectionView.isPrefetchingEnabled = false
        }
        
        for i in 1 ... 5 {
            items.append("\(i)")
        }
        
        cardCollectionView.dataSource = self
        cardCollectionView.delegate = self
        cardCollectionView.decelerationRate = UIScrollViewDecelerationRateFast
        
        pagerCollectionView.dataSource = self
        pagerCollectionView.delegate = self
        pagerCollectionView.decelerationRate = UIScrollViewDecelerationRateFast
    }
}

extension MainVC: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView === cardCollectionView, let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DequeueCardCell, for: indexPath) as? CardCell {
            
            return cell
        } else if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DequeuePagerCell, for: indexPath) as? PagerCell {
            
            return cell
        }
        
        return UICollectionViewCell()
    }
}

extension MainVC: UICollectionViewDelegate {
    
}
