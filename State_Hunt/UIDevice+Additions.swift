//
//  UIDevice+Additions.swift
//  State_Hunt
//
//  Created by Gary Morris on 9/18/14.
//  Copyright (c) 2014 Gary Morris. All rights reserved.
//

import Foundation

extension UIDevice {
    
    class func isPad() -> Bool {
        return currentDevice().userInterfaceIdiom == .Pad
    }

}