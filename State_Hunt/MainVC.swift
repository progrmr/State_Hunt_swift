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
let kMapScaleMaximum    =   2_800_000.0

let kNormalFillRGBA     : UInt32 = 0x77ff7740
let kSelectedFillRGBA   : UInt32 = 0x77ff7780
let kNormalBorderRGBA   : UInt32 = 0x006600ff
let kSelectedBorderRGBA : UInt32 = 0x009900ff

class MainVC: UIViewController, AGSLayerDelegate, UICollectionViewDataSource, UICollectionViewDelegate, AGSQueryTaskDelegate {
    
    // views
    var listView    : UICollectionView?
    var flowLayout  : UICollectionViewFlowLayout!
    var cellSize    : CGSize
    
    var mapView     : AGSMapView?
    var headerView  : HeaderView?
    
    // map layers
    var tiledLayer    : AGSTiledMapServiceLayer?
    var graphicsLayer = AGSGraphicsLayer()
    
    let dateFormatter = NSDateFormatter()
    var showDetails   = false
    var scores        = ScoreBoard()
    
    let clickSound    = SoundFX(filePath:"click", ofType:"wav")
    let doorSound     = SoundFX(filePath:"close_door2", ofType:"wav")
    var cheerSound    : SoundFX?
    var applauseSound : SoundFX?
    var oohSound      : SoundFX?
    
    var statusBarHidden : Bool = true
    
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!)
    {
        // property init goes here
        dateFormatter.locale    = NSLocale.currentLocale()
        dateFormatter.dateStyle = .ShortStyle
        dateFormatter.timeStyle = .ShortStyle

        cellSize = CGSizeMake(103,35)
        
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil);
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        
        // add the graphics layer to the map
        mapView.addMapLayer(graphicsLayer)
        
        // add status bar backdrop
        let backdrop = UIView()
        backdrop.backgroundColor = UIColor(white: 1, alpha: 0.5)
        
