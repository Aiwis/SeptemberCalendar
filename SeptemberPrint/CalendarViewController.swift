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
    @IBOutlet weak var selectPictureLabel: UILabel!
    @IBOutlet weak var calendarView: UIView!
    @IBOutlet weak var selectPictureButton: UIButton!
    
    // To render the final calendar on each device, we need to calculate all the constraints
    @IBOutlet weak var selectedImageTopMarginConstraint: NSLayoutConstraint!
    @IBOutlet weak var selectedImageLeftMarginConstraint: NSLayoutConstraint!
    @IBOutlet weak var selectedImageRightMarginConstraint: NSLayoutConstraint!
    @IBOutlet weak var selectedImageBottomSpaceConstraint: NSLayoutConstraint!
    @IBOutlet weak var septemberImageHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var septemberImageWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var septemberImageBottomMarginConstraint: NSLayoutConstraint!
    @IBOutlet weak var calendarViewHeightConstraint: NSLayoutConstraint!
    
    // Collection view UI
    let kCollectionViewLeftRightMargin: CGFloat     = 0
    let kCollectionViewTopMargin: CGFloat           = 0
    let kCollectionViewBottomMargin: CGFloat        = 4
    let kCollectionViewInterItemSpacing: CGFloat    = 4
    let kEstimatedImageWidth: CGFloat               = 160
    var itemWidth: CGFloat                          = 120
    
    // Handle header animation
    @IBOutlet weak var calendarViewTopSpacingConstraint: NSLayoutConstraint!
    var lastTopSpaceConstraint: CGFloat             = 0
    var lastOffset: CGFloat                         = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initTableView()
        initCollectionView()
        initCalendarView()
        initNavigationBar()
        
        viewModel.fetchGalleryPictures()
        
    }
    
    func initNavigationBar() {
        navigationController?.navigationBar.translucent = false
        navigationController?.navigationBar.barStyle = .BlackTranslucent
        let saveButtonItem = UIBarButtonItem(barButtonSystemItem: .Save, target: self, action: #selector(saveCalendar))
        navigationItem.rightBarButtonItem = saveButtonItem
        navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        navigationController?.navigationBar.barTintColor = UIColor.sp_darkBlueColor()
        saveButtonItem.enabled = false
    }
    
    func initTableView() {
        tableView.tableHeaderView?.frame = tableView.frame
    }
    
    func initCalendarView() {
        
        selectPictureLabel.text = "Select a picture"
        selectPictureLabel.textColor = UIColor.sp_lightGrayColor()
        selectPictureLabel.font = UIFont.systemFontOfSize(16)
        
        calendarView.backgroundColor = UIColor.sp_darkWhiteColor()
        
        selectedImageView.clipsToBounds = true
        selectedImageView.backgroundColor = UIColor.whiteColor()
        selectedImageView.layer.borderWidth = 0.5
        selectedImageView.layer.borderColor = UIColor.sp_lightGrayColor().CGColor
        
        // Render final calendar aspect
        selectedImageTopMarginConstraint.constant = viewModel.ratio(viewModel.selectedImageTopBottomMargin)
        selectedImageBottomSpaceConstraint.constant = viewModel.ratio(viewModel.selectedImageTopBottomMargin)
        selectedImageLeftMarginConstraint.constant = viewModel.ratio(viewModel.selectedImageLeftRightMargin)
        selectedImageRightMarginConstraint.constant = viewModel.ratio(viewModel.selectedImageLeftRightMargin)
        calendarViewHeightConstraint.constant = viewModel.ratio(viewModel.calendarTargetSize.height)
        septemberImageWidthConstraint.constant = viewModel.ratio(viewModel.septemberImageTargetSize().width)
        septemberImageHeightConstraint.constant = viewModel.ratio(viewModel.septemberImageTargetSize().height)
        septemberImageBottomMarginConstraint.constant = viewModel.ratio(viewModel.septemberImageBottomMargin)
    }
    
    func initCollectionView() {
        
        let flowLayout = UICollectionViewFlowLayout()
        
        flowLayout.minimumLineSpacing = kCollectionViewInterItemSpacing
        flowLayout.minimumInteritemSpacing = kCollectionViewInterItemSpacing
        flowLayout.sectionInset = UIEdgeInsets(top: kCollectionViewTopMargin,
                                               left: kCollectionViewLeftRightMargin,
                                               bottom: kCollectionViewBottomMargin,
                                               right: kCollectionViewLeftRightMargin)
        
        
        itemWidth = calculateItemWidth()
        
        galleryCollectionView.collectionViewLayout = flowLayout
        galleryCollectionView.dataSource = self
        galleryCollectionView.delegate = self
        galleryCollectionView.registerNib(UINib(nibName: "PhotoCell", bundle: nil), forCellWithReuseIdentifier: "PhotoCell")
        galleryCollectionView.backgroundColor = UIColor.whiteColor()
    }
    
    func refreshCalendarView() {
        if let image = viewModel.selectedImage {
            selectedImageView.contentMode = .ScaleAspectFit
            navigationItem.rightBarButtonItem?.enabled = true
            selectedImageView.layer.borderWidth = 0
            selectPictureLabel.hidden = true
            selectedImageView.image = image
            selectPictureButton.hidden = true
        }
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
        
        viewModel.fetchImageAtIndexPath(indexPath, isSelected: false) { [unowned self] (image) in
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
            
            viewModel.fetchImageAtIndexPath(indexPath, isSelected: true) { [unowned self] (image) in
                
                self.refreshCalendarView()
                
                // Handle calendar view animation
                self.calendarViewTopSpacingConstraint.constant = 0
                self.lastTopSpaceConstraint = 0
                UIView.animateWithDuration(0.5, animations: {
                    self.view.layoutIfNeeded()
                })
            }
            
        }
    }
}

