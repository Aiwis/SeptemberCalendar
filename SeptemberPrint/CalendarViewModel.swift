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
    
    // Gallery
    var assets = [PHAsset]()

    // Selection
    var selectedPhotoIndex: NSIndexPath?
    var selectedImage: UIImage?
    
    // Save picture
    var imageSavedCompletionHandler: ((Bool) -> ())?
    
    // Target image values
    let calendarTargetSize = CGSize(width: 1000, height: 950)
    let septemberImageTargetWidth: CGFloat = 500
    let selectedImageLeftRightMargin: CGFloat = 50
    let selectedImageTopBottomMargin: CGFloat = 50
    let septemberImageBottomMargin: CGFloat = 50
    
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
                                                        targetSize: CGSize(width: 600, height: 600),
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
        
        let selectedImageTargetSize = self.selectedImageTargetSize()

        imageManager.requestImageForAsset(asset,
                                          targetSize:  (isSelected ? selectedImageTargetSize : CGSize(width: 600, height: 600)),
                                          contentMode: .AspectFill,
                                          options: options) { (result, info) in
                                            if let image = result {
                                                
                                                print("---------------")
                                                print(image.size)
                                                print(selectedImageTargetSize)
                                                if image.size == selectedImageTargetSize || image.size == CGSize(width: 600, height: 600) {
                                                    if let info = info {
                                                        if info[PHImageResultIsDegradedKey] === false {
                                                            if isSelected {
                                                                self.selectedImage = image
                                                            }
                                                            completionHandler(image)
                                                        }
                                                    }
                                                    
                                                }
                                                else {
                                                    imageManager.requestImageForAsset(asset, targetSize: CGSize(width: selectedImageTargetSize.height, height: selectedImageTargetSize.width), contentMode: .AspectFill, options: options, resultHandler: { (result, info) in
                                                        if let image = result {
                                                            if let info = info {
                                                                if info[PHImageResultIsDegradedKey] === false {
                                                                    if isSelected {
                                                                        self.selectedImage = image
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
                
                if let calendarImage = UIImage(named: "september-finalimage") {
                    
                    //                    print(selectedImage!.size)
                    
                    UIGraphicsBeginImageContext(self.calendarTargetSize)

                    // Add border
                    let finalImageRect = CGRect(x: 0, y: 0, width: self.calendarTargetSize.width, height: self.calendarTargetSize.height)
                    let context = UIGraphicsGetCurrentContext();
                    CGContextBeginTransparencyLayer(context, nil)
                    CGContextSetStrokeColorWithColor(context, UIColor.sp_lightGrayColor().CGColor)

                    // Add background color
                    CGContextSetFillColorWithColor(context, UIColor.sp_darkWhiteColor().CGColor)
                    CGContextFillRect(context, finalImageRect)
                    CGContextStrokeRectWithWidth(context, finalImageRect, 2)
                    CGContextEndTransparencyLayer(context)

                    // Draw calendar in determined area
                    let calendarAreaX = (self.calendarTargetSize.width - self.septemberImageTargetSize().width) / 2
                    let calendarAreaY = self.calendarTargetSize.height - self.septemberImageTargetSize().height - self.septemberImageBottomMargin
                    let calendarArea = CGRect(x: calendarAreaX,
                        y: calendarAreaY,
                        width: self.septemberImageTargetSize().width,
                        height: self.septemberImageTargetSize().height)
                    calendarImage.drawInRect(calendarArea, blendMode: .Normal, alpha: 1)
                    
                    // Draw selected image within target rect
                    let selectedImageArea = CGRect(x: self.selectedImageLeftRightMargin,
                        y: self.selectedImageTopBottomMargin,
                        width: self.selectedImageTargetSize().width,
                        height: self.selectedImageTargetSize().height)
                    selectedImage!.drawInRect(selectedImageArea)
                    
                    let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()
                    UIGraphicsEndImageContext()
                    
                    // Save image
                    UIImageWriteToSavedPhotosAlbum(newImage, self, #selector(self.savedOK(_:didFinishSavingWithError:contextInfo:)), nil)
                    
                }
                
            })
            
        }
        
    }
    
    // Image saved callback
    @objc func savedOK(image:UIImage!, didFinishSavingWithError error:NSError!, contextInfo:UnsafePointer<Void>) {
        if let completionHandler = imageSavedCompletionHandler {
            guard error == nil else {
                completionHandler(false)
                return
            }
            completionHandler(true)
        }
    }
    
    func septemberImageTargetSize() -> CGSize {
        if let calendarImage = UIImage(named: "september-finalimage") {
            
            // Determine calendar size
            let calendarAspectRatio = calendarImage.size.width / calendarImage.size.height
            return CGSize(width: self.septemberImageTargetWidth, height: self.septemberImageTargetWidth / calendarAspectRatio)
        }
        return CGSizeZero
    }
    
    func selectedImageTargetSize() -> CGSize {
        let selectedImageWidth = self.calendarTargetSize.width - 2 * self.selectedImageLeftRightMargin
        let selectedImageHeight = self.calendarTargetSize.height - 2 * self.selectedImageTopBottomMargin - self.septemberImageTargetSize().height - self.septemberImageBottomMargin
        return CGSize(width: round(selectedImageWidth), height: round(selectedImageHeight))
    }
    
    // Obtain a float number to adapt target size to phone size in order to correctly render the target image on the phone
    // Number is the target value. We return the phone sized value.
    func ratio(number: CGFloat) -> CGFloat {
        let aspectRatio = calendarTargetSize.width / UIScreen.mainScreen().bounds.width
        return number / aspectRatio
    }
}


