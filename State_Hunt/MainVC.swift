//
//  ViewController.swift
//  State_Hunt
//
//  Created by Gary Morris on 7/1/14.
//  Copyright (c) 2014 Gary Morris. All rights reserved.
//

import UIKit
import Foundation
import ArcGIS

//let tiledServiceURLString = "http://services.arcgisonline.com/ArcGIS/rest/services/ESRI_StreetMap_World_2D/MapServer"
let tiledServiceURLString = "http://services.arcgisonline.com/ArcGIS/rest/services/NatGeo_World_Map/MapServer"

// http://sampleserver1.arcgisonline.com/ArcGIS/rest/services/Demographics/ESRI_Census_USA/MapServer/5
// where "UPPER(STATE_NAME) = 'NORTH DAKOTA'"

let kStateCellReuseId   = "kStateCellReuseId"
let kHeaderViewReuseId  = "kHeaderViewReuseId"
let kInitialLatLong     = (lat: 39.0, long: -96.0)
let kMapScaleInitial    = 150_000_000.0
let kMapScaleMinimum    = 300_000_000.0
let kMapScaleMaximum    =   2_000_000.0

class MainVC: UIViewController, AGSLayerDelegate, UICollectionViewDataSource, UICollectionViewDelegate, AGSQueryTaskDelegate {
    
    // views
    var listView    : UICollectionView?
    var mapView     : AGSMapView?
    var headerView  : HeaderView?
    
    // map layers
    var tiledLayer  : AGSTiledMapServiceLayer?
    
    let dateFormatter = NSDateFormatter()
    var showDetails   = false
    var scores        = ScoreBoard()
    
    var clickSound    : SoundFX?
    var doorSound     : SoundFX?
    var cheerSound    : SoundFX?
    var applauseSound : SoundFX?
    var oohSound      : SoundFX?
    
    // statesGeometry keyed by StateCode
    var stateGeometry : Dictionary<ScoreBoard.StateCode,AGSGeometry> = Dictionary()
    var stateQueries  : Dictionary<ScoreBoard.StateCode,NSOperation> = Dictionary()
    
