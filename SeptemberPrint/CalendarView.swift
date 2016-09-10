//
//  CalendarView.swift
//  SeptemberPrint
//
//  Created by Mathilde Menet on 10/09/2016.
//  Copyright © 2016 Mathilde Menet. All rights reserved.
//

import UIKit

class CalendarView: UICollectionReusableView {

    var viewModel = CalendarViewModel() {
        didSet {
            initView()
        }
    }
    
    @IBOutlet weak var selectedImageView: UIImageView!
    
    // To render the final calendar on each device, we need to calculate all the constraints
    @IBOutlet weak var selectedImageTopMarginConstraint: NSLayoutConstraint!
    @IBOutlet weak var selectedImageLeftMarginConstraint: NSLayoutConstraint!
    @IBOutlet weak var selectedImageRightMarginConstraint: NSLayoutConstraint!
    @IBOutlet weak var selectedImageBottomSpaceConstraint: NSLayoutConstraint!
    @IBOutlet weak var septemberImageHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var septemberImageWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var septemberImageBottomMarginConstraint: NSLayoutConstraint!
//    @IBOutlet weak var calendarViewHeightConstraint: NSLayoutConstraint!
    
    // Handle header animation
//    @IBOutlet weak var calendarViewTopSpacingConstraint: NSLayoutConstraint!
    var lastOffset: CGFloat                         = 0

    func initView() {
//        tableView.tableHeaderView?.frame = UIScreen.mainScreen().bounds
//        selectedImageView.clipsToBounds = true
//        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.ExtraLight)
//        let blurEffectView = UIVisualEffectView(effect: blurEffect)
//        blurEffectView.frame = self.selectedImageView.bounds
//        
        // Render final calendar aspect
        selectedImageTopMarginConstraint.constant = viewModel.ratio(viewModel.selectedImageTopBottomMargin)
        selectedImageBottomSpaceConstraint.constant = viewModel.ratio(viewModel.selectedImageTopBottomMargin)
        selectedImageLeftMarginConstraint.constant = viewModel.ratio(viewModel.selectedImageLeftRightMargin)
        selectedImageRightMarginConstraint.constant = viewModel.ratio(viewModel.selectedImageLeftRightMargin)
//        calendarViewHeightConstraint.constant = viewModel.ratio(viewModel.calendarTargetSize.height)
        septemberImageWidthConstraint.constant = viewModel.ratio(viewModel.septemberImageTargetSize().width)
        septemberImageHeightConstraint.constant = viewModel.ratio(viewModel.septemberImageTargetSize().height)
        septemberImageBottomMarginConstraint.constant = viewModel.ratio(viewModel.septemberImageBottomMargin)
        
        selectedImageView.image = viewModel.selectedImage
        
    }
    
}
