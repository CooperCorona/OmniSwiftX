//
//  NSNotificationCenter+Convenience.swift
//  OmniSwift
//
//  Created by Cooper Knaak on 11/10/15.
//  Copyright © 2015 Cooper Knaak. All rights reserved.
//

import Foundation
import Foundation

extension NSNotificationCenter {
    
    public func addObserver(observer:AnyObject, name: String, selector: Selector) {
        self.addObserver(observer, selector: selector, name: name, object: nil)
    }
    
    public class func addObserver(observer:AnyObject, name: String, selector: Selector) {
        NSNotificationCenter.defaultCenter().addObserver(observer, selector: selector, name: name, object: nil)
    }
    
    public class func removeObserver(observer:AnyObject, name: String) {
        NSNotificationCenter.defaultCenter().removeObserver(observer, name: name, object: nil)
    }
    
    public class func removeObserver(observer:AnyObject) {
        NSNotificationCenter.defaultCenter().removeObserver(observer)
    }
    
}