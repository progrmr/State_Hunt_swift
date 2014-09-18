//
//  StateCell.swift
//  State_Hunt
//
//  Created by Gary Morris on 7/2/14.
//  Copyright (c) 2014 Gary Morris. All rights reserved.
//

import UIKit
import Foundation

class StateCell: UICollectionViewCell {

    let titleLabel  = UILabel()
    let detailLabel = UILabel()
    
    convenience override init() {
        self.init(frame: CGRectZero)
    }
    
    override init(frame: CGRect) {
        let theme = Theme.currentTheme
        
        titleLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        titleLabel.backgroundColor              = theme.kBackgroundColor
        titleLabel.textColor                    = theme.kTextColor
        titleLabel.textAlignment                = .Center
        titleLabel.font                         = UIFont.systemFontOfSize(22)
        titleLabel.minimumScaleFactor           = 0.50
        titleLabel.adjustsFontSizeToFitWidth    = true
        titleLabel.accessibilityTraits          |= UIAccessibilityTraitButton | UIAccessibilityTraitUpdatesFrequently
        
        detailLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        detailLabel.backgroundColor             = theme.kBackgroundColor
        detailLabel.textColor                   = theme.kDetailTextColor
        detailLabel.font                        = UIFont.systemFontOfSize(10)
        detailLabel.textAlignment               = .Center
        detailLabel.minimumScaleFactor          = 0.75
        detailLabel.adjustsFontSizeToFitWidth   = true
        
        super.init(frame: frame)

        self.clipsToBounds = true
        
        self.addSubview(titleLabel)
        self.addSubview(detailLabel)
        
        // add auto layout constraints
        var nslcs = NSLC(parent:self)
        nslcs += ["title" : titleLabel, "detail" : detailLabel]
        nslcs += "H:|-2-[title]-2-|"
        nslcs += "H:|-2-[detail]-2-|"
        nslcs += "V:|[title][detail]-3-|"
        
        // set the hugging priority for the detailLabel higher than the titleLabel,
        // so it shrinks to 0 height when it contains no text
        detailLabel.setContentHuggingPriority(251, forAxis: .Vertical)
        
        // add border
        self.layer.borderColor  = theme.kCellBorderColor.CGColor
        self.layer.borderWidth  = 1.0 / UIScreen.mainScreen().scale
        self.layer.cornerRadius = 6
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        let theme = Theme.currentTheme
        
        contentView.backgroundColor = theme.kBackgroundColor
        titleLabel.backgroundColor  = theme.kBackgroundColor
        detailLabel.backgroundColor = theme.kBackgroundColor

        titleLabel.textColor        = theme.kTextColor
        detailLabel.textColor       = theme.kDetailTextColor
        
        titleLabel.text     = nil
        detailLabel.text    = nil
    }

}