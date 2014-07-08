//
//  SoundFX.swift
//  State_Hunt
//
//  Created by Gary Morris on 7/4/14.
//  Copyright (c) 2014 Gary Morris. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

let s_avSession : AVAudioSession = AVAudioSession.sharedInstance()
var s_avSessionInitialized = false
var s_avSessionReady = false

class SoundFX {
    
    let audioFileURL    : NSURL
    var audioPlayer     : AVAudioPlayer?
    var lastPlayed      : NSDate?
    
    init(filePath:String, ofType suffix:String, play:Bool = false) {
        let path = NSBundle.mainBundle().pathForResource(filePath, ofType:suffix)
        audioFileURL = NSURL(fileURLWithPath:path)
        
        let dispatchInit = !s_avSessionInitialized
        
        if dispatchInit {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
                // activate the audio session, takes a bit of time:
                s_avSession.setCategory(AVAudioSessionCategoryAmbient, error: nil)
                s_avSession.setActive(true, error:nil)
                s_avSessionReady = true
                
                // play the sound now that session is ready
                if (play) {
                    dispatch_async(dispatch_get_main_queue()) {
                        self.play()
                    }
                }
            }
            s_avSessionInitialized = true;
        }
        
        if play && !dispatchInit {
            self.play()
        }
    }

    func play() {
        if (audioPlayer == nil) {
            audioPlayer = AVAudioPlayer(contentsOfURL:audioFileURL, error:nil)
        }
        
        audioPlayer!.currentTime = 0
        audioPlayer!.volume      = 1.0;
        
        var success = true
        if !audioPlayer!.playing {
            success = audioPlayer!.play()

            if success {
                lastPlayed = NSDate()
            }
        }
    }
    
    func playAfterDelay(seconds: NSTimeInterval) {
        let delay = seconds * Double(NSEC_PER_SEC)
        let time  = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        dispatch_after(time, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
            self.play()
        }
    }
    
    func playUnlessPlayedWithin(seconds: NSTimeInterval) {
        if !wasPlayedWithin(seconds) {
            play()
        }
    }
    
    func wasPlayedWithin(seconds: NSTimeInterval) -> Bool {
        if let dateLastPlayed = lastPlayed {
            return (NSDate() - dateLastPlayed) < seconds
        } else {
            return false
        }
    }

}