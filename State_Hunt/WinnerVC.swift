//
//  WinnerVC.swift
//  State_Hunt
//
//  Created by Gary Morris on 7/5/14.
//  Copyright (c) 2014 Gary Morris. All rights reserved.
//

import Foundation
import UIKit
import QuartzCore

class WinnerVC : UIViewController {
    
    // views
    let titleLabel   = UILabel()
    let scoreLabel   = UILabel()
    let doneButton   = UIButton()
    
    // sound effects
    let applauseSound = SoundFX(filePath: "applause", ofType: "mp3")
    let cheerSound    = SoundFX(filePath: "cheer_8k", ofType: "wav")
    let crowdSound    = SoundFX(filePath: "crowd_homerun_applause", ofType: "wav")

    var scores : ScoreBoard
    
    init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!, scoreBoard: ScoreBoard) {
        scores  = scoreBoard
        
        super.init(nibName:nibNameOrNil, bundle:nibBundleOrNil)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func loadView() {
        let theme = Theme.currentTheme
        
        // create the root UIView
        view = UIView()
        view.autoresizingMask       = .FlexibleWidth | .FlexibleHeight
        view.userInteractionEnabled = true
        view.backgroundColor        = UIColor(rgb: 0xE4AF5F)

        // create the inner redView
        let redView = UIView()
        redView.backgroundColor     = UIColor(rgb: 0xff0000)
        redView.autoresizingMask    = .FlexibleWidth | .FlexibleHeight
        redView.userInteractionEnabled = true
    
        // auto layout for redView inside main view
        var viewNSLC = NSLC(parent: view, metrics: ["inset": 10])
        viewNSLC += ["red": redView]
        viewNSLC += "H:|-inset-[red]-inset-|"
        viewNSLC += "V:|-inset-[red]-inset-|"
        
        // add the title label
        titleLabel.backgroundColor  = UIColor.clearColor()
        titleLabel.textColor        = UIColor.whiteColor()
        titleLabel.text             = "Winner!!!"
        titleLabel.textAlignment    = .Center
        titleLabel.font             = UIFont(name: "Helvetica Bold Oblique", size: 48)

        // add the score label
        scoreLabel.backgroundColor  = titleLabel.backgroundColor
        scoreLabel.textColor        = UIColor.whiteColor()
        let days = scores.nDaysElapsed() == 1 ? "day" : "days"
        scoreLabel.text             = "You saw all \(kStateCount) states in just \(scores.nDaysElapsed()) \(days)!"
        scoreLabel.textAlignment    = .Center
        scoreLabel.numberOfLines    = 2
        scoreLabel.font             = UIFont.systemFontOfSize(24)
        
        // add the done button
        doneButton.backgroundColor  = titleLabel.backgroundColor
        doneButton.setTitle("Done", forState: .Normal)
        doneButton.setTitleColor(theme.kButtonTintColor, forState: .Normal)
        doneButton.addTarget(self, action:"doneButtonPressed:", forControlEvents:.TouchUpInside)
        
        // add the trophy view
        let trophyImage = UIImage(named: "trophy")
        let trophyView  = UIImageView(image: trophyImage)
        
        // add auto layout constraints and subviews for redView
        var nslcs = NSLC(parent:redView, metrics: viewNSLC.metrics)
        nslcs += ["done": doneButton, "title": titleLabel, "scoreLabel": scoreLabel, "trophy": trophyView]
        
        nslcs += "H:[done(50)]-inset-|"
        nslcs += "H:|-inset-[title]-inset-|"
        nslcs += "H:|-inset-[scoreLabel]-inset-|"
        nslcs += "V:|-inset-[done(35)]-25-[title]-25-[scoreLabel]-(>=20)-[trophy]-(75@800)-|"
        
        nslcs += NSLC.EQ(trophyView, attr1:.CenterX, item2:redView, attr2:.CenterX)
        nslcs += NSLC.EQ(trophyView, attr1:.Height, item2:trophyView, attr2:.Width)
        
        trophyView.setLayoutWidth(150)
    }
    
    override func viewDidAppear(animated: Bool) {
        titleLabel.layer.addAnimation(CAAnimation.shakeAnimation(), forKey: "shake")

        applauseSound.play()
        cheerSound.playAfterDelay(1)
        crowdSound.playAfterDelay(4)
        cheerSound.playAfterDelay(8)
        applauseSound.playAfterDelay(11)
    }
    
    func doneButtonPressed(button: UIButton) {
        self.dismissViewControllerAnimated(true, completion:nil)
    }
    
}