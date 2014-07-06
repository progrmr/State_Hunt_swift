//
//  GMButton.swift
//  State_Hunt
//
//  Created by Gary Morris on 7/4/14.
//  Copyright (c) 2014 Gary Morris. All rights reserved.
//

import Foundation
import UIKit

class GMButton : UIButton {
    
    override func intrinsicContentSize() -> CGSize {
        var textSize = super.intrinsicContentSize()
        let insets   = self.titleEdgeInsets
        textSize.width  += insets.left + insets.right
        textSize.height += insets.top + insets.bottom
        
        return textSize
    }
    
}