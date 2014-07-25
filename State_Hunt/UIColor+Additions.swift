//
//  UIColor+Additions.swift
//  State_Hunt
//
//  Created by Gary Morris on 7/4/14.
//  Copyright (c) 2014 Gary Morris. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    
    // colors using 32 bit hex RGB values, like 0x00FF00 for pure green
    convenience init(rgb:UInt32, alpha:CGFloat = 1.0) {
        let red   = CGFloat((rgb & 0xff0000) >> 16) / 255.0
        let green = CGFloat((rgb & 0x00ff00) >>  8) / 255.0
        let blue  = CGFloat (rgb & 0x0000ff) / 255.0
        
        self.init(red:red, green:green, blue:blue, alpha:alpha)
    }
    
    // colors using 32 bit hex RGBA values, like 0xFF0000FF for pure red
    convenience init(rgba: UInt32) {
        let red   = CGFloat((rgba & 0xff000000) >> 24) / 255.0
        let green = CGFloat((rgba & 0x00ff0000) >> 16) / 255.0
        let blue  = CGFloat((rgba & 0x0000ff00) >>  8) / 255.0
        let alpha = CGFloat (rgba & 0x000000ff) / 255.0

        self.init(red:red, green:green, blue:blue, alpha:alpha)
    }
    
    // r,g,b,a using CGFloats, all have defaults
    // e.g.:    UIColor(g:0.6)          // gives dark green
    //          UIColor(r:1.0)          // pure red
    //          UIColor(b:1.0, a:0.5)   // blue with transparency
    convenience init(r:CGFloat=0.0, g:CGFloat=0.0, b:CGFloat=0.0, a:CGFloat=1.0) {
        self.init(red:r, green:g, blue:b, alpha:a)
    }
    
    // any gray from black (0.0) to white (1.0)
    //
    // e.g.:    UIColor(gray:0.0)       // black
    //          UIColor(gray:0.5)       // middle gray
    //          UIColor(gray:0.8)       // light gray
    //          UIColor(gray:1.0)       // white
    //
    convenience init(gray:CGFloat) {
        self.init(white:gray, alpha:1)
    }
    
}