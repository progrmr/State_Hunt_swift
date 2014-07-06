//
//  NSDate+Operators.swift
//  State_Hunt
//
//  Created by Gary Morris on 7/3/14.
//  Copyright (c) 2014 Gary Morris. All rights reserved.
//

import Foundation

//-----------------------------------------------------
// Comparison operators for NSDate:
//     <  >  <=  >=  ==
//
// Arithmetic operators for NSDate:
//     +  -
//-----------------------------------------------------
func < (left: NSDate, right: NSDate) -> Bool {
    let result : NSComparisonResult = left.compare(right)
    return (result == .OrderedAscending)
}

func > (left: NSDate, right: NSDate) -> Bool {
    let result : NSComparisonResult = left.compare(right)
    return (result == .OrderedDescending)
}

func == (left: NSDate, right: NSDate) -> Bool {
    return left.isEqualToDate(right)
}

func <= (left: NSDate, right: NSDate) -> Bool {
    return !(left > right)
}

func >= (left: NSDate, right: NSDate) -> Bool {
    return !(left < right)
}

func - (left: NSDate, right: NSDate) -> NSTimeInterval {
    return left.timeIntervalSinceDate(right)
}

func + (left: NSDate, right: NSTimeInterval) -> NSDate {
    return left.dateByAddingTimeInterval(right)
}

func + (left: NSTimeInterval, right: NSDate) -> NSDate {
    return right.dateByAddingTimeInterval(left)
}