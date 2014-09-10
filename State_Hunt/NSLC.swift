//
//  NSLC.swift
//  State_Hunt
//
//  Created by Gary Morris on 7/1/14.
//  Copyright (c) 2014 Gary Morris. All rights reserved.
//

import UIKit
import Foundation

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

// remove when linker bug fixed and UILayoutPriorityRequired can be used again
let k_UILayoutPriorityRequired: UILayoutPriority = 1000

// adds a named view for use with visual layout
func += (inout left: NSLC, right: (name:String, subview:UIView)) {
    // make sure subview is setup for auto layout
    right.subview.setTranslatesAutoresizingMaskIntoConstraints(false)

    // add subview and its name to the dictionary
    left.subviews[right.name] = right.subview
    
    // add the subview as a subview of parent (if needed)
    if right.subview.superview == nil {
        left.parent?.addSubview(right.subview)
    }
    
// UNCOMMENT TO SHOW ALL VIEW BOUNDARIES
//        right.subview.layer.borderColor = UIColor.greenColor().CGColor
//        right.subview.layer.borderWidth = 1
}

// adds a Dictionary of named subviews for use with visual layout
func += (inout left: NSLC, right: Dictionary<String,UIView>) {
    for (name, subview) in right {
        left += (name, subview)
    }
}

// adds constraints using the visual layout
func += (inout left: NSLC, visualFormat: String) {
    left.addConstraints(visualFormat)
}

// add an array of constraints
func += (inout left: NSLC, right: Array<NSLayoutConstraint> ) {
    for constraint in right {
        left.addConstraint(constraint)
    }
}

// add a single constraint
func += (inout left: NSLC, right: NSLayoutConstraint) {
    left.addConstraint(right)
}

class NSLC {
    
    var constraints = Array<NSLayoutConstraint>()   // all added constraints
    let parent      : UIView?                       // constraints are added to parent (if provided)
    let subviews    = NSMutableDictionary()         // named subviews dictionary
    var metrics     : NSDictionary?                 // named metrics dictionary
    var options     : NSLayoutFormatOptions         // visual layout format options

    init(parent: UIView? = nil, metrics: NSDictionary? = nil, options: NSLayoutFormatOptions = .DirectionLeftToRight)
    {
        self.parent     = parent
        self.metrics    = metrics
        self.options    = options
    }
    
    // adds constraints from visual format string to self.constraints
    func addConstraints(visualFormat:String)
    {
        for constraint in visualConstraints(visualFormat) {
            self.addConstraint(constraint)
        }
    }
    
    // adds constraints from visual format string to self.constraints
    func addConstraint(constraint:NSLayoutConstraint)
    {
        constraints.append(constraint)
//        constraints += constraint
        parent?.addConstraint(constraint)
    }
    
    // returns array of NSLayoutConstraints given a visual format string
    func visualConstraints(visualFormat:String) -> Array<NSLayoutConstraint>! {
        let results = NSLayoutConstraint.constraintsWithVisualFormat(visualFormat, options: self.options, metrics: self.metrics, views: self.subviews)
        
        return results as Array<NSLayoutConstraint>
    }
    
    // returns a NSLayoutConstraint to make the same attribute equal on two items, with optional multiplier, constant and priority
    class func EQ(item1: AnyObject!,
        multiplier: CGFloat = 1,
        item2: AnyObject!,
        attr:  NSLayoutAttribute,
        constant: CGFloat = 0,
        priority: UILayoutPriority = k_UILayoutPriorityRequired) -> NSLayoutConstraint
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
        priority: UILayoutPriority = k_UILayoutPriorityRequired) -> NSLayoutConstraint
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
        priority: UILayoutPriority = k_UILayoutPriorityRequired) -> NSLayoutConstraint
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
        priority: UILayoutPriority = k_UILayoutPriorityRequired) -> NSLayoutConstraint
    {
        let tmp = NSLayoutConstraint(item:item1, attribute:attr1, relatedBy:.GreaterThanOrEqual, toItem:item2, attribute:attr2, multiplier:multiplier, constant:constant)
        tmp.priority = priority
        return tmp
    }
    
}

extension UIView {

    // adds a width constraint to a view
    func setLayoutWidth(width:CGFloat, priority:UILayoutPriority = k_UILayoutPriorityRequired)
    {
        let aConstraint = NSLayoutConstraint(item:self, attribute:.Width, relatedBy:.Equal, toItem:nil, attribute:.NotAnAttribute, multiplier:1, constant:width)
        aConstraint.priority = priority
        self.addConstraint(aConstraint)
    }
    
    // adds a height constraint to a view
    func setLayoutHeight(height:CGFloat, priority:UILayoutPriority = k_UILayoutPriorityRequired)
    {
        let aConstraint = NSLayoutConstraint(item:self, attribute:.Width, relatedBy:.Equal, toItem:nil, attribute:.NotAnAttribute, multiplier:1, constant:height)
        aConstraint.priority = priority
        self.addConstraint(aConstraint)
    }

    
}