// MARK: - Collection View flow layout delegate

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
            
            // If bounce is enabled, we ignore negative offset
            if offset >= 0 {
                
                if offset - lastOffset > 0 {
                    
                    // Scroll up
                    
                    if offset <= calendarViewHeightConstraint.constant && calendarViewTopSpacingConstraint.constant == -lastOffset {
                        
                        // Corresponds to the zone where the offset is lower than calendar view height,
                        // when the calendar view was hidden before we enter in this zone
                        
                        calendarViewTopSpacingConstraint.constant = -offset
                        
                    } else if -lastTopSpaceConstraint <= calendarViewHeightConstraint.constant {
                        
                        // The calendar is not hidden
                        
                        if lastTopSpaceConstraint - (abs(offset - lastOffset)) > -calendarViewHeightConstraint.constant {
                            
                            // The new top constraint (last top constraint - offset delta) is lower than calendar view height
                            
                            calendarViewTopSpacingConstraint.constant = lastTopSpaceConstraint - (abs(offset - lastOffset))
                            
                        } else {
                            
                            // Hide completely calendar view
                            
                            calendarViewTopSpacingConstraint.constant = -calendarViewHeightConstraint.constant
                        }
                    } else {
                        
                        // The calendar is hidden and we scroll up, nothing happens
                    }
                } else {
                    
                    // Scroll down
                    
                    if offset < calendarViewHeightConstraint.constant && calendarViewTopSpacingConstraint.constant != 0 && calendarViewTopSpacingConstraint.constant == -lastOffset {
                        
                        // Corresponds to the zone where the offset is lower than calendar view height,
                        // when the calendar view was fully displayed before we enter in this zone
                        
                        calendarViewTopSpacingConstraint.constant = -offset
                        
                    } else {
                        
                        if calendarViewTopSpacingConstraint.constant < -abs(offset - lastOffset)  {
                            
                            // The new top constraint (current top constraint - offset delta) is lower than calendar view height
                            
                            calendarViewTopSpacingConstraint.constant = calendarViewTopSpacingConstraint.constant + (abs(offset - lastOffset))
                            
                        } else {
                            
                            // Fully display calendar view
                            
                            calendarViewTopSpacingConstraint.constant = 0
                        }
                    }
                }
            }
            
            lastTopSpaceConstraint = calendarViewTopSpacingConstraint.constant
            lastOffset = offset
            
            tableView.tableHeaderView?.frame = CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.width, height: tableView.frame.height)
        }
    }
    
    @IBAction func selectPictureButtonAction(sender: AnyObject) {
        if viewModel.selectedImage == nil {
            let offsetY = lastOffset + (calendarViewHeightConstraint.constant - abs(lastTopSpaceConstraint))
            galleryCollectionView.setContentOffset(CGPoint(x: 0, y: offsetY), animated: true)
        }
    }
}

// MARK: - Save picture

extension CalendarViewController {
    
    func saveCalendar() {
        viewModel.saveCalendarPicture { [unowned self] success in
            
            if success {
                let alert = UIAlertController(title: "Image saved", message: "Your calendar is now saved in the phone gallery.", preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
                alert.addAction(UIAlertAction(title: "Show in gallery", style: .Default, handler: { (_) in
                    UIApplication.sharedApplication().openURL(NSURL(string: "photos-redirect://")!)
                }))
                self.presentViewController(alert, animated: true, completion: nil)
            } else {
                let alert = UIAlertController(title: "Error while saving picture", message: "Your calendar has not been saved in the phone gallery.", preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
        }
    }
}
