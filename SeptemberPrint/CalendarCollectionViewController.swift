//
//  CalendarCollectionViewController.swift
//  SeptemberPrint
//
//  Created by Mathilde Menet on 10/09/2016.
//  Copyright © 2016 Mathilde Menet. All rights reserved.
//

import UIKit



class CalendarCollectionViewController: UICollectionViewController {

    // Const
    private let kCollectionViewLeftRightMargin: CGFloat     = 0
    private let kCollectionViewTopBottomMargin: CGFloat     = 4
    private let kCollectionViewInterItemSpacing: CGFloat    = 4
    private let kEstimatedImageWidth: CGFloat               = 160
    
    // Calculated values
    private var itemWidth: CGFloat                          = 120
    
    private let cellReuseIdentifier = "PhotoCell"
    private let headerReuseIdentifier = "CalendarView"

    private let viewModel = CalendarViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initCollectionView()
        
        viewModel.fetchGalleryPictures()
        
        navigationController?.navigationBar.translucent = false
        let saveButtonItem = UIBarButtonItem(barButtonSystemItem: .Save, target: self, action: #selector(saveCalendar))
        navigationItem.rightBarButtonItem = saveButtonItem
        
    }
    
    func initCollectionView() {
        
        let flowLayout = UICollectionViewFlowLayout()
        
        flowLayout.minimumLineSpacing = kCollectionViewInterItemSpacing
        flowLayout.minimumInteritemSpacing = kCollectionViewInterItemSpacing
        flowLayout.sectionInset = UIEdgeInsets(top: kCollectionViewTopBottomMargin,
                                               left: kCollectionViewLeftRightMargin,
                                               bottom: kCollectionViewTopBottomMargin,
                                               right: kCollectionViewLeftRightMargin)
        
        flowLayout.headerReferenceSize = CGSize(width: UIScreen.mainScreen().bounds.width, height: viewModel.ratio(viewModel.calendarTargetSize.height))
        
        
        itemWidth = calculateItemWidth()
        
        collectionView?.collectionViewLayout = flowLayout
        
        collectionView?.registerNib(UINib(nibName: "PhotoCell", bundle: nil), forCellWithReuseIdentifier: cellReuseIdentifier)
        collectionView?.registerNib(UINib(nibName: "CalendarView", bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headerReuseIdentifier)
        collectionView?.backgroundColor = UIColor.blackColor()
    }

}

// MARK: - Collection View data source

extension CalendarCollectionViewController {
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfPictures()
    }
}

// MARK: - Collection View delegate

extension CalendarCollectionViewController {
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellReuseIdentifier, forIndexPath: indexPath) as? PhotoCell
        
        viewModel.fetchImageAtIndexPath(indexPath, isSelected: false) { (image) in
            if let image = image {
                cell?.loadCell(image: image, selected: self.viewModel.isPhotoSelectedAtIndexPath(indexPath))
            }
        }
        return cell ?? UICollectionViewCell()
    }
    
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        
        if indexPath != viewModel.selectedPhotoIndex {
            var indexPaths = [indexPath]
            if let selectedPhotoIndexPath = viewModel.selectedPhotoIndex {
                indexPaths.append(selectedPhotoIndexPath)
            }
            collectionView.reloadItemsAtIndexPaths(indexPaths)
            
            viewModel.fetchImageAtIndexPath(indexPath, isSelected: true) { (image) in
                if let image = image {
//                    self.selectedImageView.image = image
                    self.collectionView?.reloadData()
                }
                
                dispatch_async(dispatch_get_main_queue(), {
//                    self.calendarViewTopSpacingConstraint.constant = 0
//                    //                    self.galleryCollectionView.contentOffset = CGPointMake(0, self.lastOffset-240)
//                    self.tableView.tableHeaderView?.frame = UIScreen.mainScreen().bounds
//                    UIView.animateWithDuration(0.5, animations: {
//                        self.view.layoutIfNeeded()
//                    })
                    self.collectionView?.reloadSections(NSIndexSet(indexesInRange: NSRange(location: 0,length: 1)))

                })
            }
            viewModel.selectPictureAtIndexPath(indexPath)
            
        }
    }
    
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
//        let height = viewModel.ratio(viewModel.calendarTargetSize.height)
//        let width = UIScreen.mainScreen().bounds.width
//        let frame = CGRect(x: 0, y: 0, width: width, height: height)
        
        let view = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: headerReuseIdentifier, forIndexPath: indexPath) as! CalendarView
        view.viewModel = self.viewModel
//        view.frame = frame
        return view

    }
}

// MARK: - Collection View flow layout

extension CalendarCollectionViewController {
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(itemWidth, itemWidth)
    }
    
    func calculateItemWidth() -> CGFloat {
        
        // Number of columns
        let screenWidth = UIScreen.mainScreen().bounds.width
        //        let numberOfColums: Int = Int(ceil(screenWidth / kEstimatedImageWidth))
        let numberOfColums: Int = 3
        
        // Item width (screen width - margins and spacing) / number of columns (-2 to avoid rounding the result and not calculating the right number of columns)
        let spaces = kCollectionViewLeftRightMargin*2 + kCollectionViewInterItemSpacing*CGFloat(numberOfColums - 1)
        let itemWidth = (screenWidth - spaces) / CGFloat(numberOfColums)
        
        return itemWidth
    }
}


// MARK: - Save picture

extension CalendarCollectionViewController {
    
    func saveCalendar() {
        viewModel.saveCalendarPicture { success in
            
            if success {
                print("saved !")
                let alert = UIAlertController(title: "Image saved", message: "Your calendar is now saved in the phone gallery.", preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            } else {
                print("not saved :(")
                let alert = UIAlertController(title: "Error while saving picture", message: "Your calendar has not been saved in the phone gallery.", preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
        }
    }
}

