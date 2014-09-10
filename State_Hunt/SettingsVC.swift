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

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        howToLabel.numberOfLines    = 4
        howToLabel.text             = "Try to spot license plates from each state and you this app to keep track of which ones you have seen."
        
        // add the done button
        doneButton.backgroundColor  = theme.kBackgroundColor
        doneButton.setTitle("Done", forState: .Normal)
        doneButton.setTitleColor(theme.kButtonTintColor, forState: .Normal)
        doneButton.addTarget(self, action:"doneButtonPressed:", forControlEvents:.TouchUpInside)
       
        // add the reset button
        resetButton.selectedSegmentIndex    = UISegmentedControlNoSegment
        resetButton.backgroundColor = UIColor.whiteColor()
        resetButton.tintColor       = UIColor(rgb:0x880000)
        resetButton.layer.cornerRadius      = 4
        resetButton.layer.masksToBounds     = true
        resetButton.addTarget(self, action:"resetButtonPressed:", forControlEvents:.ValueChanged)
        
        // add auto layout constraints
        var nslcs = NSLC(parent:view)
        nslcs += ["done" : doneButton, "title" : titleLabel, "scoreLabel" : scoreLabel, "howToLabel" : howToLabel, "resetButton" : resetButton]
        
        nslcs += "H:[done(>=50)]-|"
        nslcs += "H:|[title]|"
        nslcs += "H:|[scoreLabel]|"
        nslcs += "H:|-(>=5)-[howToLabel(<=260@800)]-(>=5)-|"
        nslcs += "V:[done(>=35)][title]-20-[scoreLabel]-20-[howToLabel]-(>=10)-[resetButton]-(>=5,30@900)-|"
        
        nslcs += NSLC.EQ(howToLabel, attr1:.CenterX, item2:view, attr2:.CenterX)
        nslcs += NSLC.EQ(resetButton, attr1:.CenterX, item2:view, attr2:.CenterX)
        nslcs += NSLC.EQ(doneButton, attr1:.Top, item2:self.topLayoutGuide, attr2:.Bottom);
        
        resetButton.setLayoutWidth(120)
    }
    
    override func viewWillAppear(animated: Bool) {
        let nSeen  = scores.numberOfStatesSeen()
        let nDays  = scores.nDaysElapsed()
        let states = (nSeen == 1) ? "state" : "states"
        let days   = (nDays == 1) ? "day" : "days"
        
        scoreLabel.text = "You have seen \(nSeen) \(states) in \(nDays) \(days)."
    }
    
    func doneButtonPressed(button: UIButton) {
        self.dismissViewControllerAnimated(true, completion:nil)
    }

    func resetButtonPressed(control: UISegmentedControl) {
        self.resetButton.selectedSegmentIndex = UISegmentedControlNoSegment

        let cancelAction = GMAlertAction(title: "Cancel")
        let resetAction  = GMAlertAction(title: "Reset All")
        resetAction.buttonPressed = {
            self.scores.resetAll()
            self.dismissViewControllerAnimated(true, completion:nil)
        }
        
        let message = "This will reset the \(scores.numberOfStatesSeen()) states you have collected.  Are you sure you want to erase everything and start over?"
        
        let alert = GMAlertView(title: "Reset All States", message: message, cancelAction: cancelAction, otherAction: resetAction);
        alert.show();
    }
    
}