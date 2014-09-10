//
//  StateData.swift
//  State_Hunt
//
//  Created by Gary Morris on 7/15/14.
//  Copyright (c) 2014 Gary Morris. All rights reserved.
//

import Foundation
import ArcGIS

let kStateCount = 50

typealias StateIndex = Int          // 50 states, index 0..49
typealias StateName  = String       // Mixed case, full name of state
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

// Array of 2 letter state codes sorted by the state's full name
let stateCodes : Array<StateCode> = {
    stateNameForCode.keysSortedByValue(<)
}()

// Dictionary keyed by state code containing the AGSGraphic for each state
let stateGraphics    : Dictionary<StateCode,AGSGraphic> = {
    // read the geometry data from the file in the bundle
    let statesFilePath  = NSBundle.mainBundle().bundlePath.stringByAppendingPathComponent("state_polygons.plist")
    let statePolygons   = NSMutableDictionary(contentsOfFile: statesFilePath)
    var result          = Dictionary<StateCode,AGSGraphic>(minimumCapacity: statePolygons.count)
    
    for (stateCode, polygonJSON) in statePolygons {
        if let code = stateCode as? StateCode {
            if let json = polygonJSON as? [NSObject:AnyObject] {
                let polygon = AGSPolygon.polygonWithJSON(json) as AGSGeometry
                result[code] = AGSGraphic(geometry: polygon, symbol: nil, attributes: nil)
            }
        }
    }
    return result
}()

class StateData {
    
}



