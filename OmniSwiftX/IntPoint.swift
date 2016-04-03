//
//  IntPoint.swift
//  KingOfKauffman
//
//  Created by Cooper Knaak on 11/23/15.
//  Copyright © 2015 Cooper Knaak. All rights reserved.
//

import Foundation

public struct IntPoint: CustomStringConvertible, Hashable {
    
    // MARK: - Properties
    
    public var x = 0
    public var y = 0
    public var description:String { return "(\(self.x), \(self.y))" }
    public var hashValue:Int { return self.x << 16 | self.y }
    
    // MARK: - Setup
    
    public init() {
        
    }
    
    public init(x:Int, y:Int) {
        self.x = x
        self.y = y
    }
    
    public init(x:Int) {
        self.x = x
    }
    
    public init(y:Int) {
        self.y = y
    }
    
    public init(point:NSPoint) {
        self.x = Int(point.x)
        self.y = Int(point.y)
    }
    
    public init(string:String) {
        self.init(point: NSPointFromString(string))
    }
    
    // MARK: - Logic
    
    ///Returns true if 0 <= x < width and 0 <= y < height.
    public func withinGridWidth(width:Int, height:Int) -> Bool {
        return 0 <= self.x && self.x < width && 0 <= self.y && self.y < height
    }
    
    public func getNSPoint() -> NSPoint {
        return NSPoint(x: self.x, y: self.y)
    }
    
    public func getString() -> String {
        return NSStringFromPoint(self.getNSPoint()) as String
    }
    
    ///Uses manhattan distance, becaase euclidian distance just doesn't make sense.
    public func distance(point:IntPoint) -> Int {
        return abs(point.x - self.x) + abs(point.y - self.y)
    }
}