//        // add blur visual effect to the backdrop
//        var visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .Light))
//        visualEffectView.frame = backdrop.bounds
//        visualEffectView.autoresizingMask = .FlexibleWidth | .FlexibleHeight
//        backdrop.addSubview(visualEffectView)
        
        // add the list of states collection view
        let layout = UICollectionViewFlowLayout()
        self.flowLayout = layout
        layout.sectionInset            = UIEdgeInsetsMake(2, 2, 0, 2)
        layout.scrollDirection         = .Vertical
        layout.minimumLineSpacing      = 3;
        layout.minimumInteritemSpacing = 3;
        layout.itemSize                = cellSize
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
        nslc += NSLC.EQ(mapView, attr1:.Height, multiplier:0.45, item2:view, attr2:.Height, priority: 900)
        nslc += NSLC.EQ(backdrop, attr1:.Bottom, item2:self.topLayoutGuide, attr2:.Bottom)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let size = view.bounds.size
        let width = size.width < size.height ? size.width : size.height
        
        if (width > 410) {
            // size cell to fit nicely on iPhone 6 plus
            cellSize = CGSizeMake(100,35)
            flowLayout.itemSize = cellSize
            flowLayout.invalidateLayout()
        } else if (width > 370) {
            // size cell to fit nicely on iPhone 6 
            cellSize = CGSizeMake(121,35)
            flowLayout.itemSize = cellSize
            flowLayout.invalidateLayout()
        }
        
        listView?.reloadData()
        
        // check to see if a resetAll has occurred
        if scores.numberOfStatesSeen() == 0 {
            self.graphicsLayer.removeAllGraphics()
            self.zoomToUnitedStates() 
        }
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return self.statusBarHidden
    }
    
    func markNewStateSeen(stateIndex: StateIndex) {
        // set the seen flag for that state row
        setState(stateIndex, seen:true)
        clickSound.play()
        
        let numSeen = scores.numberOfStatesSeen()
        var oMessage : String?
        
        switch numSeen {
        case kStateCount:
            //--------------------------------------
            // All states seen, we have a WINNER!
            //--------------------------------------
            let winnerVC = WinnerVC(nibName:"WinnerVC", bundle:nil, scoreBoard:scores)
            
            self.presentViewController(winnerVC, animated: true, completion:nil)
            
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
            let cancelAction = GMAlertAction(title: "Yes!")
            
            let alert = GMAlertView(title: "\(numSeen) States", message: message, cancelAction: cancelAction, otherAction: nil);
            alert.show();
        }
    }
    
    func unmarkStateSeen(stateIndex: StateIndex) {
        let stateCode = stateCodes[stateIndex]
        let dateSeen  = scores.dateSeen(stateCode) ?? NSDate()
        let timeSinceSeen = NSDate() - dateSeen
        
        if (timeSinceSeen < 30) {
            // they just saw this within the past few minutes, go ahead an unmark it without asking
            self.setState(stateIndex, seen:false)
            self.clickSound.play()
            
        } else {
            // it's been a while since this was marked, ask before unmarking it
            let dateFmtr       = NSDateFormatter()
            dateFmtr.locale    = NSLocale.currentLocale()
            dateFmtr.dateStyle = .MediumStyle
            dateFmtr.timeStyle = .ShortStyle
            
            let dateStr   = dateFmtr.stringFromDate(dateSeen)
            let stateName = stateNameForCode[stateCode]
            let message   = "You've saw \(stateName) on \(dateStr), do you really want to undo this?"
            
            let cancelAction = GMAlertAction(title: "No")
            let removeAction = GMAlertAction(title: "Remove")
            removeAction.buttonPressed = {
                self.setState(stateIndex, seen:false)
                self.clickSound.play()
            }
            
            let alert = GMAlertView(title: "Remove \(stateName)?", message: message, cancelAction: cancelAction, otherAction: removeAction);
            alert.show();
        }
    }
    
    //------------------------------------------
    // AGSLayerDelegate methods
    //------------------------------------------
    func layerDidLoad(layer: AGSLayer!) {
        NSLog("layerDidLoad: %@", layer.name)
        
        self.zoomToUnitedStates()
        
        // get geometries for all seen states and highlight them on the map
        for stateCode in stateCodes {
            if let date = scores.dateSeen(stateCode) {
                // highlight it on the map
                highlightStateGeometry(stateCode, zoom: false)
            }
        }
    }

    //------------------------------------------
    // UIButton event handlers
    //------------------------------------------
    func showAllButtonPressed() {
        showDetails = !showDetails
        
        headerView!.showAllButton.selected = showDetails
        headerView!.showAllButton.accessibilityLabel = showDetails ? "less detail" : "more detail"
        
        var indexPaths = Array<NSIndexPath>()
        
        for row in 0 ..< stateCodes.count {
            if let date = scores.dateSeen(stateCodes[row]) {
                indexPaths.append(NSIndexPath(forRow:row, inSection:0))
            }
        }
        
        if !indexPaths.isEmpty {
            listView!.reloadItemsAtIndexPaths(indexPaths)
        }
        
        if scores.numberOfStatesSeen() > 0 {
            doorSound.play()
        }

    }

    func infoButtonPressed() {
        let settingsVC = SettingsVC(nibName: nil, bundle: nil, scoreBoard: scores)
        self.presentViewController(settingsVC, animated: true, completion: nil)
    }
    
    //------------------------------------------
    // UICollectionViewDelegateFlowLayout methods
    //------------------------------------------
    func collectionView(collectionView: UICollectionView, layout:UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let row         = indexPath.row
        let stateCode   = stateCodes[row]
        let notSeenYet  = !scores.wasSeen(stateCode)
        
        if (notSeenYet || showDetails) {
            return cellSize
        } else {
            return CGSizeMake(35, 35)
        }
    }

    //------------------------------------------
    // UICollectionViewDataSource methods
    // UICollectionViewDelegate   methods
    //------------------------------------------
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection: Int) -> Int {
        return kStateCount
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let theme       = Theme.currentTheme
        let row         = indexPath.row;
        let stateCode   = stateCodes[row]
        let stateName   = stateNameForCode[stateCode]
        let seen        = scores.wasSeen(stateCode)
        var cell        = listView!.dequeueReusableCellWithReuseIdentifier(kStateCellReuseId, forIndexPath: indexPath) as StateCell
        
        if (seen) {
            // State HAS been seen
            cell.contentView.backgroundColor    = theme.kSeenBackgroundColor
            cell.titleLabel.backgroundColor     = theme.kSeenBackgroundColor
            cell.titleLabel.textColor           = theme.kSeenTextColor
            cell.detailLabel.backgroundColor    = theme.kSeenBackgroundColor
            
            if (showDetails) {
                let dateSeen = scores.dateSeen(stateCode) ?? NSDate()
                
                cell.titleLabel.text            = stateName
                cell.detailLabel.text           = dateFormatter.stringFromDate(dateSeen)
                cell.detailLabel.textColor      = theme.kSeenTextColor
                
            } else {
                cell.titleLabel.text            = stateCode
            }
            
        } else {
            // State has NOT been seen
            cell.titleLabel.text                = stateName
        }
        
        let verb = seen ? "got" : "need"
        cell.titleLabel.accessibilityLabel = "\(verb) \(stateName)"
        
        return cell;
    }

    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath!) -> UICollectionReusableView
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
    
    func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        let row         = indexPath.row
        let stateCode   = stateCodes[row]
        let seen        = scores.wasSeen(stateCode)
        
        if (seen) {
            unmarkStateSeen(row)
        } else {
            markNewStateSeen(row)
        }
        
        return false;		// never select cells
    }
    
    func setState(index: StateIndex, seen: Bool) {
        let stateCode = stateCodes[index]

        if seen {
            // hasn't been seen before, set it to "seen"
            scores.setState(stateCode, dateSeen:NSDate())
            
            // highlight it on the map
            highlightStateGeometry(stateCode, zoom: true)
            
        } else {
            // Mark a "seen" state back to "unseen"
            scores.setState(stateCode, dateSeen:nil)
            
            // unhighlight state
            self.unhighlightStateGeometry(index)
        }

        // update cell in table
        let indexPath = NSIndexPath(forRow:index, inSection: 0)
        listView!.reloadItemsAtIndexPaths([indexPath])
        
        // update header view in table
        headerView!.setScore(scores.numberOfStatesSeen())
    }
    
    func highlightStateGeometry(stateCode: StateCode, zoom: Bool) {
        if let graphic = stateGraphics[stateCode] {
            if zoom {
                // init the symbol with the "selected" colors
                updateStateColor(stateCode, seen: true, normal: false)
                
                // zoom to the geometry
                self.zoomToGeometry(graphic.geometry)

                // after a few seconds, change the color to normal
                let delay = 3 * Double(NSEC_PER_SEC)
                let time  = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
                
                dispatch_after(time, dispatch_get_main_queue()) {
                    // recheck seen date, it might have changed during the delay period
                    if let date = self.scores.dateSeen(stateCode) {
                        self.updateStateColor(stateCode, seen: true, normal: true)
                    }
                }
                
            } else {
                // not zooming, just set the final fill colors
                graphic.symbol  = AGSSimpleFillSymbol(color: UIColor(rgba:kNormalFillRGBA), outlineColor: UIColor(rgba:kNormalBorderRGBA))
                graphicsLayer.addGraphic(graphic)
            }
        }
    }
    
    func unhighlightStateGeometry(index: StateIndex) {
        let stateCode = stateCodes[index]
        
        updateStateColor(stateCode, seen:false)
        
        self.zoomToUnitedStates()
    }
    
    func updateStateColor(stateCode: StateCode, seen: Bool, normal: Bool = true) {
        if let graphic = stateGraphics[stateCode] {
            if graphic.layer != nil {
                graphic.layer.removeGraphic(graphic)
            }

            if seen {
                // state has been seen, set it's colors
                let fillRGBA    = normal ? kNormalFillRGBA   : kSelectedFillRGBA
                let outlineRGBA = normal ? kNormalBorderRGBA : kSelectedBorderRGBA
                let fillSymbol  = AGSSimpleFillSymbol(color: UIColor(rgba:fillRGBA), outlineColor: UIColor(rgba:outlineRGBA))
                fillSymbol.outline.width = normal ? 1 : 2
                graphic.symbol  = fillSymbol
                graphicsLayer.addGraphic(graphic)
            }
        }
    }
    
    func zoomToGeometry(geometry: AGSGeometry) {
        mapView?.zoomToGeometry(geometry, withPadding: 120, animated: true)
    }
    
    func zoomToUnitedStates() {
        var center = AGSPoint(x:kInitialLatLong.long, y:kInitialLatLong.lat, spatialReference: AGSSpatialReference.wgs84SpatialReference())
        let engine = AGSGeometryEngine.defaultGeometryEngine()
        center = engine.projectGeometry(center, toSpatialReference: mapView!.spatialReference) as AGSPoint
        mapView!.zoomToScale(kMapScaleInitial, withCenterPoint: center, animated: true)
    }
    
}