    init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!)
    {
        // property init goes here
        dateFormatter.locale    = NSLocale.currentLocale()
        dateFormatter.dateStyle = .ShortStyle
        dateFormatter.timeStyle = .NoStyle
        
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil);
    }
    
    override func loadView() {
        let theme = Theme.currentTheme
        
        // create the root UIView
        view = UIView()
        view.autoresizingMask       = .FlexibleWidth | .FlexibleHeight
        view.userInteractionEnabled = true
       
        // add the map view
        let mapView = AGSMapView()
        self.mapView = mapView
        mapView.backgroundColor         = UIColor.grayColor()
        mapView.allowRotationByPinching = true
        mapView.allowMagnifierToPanMap  = false
        mapView.allowCallout            = false
        mapView.minScale                = kMapScaleMinimum
        mapView.maxScale                = kMapScaleMaximum
        mapView.enableWrapAround()
        
        // add a tiled layer to the map
        let tiledServiceURL = NSURL(string: tiledServiceURLString)
        let tiledLayer = AGSTiledMapServiceLayer.tiledMapServiceLayerWithURL(tiledServiceURL) as AGSTiledMapServiceLayer
        self.tiledLayer = tiledLayer
        tiledLayer.delegate = self
        mapView.addMapLayer(tiledLayer)
        
        // add status bar backdrop
        let backdrop = UIView()
        backdrop.backgroundColor = UIColor(white: 1, alpha: 0.5)
        
        // add blur visual effect to the backdrop
        var visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .Light))
        visualEffectView.frame = backdrop.bounds
        visualEffectView.autoresizingMask = .FlexibleWidth | .FlexibleHeight
        backdrop.addSubview(visualEffectView)
        
        // add the list of states collection view
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset            = UIEdgeInsetsMake(2, 2, 0, 2)
        layout.scrollDirection         = .Vertical
        layout.minimumLineSpacing      = 3;
        layout.minimumInteritemSpacing = 3;
        layout.itemSize                = CGSizeMake(103,35)
        layout.headerReferenceSize     = CGSizeMake(0, 35)
        
        let listView = UICollectionView(frame: CGRectZero, collectionViewLayout: layout)
        self.listView = listView
        listView.backgroundColor = theme.kBackgroundColor
        listView.registerClass(StateCell.self, forCellWithReuseIdentifier: kStateCellReuseId)
        listView.registerClass(HeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: kHeaderViewReuseId)
        listView.dataSource      = self;
        listView.delegate        = self;
        
        // define layout constraints dictionary
        var nslc = NSLC(parent:view)
        nslc += ["backdrop" : backdrop, "map" : mapView, "list" : listView]

        nslc += "H:|[list]|"
        nslc += "H:|[map]|"
        nslc += "H:|[backdrop]|"
        nslc += "V:|[backdrop]"
        nslc += "V:|[map(>=160)][list]|"
        nslc += NSLC.EQ(mapView, attr1:.Height, multiplier:0.4, item2:view, attr2:.Height, priority: 900)
        nslc += NSLC.EQ(backdrop, attr1:.Bottom, item2:self.topLayoutGuide, attr2:.Bottom)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view....
        
        if clickSound == nil {
            clickSound = SoundFX(filePath:"click", ofType:"wav")
        }
        if doorSound == nil {
            doorSound = SoundFX(filePath:"close_door2", ofType:"wav")
        }
    }

    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        
        listView?.reloadData()
    }
    
    func markNewStateSeen(stateIndex: ScoreBoard.StateIndex) {
        // set the seen flag for that state row
        setState(stateIndex, seen:true)
        clickSound?.play()
        
        let numSeen = scores.numberOfStatesSeen()
        var oMessage : String?
        
        switch numSeen {
        case scores.numberOfStates():
            //--------------------------------------
            // All states seen, we have a WINNER!
            //--------------------------------------
            let winnerVC = WinnerVC(nibName:"WinnerVC", bundle:nil, scoreBoard:scores)
            
            self.presentModalViewController(winnerVC, animated: true)
            
        case 45:
            oMessage        = "Super Fantastic, you've seen \(numSeen) states!  Only a few hard to get states left."
            cheerSound      = SoundFX(filePath:"cheer_8k", ofType:"wav", play: true)
            oohSound        = SoundFX(filePath:"ooh", ofType:"mp3", play:true)
        case 40:
            oMessage        = "Fantastic, you've seen \(numSeen) states!  Not many left now."
            cheerSound      = SoundFX(filePath:"cheer_8k", ofType:"wav", play: true)
        case 35:
            oMessage        = "Awesome, you've seen \(numSeen) states!  You have sharp eyes."
            oohSound        = SoundFX(filePath:"ooh", ofType:"mp3", play:true)
        case 30:
            oMessage        = "Amazing, you've collected \(numSeen) states! You're doing great."
            applauseSound   = SoundFX(filePath:"applause", ofType:"mp3", play:true)
        case 25:
            oMessage        = "Fantastic, you've seen \(numSeen) states! That's half the country!"
            cheerSound      = SoundFX(filePath:"cheer_8k", ofType:"wav", play: true)
        case 20:
            oMessage        = "Wow, you've seen \(numSeen) states so far!"
            applauseSound   = SoundFX(filePath:"applause", ofType:"mp3", play:true)
            oohSound        = SoundFX(filePath:"ooh", ofType:"mp3", play:true)
        case 15:
            oMessage        = "Great, you're up to \(numSeen) states!"
            oohSound        = SoundFX(filePath:"ooh", ofType:"mp3", play:true)
        case 10:
            oMessage        = "Very good, you've got \(numSeen) states!  Great progress."
            applauseSound   = SoundFX(filePath:"applause", ofType:"mp3", play:true)
        case 5:
            oMessage        = "That's a great start, you've seen \(numSeen) states!"
            oohSound        = SoundFX(filePath:"ooh", ofType:"mp3", play:true)
        default:
            break
        }
        
        if let message = oMessage {
            let alert = UIAlertController(title:"\(numSeen) States", message:message, preferredStyle:.Alert)
            
            alert.addAction(UIAlertAction(title:"OK", style:.Default,
                handler: {(action: UIAlertAction!) in
                    /* do nothing */
                }))
            
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func unmarkStateSeen(stateIndex: ScoreBoard.StateIndex) {
        let dateSeen  = scores.dateSeen(stateIndex)
        let timeSinceSeen = NSDate() - dateSeen!
        
        if (timeSinceSeen < 300) {
            // they just saw this within the past few minutes, go ahead an unmark it without asking
            self.setState(stateIndex, seen:false)
            self.clickSound?.play()
            
        } else {
            // it's been a while since this was marked, ask before unmarking it
            let dateFmtr       = NSDateFormatter()
            dateFmtr.locale    = NSLocale.currentLocale()
            dateFmtr.dateStyle = .MediumStyle
            dateFmtr.timeStyle = .ShortStyle
            
            let dateStr   = dateFmtr.stringFromDate(dateSeen)
            let stateName = scores.stateNameForIndex(stateIndex)
            let message   = "You've saw \(stateName) on \(dateStr), do you really want to undo this?"
            
            let alert = UIAlertController(title:"Remove \(stateName)?", message:message, preferredStyle:.Alert)
            
            let cancelAction = UIAlertAction(title:"No", style:.Cancel,
                handler: {(action: UIAlertAction!) in
                    println("title: \(action.title)")
                })
            
            let yesAction = UIAlertAction(title:"Yes", style:.Default,
                handler: {(action: UIAlertAction!) in
                    self.setState(stateIndex, seen:false)
                    self.clickSound?.play()
                })
            
            alert.addAction(cancelAction)
            alert.addAction(yesAction)
            
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    //------------------------------------------
    // AGSLayerDelegate methods
    //------------------------------------------
    func layerDidLoad(layer: AGSLayer!) {
        // TBD
        NSLog("layerDidLoad: %@", layer.name)
        
        var center = AGSPoint(x:kInitialLatLong.long, y:kInitialLatLong.lat, spatialReference: AGSSpatialReference.wgs84SpatialReference())
        let engine = AGSGeometryEngine.defaultGeometryEngine()
        center = engine.projectGeometry(center, toSpatialReference: mapView!.spatialReference) as AGSPoint
        mapView!.zoomToScale(kMapScaleInitial, withCenterPoint: center, animated: true)
    }

    //------------------------------------------
    // UIButton event handlers
    //------------------------------------------
    func showAllButtonPressed() {
        showDetails = !showDetails
        
        headerView!.showAllButton.selected = showDetails
        
        var indexPaths = Array<NSIndexPath>()
        
        for row in 0..scores.stateCodes.count-1 {
            let code = scores.stateCodes[row]
            if let date = scores.dateSeenForCode[code] {
                let indexPath = NSIndexPath(forRow:row, inSection:0)
                indexPaths += indexPath
            }
        }
        
        if indexPaths.count > 0 {
            listView!.reloadItemsAtIndexPaths(indexPaths)
        }
        
        if scores.numberOfStatesSeen() > 0 {
            doorSound?.play()
        }

    }

    func infoButtonPressed() {
        let settingsVC = SettingsVC(nibName: nil, bundle: nil, scoreBoard: scores)
        self.presentModalViewController(settingsVC, animated:true)
    }
    
    //------------------------------------------
    // UICollectionViewDelegateFlowLayout methods
    //------------------------------------------
    func collectionView(collectionView: UICollectionView!, layout:UICollectionViewLayout!, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let row         = indexPath.row;
        let notSeenYet  = !scores.wasSeen(row)
        
        if (notSeenYet || showDetails) {
            return CGSizeMake(103,35)
        } else {
            return CGSizeMake(35, 35)
        }
    }

    //------------------------------------------
    // UICollectionViewDataSource methods
    // UICollectionViewDelegate   methods
    //------------------------------------------
    func numberOfSectionsInCollectionView(collectionView: UICollectionView!) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView!, numberOfItemsInSection: Int) -> Int {
        return scores.numberOfStates()
    }
    
    func collectionView(collectionView: UICollectionView!, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell! {
        let theme   = Theme.currentTheme
        let row     = indexPath.row;
        let seen    = scores.wasSeen(row)
        var cell    = listView!.dequeueReusableCellWithReuseIdentifier(kStateCellReuseId, forIndexPath: indexPath) as StateCell
        
        if (seen) {
            // State HAS been seen
            cell.contentView.backgroundColor    = theme.kSeenBackgroundColor
            cell.titleLabel.backgroundColor     = theme.kSeenBackgroundColor
            cell.titleLabel.textColor           = theme.kSeenTextColor
            
            if (showDetails) {
                let dateSeen = scores.dateSeen(row)
                cell.titleLabel.text            = scores.stateNameForIndex(row)
                cell.detailLabel.text           = dateFormatter.stringFromDate(dateSeen)
                cell.detailLabel.backgroundColor = theme.kSeenBackgroundColor
                cell.detailLabel.textColor       = theme.kSeenTextColor
                
            } else {
                cell.titleLabel.text            = scores.stateCodeForIndex(row)
            }
            
        } else {
            // State has NOT been seen
            cell.titleLabel.text                = scores.stateNameForIndex(row)
        }
        
        return cell;
    }
    
    func collectionView(collectionView: UICollectionView!, viewForSupplementaryElementOfKind kind: String!, atIndexPath indexPath: NSIndexPath!) -> UICollectionReusableView!
    {
        let theme = Theme.currentTheme
        
        let header = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: kHeaderViewReuseId, forIndexPath: indexPath) as HeaderView
        headerView = header         // save ref to header view so we can update it
        headerView!.backgroundColor = theme.kBackgroundColor
        headerView!.setScore(scores.numberOfStatesSeen())
        headerView!.showAllButton.addTarget(self, action:"showAllButtonPressed", forControlEvents:.TouchUpInside)
        headerView!.infoButton.addTarget(self, action:"infoButtonPressed", forControlEvents:.TouchUpInside)
        return header;
    }
    
    func collectionView(collectionView: UICollectionView!, shouldSelectItemAtIndexPath indexPath: NSIndexPath!) -> Bool {
        let row   = indexPath.row
        let seen  = scores.wasSeen(row)
        
        if (seen) {
            unmarkStateSeen(row)
        } else {
            markNewStateSeen(row)
        }
        
        return false;		// never select cells
    }
    
    func setState(index: ScoreBoard.StateIndex, seen: Bool) {
        if seen {
            // hasn't been seen before, set it to "seen"
            scores.markStateSeen(index)
            
        } else {
            // Mark a "seen" state back to "unseen"
            scores.unmarkStateSeen(index)
        }

        // fetch geometry for the state (if necessary)
        self.fetchGeometryForState(index)
        
        // update cell in table
        let indexPath = NSIndexPath(forRow:index, inSection: 0)
        listView!.reloadItemsAtIndexPaths([indexPath])
        
        // update header view in table
        headerView!.setScore(scores.numberOfStatesSeen())
    }
    
    func fetchGeometryForState(index: ScoreBoard.StateIndex) {
        let stateCode = scores.stateCodeForIndex(index)
        
        if stateGeometry[stateCode] == nil && stateQueries[stateCode] == nil {
            let stateName = scores.stateNameForCode[stateCode]
            let query = AGSQuery()
            query.returnGeometry        = true
            query.outSpatialReference   = mapView!.spatialReference
            query.`where`               = "where STATE_NAME = California"  //"where STATE_NAME = '\(stateName)'"
            query.outFields             = ["*"];
            
            let demoURL   = NSURL(string: kDemographicsURLString)
            let queryTask = AGSQueryTask(URL: demoURL)
            queryTask.delegate = self
            
            stateQueries[stateCode] = queryTask.executeWithQuery(query)
        }
    }
    
    //------------------------------------------
    // AGSQueryTaskDelegate methods
    //------------------------------------------
    func queryTask(queryTask: AGSQueryTask!, operation op: NSOperation!, didExecuteWithFeatureSetResult featureSet: AGSFeatureSet!) {
        NSLog("queryTask done")
    }
    
    func queryTask(queryTask: AGSQueryTask!, operation op: NSOperation!, didFailWithError error: NSError!) {
        NSLog("queryTask FAIL")
    }
    
}

