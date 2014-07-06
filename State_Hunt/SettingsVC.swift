//
//  Settings.swift
//  State_Hunt
//
//  Created by Gary Morris on 7/5/14.
//  Copyright (c) 2014 Gary Morris. All rights reserved.
//

import Foundation
import UIKit

class SettingsVC : UIViewController {
    
    // views
    let titleLabel   = UILabel()
    let doneButton   = UIButton()
    let versionLabel = UILabel()
    let scoreLabel   = UILabel()
    let howToLabel   = UILabel()
    let resetButton  = UISegmentedControl(items:["Start Over"])
    
    let scores : ScoreBoard

    init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!, scoreBoard: ScoreBoard) {
        scores  = scoreBoard
        
        super.init(nibName:nibNameOrNil, bundle:nibBundleOrNil)
    }

    override func loadView() {
        let theme = Theme.currentTheme
        
        // create the root UIView
        view = UIView()
        view.autoresizingMask       = .FlexibleWidth | .FlexibleHeight
        view.userInteractionEnabled = true
        view.backgroundColor        = theme.kBackgroundColor
        
        // add the title label
        titleLabel.backgroundColor  = theme.kBackgroundColor
        titleLabel.text             = "State Hunt"
        titleLabel.textAlignment    = .Center
        titleLabel.font             = UIFont.boldSystemFontOfSize(20)
        
        // add the score label
        scoreLabel.backgroundColor  = theme.kBackgroundColor
        scoreLabel.textAlignment    = .Center
        scoreLabel.font             = UIFont.systemFontOfSize(17)

        // add the howToLabel instructions
        howToLabel.backgroundColor  = theme.kBackgroundColor
        howToLabel.textAlignment    = .Center
        howToLabel.font             = UIFont.systemFontOfSize(15)
        howToLabel.numberOfLines    = 3
        howToLabel.text             = "Try to spot license plates from each state and keep track of which ones you have seen."
        
        // add the done button
        doneButton.backgroundColor  = theme.kBackgroundColor
        doneButton.setTitle("Done", forState: .Normal)
        doneButton.setTitleColor(theme.kButtonTintColor, forState: .Normal)
        doneButton.addTarget(self, action:"doneButtonPressed:", forControlEvents:.TouchUpInside)
       
        // add the reset button
        resetButton.backgroundColor = UIColor(rgb:0x880000)
        resetButton.tintColor       = UIColor.whiteColor()
        resetButton.layer.cornerRadius      = 6
        resetButton.layer.masksToBounds     = true
        resetButton.layer.borderColor       = UIColor.blackColor().CGColor
        resetButton.layer.borderWidth       = 1
        resetButton.addTarget(self, action:"resetButtonPressed:", forControlEvents:.ValueChanged)
        
        // add auto layout constraints
        var nslcs = NSLC(parent:view)
        nslcs += ["done" : doneButton, "title" : titleLabel, "scoreLabel" : scoreLabel, "howToLabel" : howToLabel, "resetButton" : resetButton]
        
        nslcs += "H:[done(>=50)]-|"
        nslcs += "H:|[title]|"
        nslcs += "H:|[scoreLabel]|"
        nslcs += "H:|-(>=5)-[howToLabel(<=220)]-(>=5)-|"
        nslcs += "V:|-[done(>=35)][title]-20-[scoreLabel]-20-[howToLabel]-(>=10)-[resetButton]-(>=5,30@900)-|"
        
        nslcs += NSLC.EQ(howToLabel, attr1:.CenterX, item2:view, attr2:.CenterX)
        nslcs += NSLC.EQ(resetButton, attr1:.CenterX, item2:view, attr2:.CenterX)
        nslcs.addWidthToView(resetButton, width: 120)
    }
    
    override func viewWillAppear(animated: Bool) {
        scoreLabel.text = "You have seen \(scores.numberOfStatesSeen()) states in \(scores.nDaysElapsed()) days."
    }
    
    func doneButtonPressed(button: UIButton) {
        self.dismissModalViewControllerAnimated(true)
    }

    func resetButtonPressed(button: UIButton) {
        // TODO not implemented yet
        let message = "This will reset the \(scores.numberOfStatesSeen()) states you have collected.  Are you sure you want to erase everything and start over?"
        let alert = UIAlertController(title:"Reset All States", message:message, preferredStyle:.Alert)
        
        let cancelAction = UIAlertAction(title:"Cancel", style:.Cancel,
            handler: {(action: UIAlertAction!) in
                self.dismissModalViewControllerAnimated(true)
            })
        
        let resetAction = UIAlertAction(title:"Reset Everything", style:.Destructive,
            handler: {(action: UIAlertAction!) in
                self.scores.resetAll()
                self.dismissModalViewControllerAnimated(true)
            })
        
        alert.addAction(cancelAction)
        alert.addAction(resetAction)
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
}