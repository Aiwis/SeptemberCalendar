//
//  CalendarViewModel.swift
//  SeptemberPrint
//
//  Created by Mathilde Menet on 06/09/2016.
//  Copyright © 2016 Mathilde Menet. All rights reserved.
//

import UIKit
import Photos

class CalendarViewModel: NSObject {
    
    var selectedPhotoIndex: NSIndexPath?
    var assets = [PHAsset]()
    var imageSavedCompletionHandler: ((Bool) -> ())?
    var selectedImage: UIImage?
    
    let calendarTargetSize = CGSize(width: 1000, height: 900)
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
        
        let options = PHImageRequestOptions()
        options.resizeMode = PHImageRequestOptionsResizeMode.Exact
        options.deliveryMode = PHImageRequestOptionsDeliveryMode.HighQualityFormat

        var targetSize: CGSize?
        if isSelected {
            if let selectedImage = selectedImage {
                if selectedImage.size.width > selectedImage.size.height {
                    targetSize = calendarTargetSize
                } else {
                    targetSize = CGSize(width: self.calendarTargetSize.height, height: self.calendarTargetSize.width)
                }
            }
        }
        imageManager.requestImageForAsset(asset,
                                          targetSize: targetSize ?? (isSelected ? calendarTargetSize : CGSize(width: 600, height: 600)),
                                          contentMode: .AspectFill,
                                          options: options) { (result, info) in
                                            if let image = result {
                                                
                                                print(targetSize)
                                                print(image.size)
                                                if image.size == self.calendarTargetSize || image.size == CGSize(width: 600, height: 600) {
                                                    if let info = info {
                                                        if info[PHImageResultIsDegradedKey] === false {
                                                            if isSelected {
                                                                self.selectedImage = image
                                                            }
                                                            completionHandler(image)
                                                        }
                                                    }

                                                } else {
                                                    imageManager.requestImageForAsset(asset, targetSize: CGSize(width: self.calendarTargetSize.height, height: self.calendarTargetSize.width), contentMode: .AspectFill, options: options, resultHandler: { (result, info) in
                                                        if let image = result {
                                                            if let info = info {
                                                                if info[PHImageResultIsDegradedKey] === false {
                                                                    if isSelected {
                                                                        print("final image size")
                                                                        print(image.size)
                                                                    }
                                                                    completionHandler(image)
                                                                }
                                                            }
                                                        }
                                                    })
                                                }
                                            }
                                            
        }
        
    }
    
    func isPhotoSelectedAtIndexPath(indexPath: NSIndexPath) -> Bool {
        return indexPath == selectedPhotoIndex
    }
    
    func saveCalendarPicture(completionHandler: (Bool) -> ()) {
        
        imageSavedCompletionHandler = completionHandler
        
        if let indexPath = selectedPhotoIndex {
            print("test1")
            fetchImageAtIndexPath(indexPath, isSelected: true, completionHandler: { (image) in
                print("test2")
                let selectedImage = image
                
                if let calendarImage = UIImage(named: "september") {
                    
//                    print(selectedImage!.size)
                    
                    UIGraphicsBeginImageContext(self.calendarTargetSize)
                    
                    // Draw selected image within target rect
                    let areaSize = CGRect(x: 0, y: 0, width: self.calendarTargetSize.width, height: self.calendarTargetSize.height)
                    selectedImage!.drawInRect(areaSize)
                    
                    // Determine calendar size
                    let calendarAspectRatio = calendarImage.size.width / calendarImage.size.height
                    let calendarSize = CGSize(width: self.calendarTargetSize.width, height: self.calendarTargetSize.width / calendarAspectRatio)
                    
                    // Draw calendar in determined area
                    let calendarAreaSize = CGRect(x: 0, y: self.calendarTargetSize.height - calendarSize.height, width: calendarSize.width, height: calendarSize.height)
                    calendarImage.drawInRect(calendarAreaSize, blendMode: .Normal, alpha: 1)
                    
                    let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()
                    UIGraphicsEndImageContext()
                    
//                    print(newImage.size)
                    
                    UIImageWriteToSavedPhotosAlbum(newImage, self, #selector(self.savedOK(_:didFinishSavingWithError:contextInfo:)), nil)
                    
                }
                
            })
            
        }
        
    }
    
    
    @objc func savedOK(image:UIImage!, didFinishSavingWithError error:NSError!, contextInfo:UnsafePointer<Void>) {
        if let completionHandler = imageSavedCompletionHandler {
            guard error == nil else {
                completionHandler(false)
                return
            }
            completionHandler(true)
        }
    }
}


