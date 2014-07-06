//
//  AppDelegate.swift
//  State_Hunt
//
//  Created by Gary Morris on 7/1/14.
//  Copyright (c) 2014 Gary Morris. All rights reserved.
//

import UIKit
import Foundation
import ArcGIS

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate {
                            
    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: NSDictionary?) -> Bool {
        // initialize ArcGIS client id
//        let clientID = "replace this with your client id"
//        AGSRuntimeEnvironment.setClientID(clientID, error: nil)
        
        // Override point for customization after application launch.
        let w = UIWindow()
        w.frame              = UIScreen.mainScreen().bounds
        w.rootViewController = MainVC(nibName: nil, bundle: nil)
        w.makeKeyAndVisible()
        window = w
        
        return true
    }

}

