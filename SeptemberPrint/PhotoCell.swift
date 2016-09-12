//
//  PhotoCell.swift
//  SeptemberPrint
//
//  Created by Mathilde Menet on 06/09/2016.
//  Copyright © 2016 Mathilde Menet. All rights reserved.
//

import UIKit

class PhotoCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var overlayView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        clipsToBounds = true
        overlayView.hidden = true
        overlayView.backgroundColor = UIColor.sp_blackAlphaColor()
    }
    
    func loadCell(image image: UIImage, selected: Bool) {

        if image != imageView.image {
            imageView.image = image
        }
        overlayView.hidden = !selected
    }

}
