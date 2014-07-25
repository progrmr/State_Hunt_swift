//
//  ScoreBoard.swift
//  State_Hunt
//
//  Created by Gary Morris on 7/2/14.
//  Copyright (c) 2014 Gary Morris. All rights reserved.
//

import Foundation
import ArcGIS

let kDefaultsDateSeenKey = "kDefaultsDateSeenKey"

class ScoreBoard {
    
    typealias DateDictionary = Dictionary<StateCode,NSDate>

    // State Storage for persistent state data
    let saver            = StateSaver()             // reads file if there
    
    // Dictionary keyed by state code containing the NSDate when it was seen
    var dateSeenForCode  = DateDictionary(minimumCapacity: kStateCount)
    
    //------------------------------------------
    // initializers
    //------------------------------------------
    init() {
        // check to see if we have previously saved any state data
        if saver.count() > 0 {
            for stateCode in stateCodes {
                let object : AnyObject? = saver.objectForKey(stateCode)
                
                // read the NSNumber of the NSDate's time interval since the reference date
                if let dateNum = object as? NSNumber {
                    let dateVal : Double = dateNum.doubleValue
                    dateSeenForCode[stateCode] = NSDate(timeIntervalSinceReferenceDate: dateVal)
                }
            }
        }
    }
    
    //------------------------------------------
    // methods
    //------------------------------------------
    func numberOfStatesSeen(Void) -> Int {
        return dateSeenForCode.count
    }
    
    func dateSeen(stateCode: StateCode) -> NSDate? {
        return dateSeenForCode[stateCode]
    }
    
    func wasSeen(stateCode: StateCode) -> Bool {
        let date = dateSeen(stateCode)
        return date != nil
    }
    
    func markStateSeen(stateCode: StateCode) {
        // mark state seen with current date/time
        let now = NSDate()
        dateSeenForCode[stateCode] = now
        
        // save datesSeenForCode to state data
        let dateNum = NSNumber(double: now.timeIntervalSinceReferenceDate)
        saver.setObject(dateNum, forKey:stateCode)
        saver.synchronize()
    }
    
    func unmarkStateSeen(stateCode: StateCode) {
        if let date = dateSeenForCode.removeValueForKey(stateCode) {
            // remove date seen from the saved state data
            saver.setObject(nil, forKey:stateCode)
            saver.synchronize()
        }
    }
    
    func nDaysElapsed(Void) -> Int {
        let now = NSDate()
        var earliestSeen: NSDate = now
        
        for (stateCode, dateSeen) in dateSeenForCode {
            if (dateSeen < earliestSeen) {
                // this date is earlier, update earliestSeen
                earliestSeen = dateSeen
            }
        }
        
        let secondsSinceEarliest = Int64(now - earliestSeen)
        let secondsPerDay        = Int64(24*60*60)
        // round up to the next day using addition and integer truncation
        let numberOfDays         = (secondsSinceEarliest + (secondsPerDay-1)) / secondsPerDay
        
        return Int(numberOfDays)
    }

    func resetAll() {
        for (stateCode, dateSeen) in dateSeenForCode {
            unmarkStateSeen(stateCode)
        }
    }
    
}



