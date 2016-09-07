//
//  CalendarViewModel.swift
//  SeptemberPrint
//
//  Created by Mathilde Menet on 06/09/2016.
//  Copyright © 2016 Mathilde Menet. All rights reserved.
//

import UIKit
import Photos

class CalendarViewModel {
    
    var selectedPhotoIndex: NSIndexPath?
    var assets = [PHAsset]()
    
    func fetchGalleryPictures() {
        
        let cachingImageManager = PHCachingImageManager()
        
        let options = PHFetchOptions()
        options.sortDescriptors = [
            NSSortDescriptor(key: "creationDate", ascending: false)
        ]
        
        let results = PHAsset.fetchAssetsWithMediaType(.Image, options: options)
        results.enumerateObjectsUsingBlock { (object, _, _) in
            if let asset = object as? PHAsset {
                self.assets.append(asset)
            }
        }
        
        cachingImageManager.startCachingImagesForAssets(assets,
                                                        targetSize: PHImageManagerMaximumSize,
                                                        contentMode: .AspectFit,
                                                        options: nil
        )
    }
    
    func numberOfPictures() -> Int {
        return assets.count
    }
    
    func selectPictureAtIndexPath(indexPath: NSIndexPath) {

        selectedPhotoIndex = indexPath
    }
    
    func fetchImageAtIndexPath(indexPath: NSIndexPath, isSelected: Bool, completionHandler: (UIImage?)->()) {
        
        let imageManager = PHImageManager()
        let asset = assets[indexPath.row]
        
        imageManager.requestImageForAsset(asset,
                                          targetSize: isSelected ? PHImageManagerMaximumSize : CGSizeMake(800, 800),
                                     contentMode: .AspectFit,
                                     options: nil) { (result, _) in
                                        
                                        completionHandler(result)
        }
        
    }
    
    func isPhotoSelectedAtIndexPath(indexPath: NSIndexPath) -> Bool {
        return indexPath == selectedPhotoIndex
    }
    
    func saveCalendarPicture(completionHandler: () -> ()) {

        
        if let indexPath = selectedPhotoIndex {
            fetchImageAtIndexPath(indexPath, isSelected: true, completionHandler: { (image) in
                let selectedImage = image
                
                if let calendarImage = UIImage(named: "september") {
                    
                    print(selectedImage!.size)
                    
                    // Determine final image target size
                    let size = CGSize(width: 1000, height: 900)
                    UIGraphicsBeginImageContext(size)
                    
                    // Draw selected image within target rect
                    let areaSize = CGRect(x: 0, y: 0, width: size.width, height: size.height)
                    selectedImage!.drawInRect(areaSize)
                    
                    // Determine calendar size
                    let calendarAspectRatio = calendarImage.size.width / calendarImage.size.height
                    let calendarSize = CGSize(width: size.width, height: size.width / calendarAspectRatio)

                    // Draw calendar in determined area
                    let calendarAreaSize = CGRect(x: 0, y: size.height - calendarSize.height, width: calendarSize.width, height: calendarSize.height)
                    calendarImage.drawInRect(calendarAreaSize, blendMode: .Normal, alpha: 1)
                    
                    let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()
                    UIGraphicsEndImageContext()
                    
                    print(newImage.size)
                }

            })

        }
        
    }
}
