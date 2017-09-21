//
//  MainVC.swift
//  SURVEYS
//
//  Created by Frank on 18/09/2017.
//  Copyright © 2017 Frank. All rights reserved.
//

import UIKit
import DZNEmptyDataSet
import NVActivityIndicatorView
import Nuke

class MainViewController: UIViewController {
    @IBOutlet weak var cardCollectionView: UICollectionView!
    @IBOutlet weak var pagerCollectionView: UICollectionView!
    
    var surveys = [Survey]()
    var currentIndicatorIndex = 0 {
        didSet {
            collectionView(cardCollectionView, didSelectItemAt: IndexPath(row: currentIndicatorIndex, section: 0))
        }
    }
    var currentItemIndex: Int = 0
    var downwardCellSum = 0
    var upwardCellSum = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 10.0, *) {
            cardCollectionView.isPrefetchingEnabled = false
        }
        
        navigationController?.navigationBar.tintColor = .white
        
        cardCollectionView.dataSource = self
        cardCollectionView.delegate = self
        if let layout = cardCollectionView.collectionViewLayout as? CardLayout {
            layout.collectionViewCellDelegate = self
        }
        
        pagerCollectionView.dataSource = self
        pagerCollectionView.delegate = self
        
        cardCollectionView.decelerationRate = UIScrollViewDecelerationRateFast
        pagerCollectionView.decelerationRate = UIScrollViewDecelerationRateFast
        
        reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let sender = sender as? UIButton, let detailVC = segue.destination as? DetailViewController {
            detailVC.survey = surveys[sender.tag]
        }
    }
    
    func didSelectIndicator() {
        collectionView(cardCollectionView, didSelectItemAt: IndexPath(row: currentIndicatorIndex, section: 0))
    }
    
    func reloadData() {
        NVActivityIndicatorView.DEFAULT_TYPE = .pacman
        NVActivityIndicatorPresenter.sharedInstance.startAnimating(ActivityData(color: UIColor.cyan))
            
        ServiceManager.shared.query(arg: nil) { (response) in
            self.cardCollectionView.emptyDataSetSource = self
            self.cardCollectionView.emptyDataSetDelegate = self
            
            switch response {
            case .result(let json):
                _ = json.map({ (_, json) in
                    if let id = json["id"].string, let title = json["title"].string, let description = json["description"].string, let coverImageUrl = json["cover_image_url"].string {
                        let survey = Survey(id: id, title: title, description: description, coverImageUrl: "\(coverImageUrl)l")
                        
                        if self.surveys.filter({ $0.id == id }).count == 0 {
                            self.surveys.append(survey)
                        }
                    }
                })
                
                DispatchQueue.main.async {
                    self.cardCollectionView.reloadData()
                    self.pagerCollectionView.reloadData()
                    
                    NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
                }
            case .failed:
                NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
                
                let alertController = UIAlertController(title: "Error", message: "Fetch data failed", preferredStyle: .alert)
                let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                alertController.addAction(cancel)
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    func didTapTakeSurveyButton(sender: UIButton) {
        performSegue(withIdentifier: ToDetailVC, sender: sender)
    }
    
    @IBAction func refreshTapped(_ sender: UIBarButtonItem) {
        reloadData()
    }
}

extension MainViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return surveys.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView === cardCollectionView, let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DequeueCardCell, for: indexPath) as? CardCell {
            cell.titleLabel.text = surveys[indexPath.row].title
            cell.descriptionLabel.text = surveys[indexPath.row].description
            cell.takeSurveyButton.tag = indexPath.row
            
            cell.imageView.image = nil
            Nuke.loadImage(with: surveys[indexPath.row].coverImageURL, into: cell.imageView)
            
            cell.takeSurveyButton.addTarget(self, action: #selector(didTapTakeSurveyButton(sender:)), for: .touchUpInside)
            
            return cell
        } else if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DequeuePagerCell, for: indexPath) as? PagerCell {
            if currentIndicatorIndex == indexPath.row {
                cell.imageView.image = #imageLiteral(resourceName: "selected")
            } else {
                cell.imageView.image = #imageLiteral(resourceName: "notSelect")
            }
            
            return cell
        }
        
        return UICollectionViewCell()
    }
}

extension MainViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // MARK: I use collectionView and dequeue cell with fixed width and height for pager. The collectionView is 30*450 and cell is 30*30, which means the collectionView can have 15 cells within it at most. When the user's scrolling the cardCollectionView and the indicator cell hits the upper or lower boundary, content offset needs to be changed. After reseting the offset, the sums needs to be reset to max value(maxCellsQty) as well because the cell is still on the boundary. In addition, the dots also provide navigation functionality. Press the dot the content view will navigate to the index accordingly.
        if collectionView === pagerCollectionView {
            if indexPath.row > currentIndicatorIndex {
                downwardCellSum += indexPath.row - currentIndicatorIndex
                upwardCellSum = upwardCellSum > 0 ? upwardCellSum - (indexPath.row - currentIndicatorIndex) : 0
            } else if indexPath.row < currentIndicatorIndex {
                upwardCellSum += currentIndicatorIndex - indexPath.row
                downwardCellSum = downwardCellSum > 0 ? downwardCellSum - (currentIndicatorIndex - indexPath.row) : 0
            }
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DequeuePagerCell, for: indexPath)
            let maxCellsQty = Int(collectionView.bounds.height / cell.bounds.height - 1)
            
            if downwardCellSum >= maxCellsQty && indexPath.row > currentIndicatorIndex {
                collectionView.setContentOffset(CGPoint(x: 0, y: collectionView.contentOffset.y + 30 * CGFloat(downwardCellSum - maxCellsQty)), animated: true)
                downwardCellSum = maxCellsQty
            } else if upwardCellSum >= maxCellsQty && indexPath.row < currentIndicatorIndex {
                collectionView.setContentOffset(CGPoint(x: 0, y: collectionView.contentOffset.y - 30 * CGFloat(upwardCellSum - maxCellsQty)), animated: true)
                upwardCellSum = maxCellsQty
            }
            
            performSelector(onMainThread: #selector(didSelectIndicator), with: nil, waitUntilDone: false)
            
            DispatchQueue.main.async {
                self.pagerCollectionView.reloadData()
            }
            
            currentIndicatorIndex = indexPath.row
        } else if collectionView === cardCollectionView, let layout = collectionView.collectionViewLayout as? CardLayout {
            let offset = layout.dragOffset * CGFloat(indexPath.item)
            if collectionView.contentOffset.y != offset {
                collectionView.setContentOffset(CGPoint(x: 0, y: offset), animated: true)
            }
            
            currentItemIndex = indexPath.row
        }
    }
}

extension MainViewController: CollectionViewCellDelegate {
    func didCellIndexChange(index: CGFloat) {
        collectionView(pagerCollectionView, didSelectItemAt: IndexPath(row: Int(index), section: 0))
    }
}

extension MainViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        let str = "No Data"
        let attrs = [NSFontAttributeName: UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)]
        return NSAttributedString(string: str, attributes: attrs)
    }
    
    func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? {
        return #imageLiteral(resourceName: "NoData")
    }
}
