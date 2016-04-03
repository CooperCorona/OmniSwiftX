//
//  TimeTracker.swift
//  Batcher
//
//  Created by Cooper Knaak on 4/7/15.
//  Copyright (c) 2015 Cooper Knaak. All rights reserved.
//

import Foundation

// MARK: - TimeKeeper

public class TimeKeeper: NSObject {
    
    public let name:String?
    
    private var startDate = NSDate()
    private var endDate = NSDate()
    private var timing = false
    public var isTiming:Bool { return self.timing }
    
    private var totalDT:NSTimeInterval = 0.0
    private var iterations = 0
    public var averageTime:NSTimeInterval { return self.totalDT / NSTimeInterval(iterations) }
    
    public init(name:String? = nil) {
        
        self.name = name
        
        super.init()
        
    }//initialize
    
    public func start() -> Bool {
        
        if (self.timing) {
            return false
        }
        
        self.timing = true
        self.startDate = NSDate()
        
        return true
    }//start timing
    
    public func stop() -> Bool {
        
        if (!self.timing) {
            return false
        }
        
        self.timing = false
        self.endDate = NSDate()
        
        self.totalDT += self.endDate.timeIntervalSinceDate(self.startDate)
        self.iterations += 1
        
        return true
    }//stop timing
    
    
    public override var description:String {
        if let name = self.name {
            return "\(name):\(self.averageTime)"
        } else {
            return "\(self.averageTime)"
        }
    }
    
    public func msString(precision:Int) -> String {
        var string:String
        if let name = self.name {
            string = "\(name) "
        } else {
            string = " "
        }
        
        var averageStr = "\(self.averageTime * 1000.0)"
        if let decimalRange = averageStr.rangeOfString(".", options: NSStringCompareOptions(), range: nil, locale: nil) {
            let decimalIndex = averageStr.startIndex.distanceTo(decimalRange.startIndex)
            while averageStr.characterCount > decimalIndex + precision + 1 {
                averageStr.removeLast()
            }
        }
        string += averageStr
        string += " ms"
        
        return string
    }
}