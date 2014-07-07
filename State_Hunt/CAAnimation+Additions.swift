//
//  CAAnimation+Additions.swift
//  State_Hunt
//
//  Created by Gary Morris on 7/6/14.
//  Copyright (c) 2014 Gary Morris. All rights reserved.
//

import QuartzCore

func radiansFromDegrees(degrees: Double) -> Double {
    return degrees * M_PI / 180.0
}

extension CAAnimation {
   
    class func shakeAnimation(duration: NSTimeInterval = 0.25, repeatCount: CFloat = 60, rotationAngle: Double = 3.0) -> CAAnimation
    {
        let animation = CAKeyframeAnimation(keyPath: "transform.rotation.z")
        
        animation.duration      = duration
        animation.repeatCount   = repeatCount
        animation.values        = [radiansFromDegrees(-rotationAngle), radiansFromDegrees(rotationAngle), radiansFromDegrees(-rotationAngle)]
        
        return animation
    }

}

