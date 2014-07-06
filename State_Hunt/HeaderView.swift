//
//  Header.swift
//  State_Hunt
//
//  Created by Gary Morris on 7/3/14.
//  Copyright (c) 2014 Gary Morris. All rights reserved.
//

import Foundation
import UIKit

class HeaderView : UICollectionReusableView {
    
    let infoButton      = GMButton()
    let summaryLabel    = UILabel()
    let showAllButton   = GMButton()
    
    convenience init() {
        self.init(frame: CGRectZero)
    }
    
    init(frame: CGRect) {
        super.init(frame: frame)
        
        let theme = Theme.currentTheme
        
        infoButton.backgroundColor          = theme.kBackgroundColor
        infoButton.tintColor                = theme.kButtonTintColor
        infoButton.titleEdgeInsets          = UIEdgeInsetsMake(0, 10, 0, 10)
        let infoImage = UIImage(named: "724-info")
        infoButton.setImage(infoImage.imageWithRenderingMode(.AlwaysTemplate), forState:.Normal)

        summaryLabel.textAlignment          = .Center
        summaryLabel.textColor              = theme.kTextColor
        summaryLabel.backgroundColor        = theme.kBackgroundColor
        
        showAllButton.backgroundColor       = theme.kBackgroundColor
        showAllButton.tintColor             = theme.kButtonTintColor
        showAllButton.titleEdgeInsets       = UIEdgeInsetsMake(0, 10, 0, 10)
        let moreImage = UIImage(named: "1099-list")
        let lessImage = UIImage(named: "727-more")
        showAllButton.setImage(moreImage.imageWithRenderingMode(.AlwaysTemplate), forState:.Normal)
        showAllButton.setImage(lessImage.imageWithRenderingMode(.AlwaysTemplate), forState:.Selected)
        
        // add auto layout constraints
        var nslcs = NSLC(parent:self)
        nslcs += ["infoButton" : infoButton, "summaryLabel" : summaryLabel, "showButton" : showAllButton]
        
        nslcs += "H:|[infoButton(>=35)]-(>=2)-[summaryLabel]-(>=2)-[showButton(>=35)]-3-|"
        nslcs += "V:|[infoButton]|"
        nslcs += "V:|[summaryLabel]|"
        nslcs += "V:|[showButton]|"
        
        nslcs += NSLC.EQ(summaryLabel, attr1:.CenterX, item2:self, attr2:.CenterX, priority:900)
    }

    func setScore(score: Int) {
        summaryLabel.text = "\(score) States"
        showAllButton.hidden = score < 1
    }
    
}