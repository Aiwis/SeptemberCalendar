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
    
    // To render the final calendar on each device, we need to calculate all the constraints
    @IBOutlet weak var selectedImageTopMarginConstraint: NSLayoutConstraint!
    @IBOutlet weak var selectedImageLeftMarginConstraint: NSLayoutConstraint!
    @IBOutlet weak var selectedImageRightMarginConstraint: NSLayoutConstraint!
    @IBOutlet weak var selectedImageBottomSpaceConstraint: NSLayoutConstraint!
    @IBOutlet weak var septemberImageHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var septemberImageWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var septemberImageBottomMarginConstraint: NSLayoutConstraint!
    @IBOutlet weak var calendarViewHeightConstraint: NSLayoutConstraint!
    
    // Const
    let kCollectionViewLeftRightMargin: CGFloat     = 0
    let kCollectionViewTopBottomMargin: CGFloat     = 4
    let kCollectionViewInterItemSpacing: CGFloat    = 4
    let kEstimatedImageWidth: CGFloat               = 160
    
    // Calculated values
    var itemWidth: CGFloat                          = 120
    
    // Handle header animation
    @IBOutlet weak var calendarViewTopSpacingConstraint: NSLayoutConstraint!
    var lastTopSpaceConstraint: CGFloat             = 0
    var lastOffset: CGFloat                         = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initTableView()
        initCollectionView()
        
        viewModel.fetchGalleryPictures()
        
        initNavigationBar()
        
    }
    
    func initNavigationBar() {
        navigationController?.navigationBar.translucent = false
        let saveButtonItem = UIBarButtonItem(barButtonSystemItem: .Save, target: self, action: #selector(saveCalendar))
        navigationItem.rightBarButtonItem = saveButtonItem
        saveButtonItem.enabled = false
    }
    
    func initTableView() {
        tableView.tableHeaderView?.frame = tableView.frame
        selectedImageView.clipsToBounds = true
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.ExtraLight)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.selectedImageView.bounds
        
        // Render final calendar aspect
        selectedImageTopMarginConstraint.constant = viewModel.ratio(viewModel.selectedImageTopBottomMargin)
        selectedImageBottomSpaceConstraint.constant = viewModel.ratio(viewModel.selectedImageTopBottomMargin)
        selectedImageLeftMarginConstraint.constant = viewModel.ratio(viewModel.selectedImageLeftRightMargin)
        selectedImageRightMarginConstraint.constant = viewModel.ratio(viewModel.selectedImageLeftRightMargin)
        calendarViewHeightConstraint.constant = viewModel.ratio(viewModel.calendarTargetSize.height)
        septemberImageWidthConstraint.constant = viewModel.ratio(viewModel.septemberImageTargetSize().width)
        septemberImageHeightConstraint.constant = viewModel.ratio(viewModel.septemberImageTargetSize().height)
        septemberImageBottomMarginConstraint.constant = viewModel.ratio(viewModel.septemberImageBottomMargin)
        
        self.tableView.contentSize = CGSize(width: UIScreen.mainScreen().bounds.width, height: self.tableView.frame.height)
        
        
    }
    
    func initCollectionView() {
        
        let flowLayout = UICollectionViewFlowLayout()
        
        flowLayout.minimumLineSpacing = kCollectionViewInterItemSpacing
        flowLayout.minimumInteritemSpacing = kCollectionViewInterItemSpacing
        flowLayout.sectionInset = UIEdgeInsets(top: kCollectionViewTopBottomMargin,
                                               left: kCollectionViewLeftRightMargin,
                                               bottom: kCollectionViewTopBottomMargin,
                                               right: kCollectionViewLeftRightMargin)
        
        
        itemWidth = calculateItemWidth()
        
        galleryCollectionView.collectionViewLayout = flowLayout
        
        galleryCollectionView.dataSource = self
        galleryCollectionView.delegate = self
        
        galleryCollectionView.registerNib(UINib(nibName: "PhotoCell", bundle: nil), forCellWithReuseIdentifier: "PhotoCell")
        galleryCollectionView.backgroundColor = UIColor.blackColor()
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
            
            viewModel.fetchImageAtIndexPath(indexPath, isSelected: true) { (image) in
                if let image = image {
                    self.selectedImageView.image = image
                }
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.navigationItem.rightBarButtonItem?.enabled = true
                    
                    // Handler header animation
                    self.calendarViewTopSpacingConstraint.constant = 0
                    self.lastTopSpaceConstraint = 0
                    UIView.animateWithDuration(0.5, animations: {
                        self.view.layoutIfNeeded()
                    })
                })
            }
            viewModel.selectPictureAtIndexPath(indexPath)
            
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
        let numberOfColums: Int = 3
        
        // Item width (screen width - margins and spacing) / number of columns (-2 to avoid rounding the result and not calculating the right number of columns)
        let spaces = kCollectionViewLeftRightMargin*2 + kCollectionViewInterItemSpacing*CGFloat(numberOfColums - 1)
        let itemWidth = (screenWidth - spaces) / CGFloat(numberOfColums)
        
        return itemWidth
    }
}

// MARK: -  Handle header animation

extension CalendarViewController {
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView == galleryCollectionView {
            
            let offset = galleryCollectionView.contentOffset.y

            if offset >= 0 {
                
                if offset - lastOffset > 0 {

                    if offset <= calendarViewHeightConstraint.constant {
                        calendarViewTopSpacingConstraint.constant = -offset
                    } else if -lastTopSpaceConstraint <= calendarViewHeightConstraint.constant {
                        if lastTopSpaceConstraint - (abs(offset - lastOffset)) > -calendarViewHeightConstraint.constant {
                            calendarViewTopSpacingConstraint.constant = lastTopSpaceConstraint - (abs(offset - lastOffset))
                            
                        } else {
                            calendarViewTopSpacingConstraint.constant = -calendarViewHeightConstraint.constant
                        }
                    }
                } else {
                    if calendarViewTopSpacingConstraint.constant < -calendarViewHeightConstraint.constant {
                        if lastTopSpaceConstraint - (abs(offset - lastOffset)) > -calendarViewHeightConstraint.constant {
                            calendarViewTopSpacingConstraint.constant = lastTopSpaceConstraint - (abs(offset - lastOffset))
                            
                        } else {
                            calendarViewTopSpacingConstraint.constant = -calendarViewHeightConstraint.constant
                        }
                    }  else if offset < calendarViewHeightConstraint.constant && calendarViewTopSpacingConstraint.constant != 0 {
                        calendarViewTopSpacingConstraint.constant = -offset
                    } else {
                        if calendarViewTopSpacingConstraint.constant + (abs(offset - lastOffset)) < 0 {
                            calendarViewTopSpacingConstraint.constant = calendarViewTopSpacingConstraint.constant + (abs(offset - lastOffset))
                        } else {
                            calendarViewTopSpacingConstraint.constant = 0
                        }
                    }
                }
                
            }
            
            lastTopSpaceConstraint = calendarViewTopSpacingConstraint.constant
            lastOffset = offset
            
            tableView.tableHeaderView?.frame = CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.width, height: self.tableView.frame.height)
        }
    }
}

// MARK: - Save picture

extension CalendarViewController {
    
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
