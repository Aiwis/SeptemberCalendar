//
//  CalendarViewController.swift
//  SeptemberPrint
//
//  Created by Mathilde Menet on 06/09/2016.
//  Copyright © 2016 Mathilde Menet. All rights reserved.
//

import UIKit
import Foundation

class CalendarViewController: UITableViewController {
    
    let viewModel = CalendarViewModel()
    
    @IBOutlet weak var selectedImageView: UIImageView!
    @IBOutlet weak var galleryCollectionView: UICollectionView!
    
    
    // Const
    let kCollectionViewLeftRightMargin: CGFloat     = 15
    let kCollectionViewTopBottomMargin: CGFloat     = 20
    let kCollectionViewInterItemSpacing: CGFloat    = 8
    let kEstimatedImageWidth: CGFloat               = 200
    
    // Calculated item width
    var itemWidth: CGFloat                          = 120
    
    // Handle header animation
    @IBOutlet weak var calendarViewTopSpacingConstraint: NSLayoutConstraint!
    let kCalendarViewHeight: CGFloat                = 280
    var lastOffset: CGFloat                         = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initTableView()
        initCollectionView()
        
        viewModel.fetchGalleryPictures()
        
        navigationController?.navigationBar.translucent = false
        let saveButtonItem = UIBarButtonItem(barButtonSystemItem: .Save, target: self, action: #selector(saveCalendar))
        navigationItem.rightBarButtonItem = saveButtonItem
    }
    
    func initTableView() {
        tableView.tableHeaderView?.frame = UIScreen.mainScreen().bounds
        selectedImageView.clipsToBounds = true
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.ExtraLight)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.selectedImageView.bounds
        self.selectedImageView.addSubview(blurEffectView)
    }
    
    func initCollectionView() {
        
        let flowLayout = UICollectionViewFlowLayout()
        
        flowLayout.minimumLineSpacing = kCollectionViewInterItemSpacing
        flowLayout.sectionInset = UIEdgeInsets(top: kCollectionViewTopBottomMargin,
                                               left: kCollectionViewLeftRightMargin,
                                               bottom: kCollectionViewTopBottomMargin,
                                               right: kCollectionViewLeftRightMargin)
        
//        galleryCollectionView.contentInset = UIEdgeInsets(top: kCollectionViewTopBottomMargin,
//                                                          left: kCollectionViewLeftRightMargin,
//                                                          bottom: kCollectionViewTopBottomMargin,
//                                                          right: kCollectionViewLeftRightMargin)
        
        
        itemWidth = calculateItemWidth()
        
        galleryCollectionView.collectionViewLayout = flowLayout
        
        galleryCollectionView.dataSource = self
        galleryCollectionView.delegate = self
        
        galleryCollectionView.registerNib(UINib(nibName: "PhotoCell", bundle: nil), forCellWithReuseIdentifier: "PhotoCell")
    }
    
}

// MARK: - Table view data source

extension CalendarViewController {
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 0
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
}

// MARK: - Collection View data source

extension CalendarViewController: UICollectionViewDataSource {
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfPictures()
    }
}

// MARK: - Collection View delegate

extension CalendarViewController: UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("PhotoCell", forIndexPath: indexPath) as? PhotoCell
        viewModel.fetchImageAtIndexPath(indexPath, isSelected: false) { (image) in
            if let image = image {
                cell?.loadCell(image: image, selected: self.viewModel.isPhotoSelectedAtIndexPath(indexPath))
            }
        }
        return cell ?? UICollectionViewCell()
    }
    
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        if indexPath != viewModel.selectedPhotoIndex {
            var indexPaths = [indexPath]
            if let selectedPhotoIndexPath = viewModel.selectedPhotoIndex {
                indexPaths.append(selectedPhotoIndexPath)
            }
            collectionView.reloadItemsAtIndexPaths(indexPaths)
            
            viewModel.selectPictureAtIndexPath(indexPath)
            
            viewModel.fetchImageAtIndexPath(indexPath, isSelected: true) { (image) in
                if let image = image {
                    self.selectedImageView.image = image
                }
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.calendarViewTopSpacingConstraint.constant = 0
//                    self.galleryCollectionView.contentOffset = CGPointMake(0, self.lastOffset-240)
                    self.tableView.tableHeaderView?.frame = UIScreen.mainScreen().bounds
                    UIView.animateWithDuration(0.5, animations: {
                        self.view.layoutIfNeeded()
                    })
                })
            }

        }
    }
}

// MARK: - Collection View flow layout

extension CalendarViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        return CGSizeMake(itemWidth, itemWidth)
    }
    
    func calculateItemWidth() -> CGFloat {
        
        // Number of columns
        let screenWidth = UIScreen.mainScreen().bounds.width
        let numberOfColums: Int = Int(round(screenWidth / kEstimatedImageWidth))
        
        // Item width (screen width - margins and spacing) / number of columns (-2 to avoid rounding the result and not calculating the right number of columns)
        let itemWidth = (screenWidth - (kCollectionViewLeftRightMargin*2 + kCollectionViewInterItemSpacing*CGFloat(numberOfColums - 1))) / CGFloat(numberOfColums) - 2
        
        return itemWidth
    }
}

// MARK: -  Handle header animation

extension CalendarViewController {
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView == galleryCollectionView {
            
            let offset = galleryCollectionView.contentOffset.y
            
            if offset >= 0 {
                if offset <= kCalendarViewHeight {
                    calendarViewTopSpacingConstraint.constant = -offset
                } else {
                    calendarViewTopSpacingConstraint.constant = -kCalendarViewHeight
                }
            }
            
            lastOffset = offset
            tableView.tableHeaderView?.frame = UIScreen.mainScreen().bounds
        }
    }
}

// MARK: - Save picture

extension CalendarViewController {
    
    func saveCalendar() {
        viewModel.saveCalendarPicture { 
            print("saved !")
        }
    }
}





