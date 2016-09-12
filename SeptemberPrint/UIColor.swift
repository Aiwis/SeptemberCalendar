//
//  UIColor.swift
//  SeptemberPrint
//
//  Created by Mathilde Menet on 11/09/2016.
//  Copyright © 2016 Mathilde Menet. All rights reserved.
//

import UIKit

extension UIColor {
    
    class func sp_darkBlueColor() -> UIColor { return UIColor(red: 59.0/255.0, green: 77.0/255.0, blue: 87.0/255.0, alpha: 1.0) }
    class func sp_darkWhiteColor() -> UIColor { return UIColor(red: 255.0/255.0, green: 249.0/255.0, blue: 245.0/255.0, alpha: 1.0)}
    class func sp_lightGrayColor() -> UIColor { return UIColor(red: 158.0/255.0, green: 158.0/255.0, blue: 158.0/255.0, alpha: 1.0) }
    class func sp_orangeColor() -> UIColor { return UIColor(red: 253.0/255.0, green: 140.0/255.0, blue: 50.0/255.0, alpha: 1.0) }


    convenience private init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(hex:Int) {
        self.init(red:(hex >> 16) & 0xff, green:(hex >> 8) & 0xff, blue:hex & 0xff)
    }
    
}
