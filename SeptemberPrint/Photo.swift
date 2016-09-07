//
//  Photo.swift
//  SeptemberPrint
//
//  Created by Mathilde Menet on 06/09/2016.
//  Copyright © 2016 Mathilde Menet. All rights reserved.
//

import UIKit
import Photos

class Photo {
    
    var asset = PHAsset()
    var image: UIImage?
    var selected = false
    
    init(asset: PHAsset) {
        self.asset = asset
    }

}
