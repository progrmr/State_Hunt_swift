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

// -----------------------------------------------
// where "UPPER(STATE_NAME) = 'NORTH DAKOTA'"
// -----------------------------------------------
let kDemographicsURLString = "http://sampleserver1.arcgisonline.com/ArcGIS/rest/services/Demographics/ESRI_Census_USA/MapServer/5"

class ScoreBoard {
    
    typealias StateIndex = Int
    typealias StateName  = String
    typealias StateCode  = String       // 2 letter uppercase state code
    
    let stateNameForCode : Dictionary<StateCode,StateName> = [
            "AL" : "Alabama"        ,
            "AK" : "Alaska"         ,
            "AZ" : "Arizona"        ,
            "AR" : "Arkansas"       ,
            "CA" : "California"     ,
            "CO" : "Colorado"       ,
            "CT" : "Connecticut"    ,
            "DE" : "Delaware"       ,
            "FL" : "Florida"        ,
            "GA" : "Georgia"        ,
            "HI" : "Hawaii"         ,
            "ID" : "Idaho"          ,
            "IL" : "Illinois"       ,
            "IN" : "Indiana"        ,
            "IA" : "Iowa"           ,
            "KS" : "Kansas"         ,
            "KY" : "Kentucky"       ,
            "LA" : "Louisiana"      ,
            "ME" : "Maine"          ,
            "MD" : "Maryland"       ,
            "MA" : "Massachusetts"  ,
            "MI" : "Michigan"       ,
            "MN" : "Minnesota"      ,
            "MS" : "Mississippi"    ,
            "MO" : "Missouri"       ,
            "MT" : "Montana"        ,
            "NE" : "Nebraska"       ,
            "NV" : "Nevada"         ,
            "NH" : "New Hampshire"  ,
            "NJ" : "New Jersey"     ,
            "NM" : "New Mexico"     ,
            "NY" : "New York"       ,
            "NC" : "North Carolina" ,
            "ND" : "North Dakota"   ,
            "OH" : "Ohio"           ,
            "OK" : "Oklahoma"       ,
            "OR" : "Oregon"         ,
            "PA" : "Pennsylvania"   ,
            "RI" : "Rhode Island"   ,
            "SC" : "South Carolina" ,
            "SD" : "South Dakota"   ,
            "TN" : "Tennessee"      ,
            "TX" : "Texas"          ,
            "UT" : "Utah"           ,
            "VT" : "Vermont"        ,
            "VA" : "Virginia"       ,
            "WA" : "Washington"     ,
            "WV" : "West Virginia"  ,
            "WI" : "Wisconsin"      ,
            "WY" : "Wyoming"        ]
    
    // Array of 2 letter state codes sorted by the states full name
    let stateCodes       : Array<StateCode>
    
    // Dictionary keyed by state code containing the NSDate when it was seen
    typealias DateDictionary = Dictionary<StateCode,NSDate>
    var dateSeenForCode  : DateDictionary
    
    //------------------------------------------
    // initializers
    //------------------------------------------
    init() {
        stateCodes = stateNameForCode.keysSortedByValue(<)
        
        // load datesSeenForCode from NSUserDefaults
        let defaults = NSUserDefaults.standardUserDefaults()
        let datesDictOptional: DateDictionary? = defaults.objectForKey(kDefaultsDateSeenKey) as? DateDictionary
        
        if let datesDict = datesDictOptional {
            dateSeenForCode = datesDict
        } else {
            dateSeenForCode = DateDictionary()
        }
    }
    
    //------------------------------------------
    // methods
    //------------------------------------------
    func numberOfStates(Void) -> Int {
        return stateCodes.count
    }
    
    func numberOfStatesSeen(Void) -> Int {
        return dateSeenForCode.count
    }
    
    func stateNameForIndex(index: StateIndex) -> StateName {
        let stateCode : StateCode = stateCodeForIndex(index)
        let stateName : StateName = stateNameForCode[stateCode]!
        return stateName
    }
    
    func stateCodeForIndex(index: StateIndex) -> StateCode {
        return stateCodes[index]
    }
    
    func dateSeen(index: StateIndex) -> NSDate? {
        let stateCode = stateCodeForIndex(index)
        return dateSeenForCode[stateCode]
    }
    
    func wasSeen(index: StateIndex) -> Bool {
        let date = dateSeen(index)
        return date != nil
    }
    
    func markStateSeen(index: StateIndex) {
        let stateCode = stateCodeForIndex(index)
        let date = dateSeenForCode[stateCode]
        
        if (date == nil) {
            // state hasn't been seen yet, mark it now
            dateSeenForCode[stateCode] = NSDate()
            
            // save datesSeenForCode to NSUserDefaults
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setObject(dateSeenForCode, forKey:kDefaultsDateSeenKey)
            defaults.synchronize()
        }
    }
    
    func unmarkStateSeen(index: StateIndex) {
        let stateCode = stateCodeForIndex(index)
       
        if let date = dateSeenForCode.removeValueForKey(stateCode) {
            // save datesSeenForCode to NSUserDefaults
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setObject(dateSeenForCode, forKey:kDefaultsDateSeenKey)
            defaults.synchronize()
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
        for i in 0 ... numberOfStates()-1 {
            unmarkStateSeen(i)
        }
    }
    
}



