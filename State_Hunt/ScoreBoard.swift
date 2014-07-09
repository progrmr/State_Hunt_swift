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
    
    typealias StateIndex = Int          // 50 states, index 0..49
    typealias StateName  = String       // Mixed case, full name of state
    typealias StateCode  = String       // 2 letter uppercase state code

    typealias DateDictionary = Dictionary<StateCode,NSDate>

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
    
    // State Storage for persistent state data
    let saver            = StateSaver()             // reads file if there
    
    // Array of 2 letter state codes sorted by the state's full name
    let stateCodes       : Array<StateCode>
    
    // Dictionary keyed by state code containing the NSDate when it was seen
    var dateSeenForCode  : DateDictionary
    
    // Dictionary keyed by state code containing the AGSGraphic for each state
    let stateGraphics  : Dictionary<StateCode,AGSGraphic>
    
    //------------------------------------------
    // initializers
    //------------------------------------------
    init() {
        stateCodes = stateNameForCode.keysSortedByValue(<)
        dateSeenForCode = DateDictionary()
        
        // read the states_geometry.plist file from the bundle
        let bundlePath = NSBundle.mainBundle().bundlePath
        let statesFilePath = bundlePath.stringByAppendingPathComponent("states_geometry.plist")
        let geoData = NSMutableDictionary(contentsOfFile: statesFilePath)
        var tmpGeoDict = Dictionary<StateCode,AGSGraphic>()
        let sr102100 = AGSSpatialReference(WKID: 102100)
        
        for (stateCode, geometryJSON) in geoData {
            println("\(stateCode) with \(geometryJSON.count)")
            
            let json = geometryJSON as [NSObject:AnyObject]
            let geo  = AGSGeometry(JSON: json, spatialReference: sr102100) as AGSGeometry
            let code = stateCode as StateCode
            let graphic = AGSGraphic(geometry: geo, symbol: nil, attributes: nil)
            tmpGeoDict[code] = graphic
        }
        
        stateGraphics = tmpGeoDict
        
        
        // Previous version of the app used StateSaver to save dates states
        // were seen.  Try to read that file now.
        if saver.count() > 0 {
            // look for the 50 states in the saved state data
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
    
    func stateCodeForName(name: StateName) -> StateCode? {
        for (stateCode:StateCode, stateName:StateName) in stateNameForCode {
            if name == stateName {
                return stateCode;
            }
        }
        return nil
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
        
        // mark state seen with current date/time
        let now = NSDate()
        dateSeenForCode[stateCode] = now
        
        // save datesSeenForCode to state data
        let dateNum = NSNumber(double: now.timeIntervalSinceReferenceDate)
        saver.setObject(dateNum, forKey:stateCode)
        saver.synchronize()
    }
    
    func unmarkStateSeen(index: StateIndex) {
        let stateCode = stateCodeForIndex(index)
       
        if let date : NSDate = dateSeenForCode.removeValueForKey(stateCode) {
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
        for i in 0 ..< numberOfStates() {
            unmarkStateSeen(i)
        }
    }
    
}



