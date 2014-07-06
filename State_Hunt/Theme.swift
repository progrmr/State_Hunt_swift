//
//  Theme.swift
//  State_Hunt
//
//  Created by Gary Morris on 7/4/14.
//  Copyright (c) 2014 Gary Morris. All rights reserved.
//

import Foundation
import UIKit

let s_SingletonInstance = Theme()

class Theme {
    
    let kBackgroundColor        = UIColor(gray:0.85)
    let kTextColor              = UIColor.blackColor()
    let kDetailTextColor        = UIColor(gray:0.7)
    
    let kSeenBackgroundColor    = UIColor(g:0.6)
    let kSeenTextColor          = UIColor.whiteColor()
    
    let kButtonTintColor        = UIColor(g:0.4)
    let kButtonTextColor        = UIColor(g:0.4)
    let kButtonHighlightColor   = UIColor(rgb:0x4444ff)
    
    let kCellBorderColor        = UIColor(gray:0.0)
    
    class var currentTheme : Theme {
        return s_SingletonInstance
    }
    
}