//
//  NSObject+Convenience.swift
//  Gravity
//
//  Created by Cooper Knaak on 2/23/15.
//  Copyright (c) 2015 Cooper Knaak. All rights reserved.
//

import Foundation


//NSObject + Convenience
//Collection of methods designed for convenience.
public extension NSObject {
    
    public class func dispatchAfter(seconds:CGFloat, onQueue queue:dispatch_queue_t, withBlock block:dispatch_block_t) {
        
        let dTime = dispatch_time(DISPATCH_TIME_NOW, Int64(CGFloat(NSEC_PER_SEC) * seconds))
        
        dispatch_after(dTime, queue, block)
        
    }//dispatch after
    
    public class func dispatchAfter(seconds:CGFloat, withBlock block:dispatch_block_t) {
        
        NSObject.dispatchAfter(seconds, onQueue: dispatch_get_main_queue(), withBlock: block)
        
    }//dispatch after (on main thread)
    
    public class func dispatchAsyncMain(block:dispatch_block_t) {
        
        dispatch_async(dispatch_get_main_queue(), block)
        
    }//dispatch asynchronously on main thread
    
}//Convenience