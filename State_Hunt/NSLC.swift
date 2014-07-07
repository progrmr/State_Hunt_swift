//
//  NSLC.swift
//  State_Hunt
//
//  Created by Gary Morris on 7/1/14.
//  Copyright (c) 2014 Gary Morris. All rights reserved.
//

import UIKit
import Foundation
import ArcGIS

//-----------------------------------------------------------------------------
// NSLC is a class that provides convenient methods for adding NSLayoutConstraints
// to a  parent view.  NSLC also setTranslatesAutoresizingMaskIntoConstraints to
// false on all subviews added and makes them a subview of the parent view.
//
// Steps to use:
//
// (1) Instantiate NSLC with the parent view that will hold the constraints.  
//
//     let cons = NSLC(view)
//
// (2) Add names for subviews using a tuple or an array:
//
//     cons += (name: "mapView",   view: mapView)
//     cons += (name: "tableView", view: tableView)
//
//     cons += ["mapView" : mapView, "tableView", tableView]
//
// (3) Add visual format strings
//
//     cons += "H:|[tableView]|"
//     cons += "V:|-20-[mapView][tableView]|"
//
// (4) optional: add constraints using methods like EQ, GE, LE
//
//     cons += EQ(tableView, item2:mapView, attr:.Width)
//
//-----------------------------------------------------------------------------

// adds a named view for use with visual layout
@assignment func += (inout left: NSLC, right: (name:String, subview:UIView)) {
    // add subview and its name to the dictionary
    left.subviews[right.name] = right.subview
    
    // make sure subview is a subview
    if right.subview.superview == nil {
        left.parent.addSubview(right.subview)
        
// UNCOMMENT TO SEE VIEW BOUNDARIES
//        right.subview.layer.borderColor = UIColor.greenColor().CGColor
//        right.subview.layer.borderWidth = 1
    }
    
    // make sure subview is setup for auto layout
    right.subview.setTranslatesAutoresizingMaskIntoConstraints(false)
}

// adds a Dictionary of named subviews for use with visual layout
@assignment func += (inout left: NSLC, right: Dictionary<String,UIView>) {
    for (name: String, subview: UIView) in right {
        left += (name:name, subview:subview)
    }
}

// adds constraints to parent view using the visual layout
@assignment func += (inout left: NSLC, visualFormat: String) {
    let constraints = left.visualConstraints(visualFormat)
    left.parent.addConstraints(constraints)
}

// add a constraint to parent view
@assignment func += (inout left: NSLC, right: NSLayoutConstraint) {
    left.parent.addConstraint(right)
}

class NSLC {
    
    var parent      : UIView
    var metrics     : NSDictionary?
    var options     : NSLayoutFormatOptions
    
    let subviews    = NSMutableDictionary()

    init(parent: UIView, metrics: NSDictionary? = nil, options: NSLayoutFormatOptions = .DirectionLeftToRight)
    {
        self.parent     = parent
        self.metrics    = metrics
        self.options    = options
    }
    
    // adds constraints from visual format string to self.constraints
    func addConstraints(visualFormat:String)
    {
        parent.addConstraints(visualConstraints(visualFormat))
    }
    
    // adds constraints from visual format string to self.constraints
    func addConstraint(constraint:NSLayoutConstraint)
    {
        parent.addConstraint(constraint)
    }
    
    // returns array of NSLayoutConstraints given a visual format string
    func visualConstraints(visualFormat:String) -> NSArray! {
        return NSLayoutConstraint.constraintsWithVisualFormat(visualFormat, options: self.options, metrics: self.metrics, views: self.subviews)
    }
    
    // returns a NSLayoutConstraint to make the same attribute equal on two items, with optional multiplier, constant and priority
    class func EQ(item1: AnyObject!,
        multiplier: CGFloat = 1,
        item2: AnyObject!,
        attr:  NSLayoutAttribute,
        constant: CGFloat = 0,
        priority: UILayoutPriority = UILayoutPriority(UILayoutPriorityRequired)) -> NSLayoutConstraint
    {
        let tmp = NSLayoutConstraint(item:item1, attribute:attr, relatedBy:.Equal, toItem:item2, attribute:attr, multiplier:multiplier, constant:constant)
        tmp.priority = priority
        return tmp
    }
    
    // returns a NSLayoutConstraint to make an attribute on a item1 equal to an attribute on item2, with optional multiplier, constant and priority
    class func EQ(item1: AnyObject!,
        attr1: NSLayoutAttribute,
        multiplier: CGFloat = 1,
        item2: AnyObject!,
        attr2: NSLayoutAttribute,
        constant: CGFloat = 0,
        priority: UILayoutPriority = UILayoutPriority(UILayoutPriorityRequired)) -> NSLayoutConstraint
    {
        let tmp = NSLayoutConstraint(item:item1, attribute:attr1, relatedBy:.Equal, toItem:item2, attribute:attr2, multiplier:multiplier, constant:constant)
        tmp.priority = priority
        return tmp
    }
    
    // returns a NSLayoutConstraint to make an attribute on a item1 <= an attribute on item2, with optional constant and priority
    class func LE(item1: AnyObject!,
        attr1: NSLayoutAttribute,
        multiplier: CGFloat = 1,
        item2: AnyObject? = nil,
        attr2: NSLayoutAttribute,
        constant: CGFloat = 0,
        priority: UILayoutPriority = UILayoutPriority(UILayoutPriorityRequired)) -> NSLayoutConstraint
    {
        let tmp = NSLayoutConstraint(item:item1, attribute:attr1, relatedBy:.LessThanOrEqual, toItem:item2, attribute:attr2, multiplier:multiplier, constant:constant)
        tmp.priority = priority
        return tmp
    }
    
    // returns a NSLayoutConstraint to make an attribute on a item1 >= an attribute on item2, with optional constant and priority
    class func GE(item1: AnyObject!,
        attr1: NSLayoutAttribute,
        multiplier: CGFloat = 1,
        item2: AnyObject!,
        attr2: NSLayoutAttribute,
        constant: CGFloat = 0,
        priority: UILayoutPriority = UILayoutPriority(UILayoutPriorityRequired)) -> NSLayoutConstraint
    {
        let tmp = NSLayoutConstraint(item:item1, attribute:attr1, relatedBy:.GreaterThanOrEqual, toItem:item2, attribute:attr2, multiplier:multiplier, constant:constant)
        tmp.priority = priority
        return tmp
    }
    
    
    // adds a width constraint to a view
    func addWidthToView(view:UIView, width:CGFloat, priority:UILayoutPriority = UILayoutPriority(UILayoutPriorityRequired))
    {
        let aConstraint = NSLayoutConstraint(item:view, attribute:.Width, relatedBy:.Equal, toItem:nil, attribute:.NotAnAttribute, multiplier:1, constant:width)
        aConstraint.priority = priority
        view.addConstraint(aConstraint)
    }
    
    // adds a height constraint to a view
    func addHeightToView(view:UIView, height:CGFloat, priority:UILayoutPriority = UILayoutPriority(UILayoutPriorityRequired))
    {
        let aConstraint = NSLayoutConstraint(item:view, attribute:.Width, relatedBy:.Equal, toItem:nil, attribute:.NotAnAttribute, multiplier:1, constant:height)
        aConstraint.priority = priority
        view.addConstraint(aConstraint)
    }
    
}




