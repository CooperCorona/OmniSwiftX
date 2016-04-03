//
//  NSSize+Math.swift
//  InverseKinematicsTest
//
//  Created by Cooper Knaak on 10/21/14.
//  Copyright (c) 2014 Cooper Knaak. All rights reserved.
//

import Foundation


//Operations

public func +(left:NSSize, right:NSSize) -> NSSize {
    return NSSize(width: left.width + right.width, height: left.height + right.height)
}//plus

public func -(left:NSSize, right:NSSize) -> NSSize {
    return NSSize(width: left.width - right.width, height: left.height - right.height)
}//minus

public func *(left:NSSize, right:NSSize) -> NSSize {
    return NSSize(width: left.width * right.width, height: left.height * right.height)
}//times

public func /(left:NSSize, right:NSSize) -> NSSize {
    return NSSize(width: left.width / right.width, height: left.height / right.height)
}//divide

//Equals

public func +=(inout left:NSSize, right:NSSize) {
    left = left + right
}//plus equals

public func -=(inout left:NSSize, right:NSSize) {
    left = left - right
}//minus equals

public func *=(inout left:NSSize, right:NSSize) {
    left = left * right
}//times equals

public func /=(inout left:NSSize, right:NSSize) {
    left = left / right
}//divide equals

//Scalars

public func +(left:NSSize, right:CGFloat) -> NSSize {
    return NSSize(width: left.width + right, height: left.height + right)
}//plus scalar

public func +(right:CGFloat, left:NSSize) -> NSSize {
    return NSSize(width: left.width + right, height: left.height + right)
}//plus scalar

public func -(left:NSSize, right:CGFloat) -> NSSize {
    return NSSize(width: left.width - right, height: left.height - right)
}//minus scalar

public func -(right:CGFloat, left:NSSize) -> NSSize {
    return NSSize(width: left.width - right, height: left.height - right)
}//minus scalar

public func *(left:NSSize, right:CGFloat) -> NSSize {
    return NSSize(width: left.width * right, height: left.height * right)
}//times scalar

public func *(right:CGFloat, left:NSSize) -> NSSize {
    return NSSize(width: left.width * right, height: left.height * right)
}//times scalar

public func /(left:NSSize, right:CGFloat) -> NSSize {
    return NSSize(width: left.width / right, height: left.height / right)
}//divide scalar

public func /(right:CGFloat, left:NSSize) -> NSSize {
    return NSSize(width: left.width / right, height: left.height / right)
}//divide scalar

//Scalar equals

public func +=(inout left:NSSize, right:CGFloat) {
    left = left + right
}//add equals scalar

public func -=(inout left:NSSize, right:CGFloat) {
    left = left - right
}//minus equals scalar

public func *=(inout left:NSSize, right:CGFloat) {
    left = left * right
}//times equals scalar

public func /=(inout left:NSSize, right:CGFloat) {
    left = left / right
}//divide equals scalar


public extension NSSize {
    
    public var center:NSPoint { return NSPoint(x: self.width / 2.0, y: self.height / 2.0) }
    
    public var maximum:CGFloat { return max(self.width, self.height) }
    public var minimum:CGFloat { return min(self.width, self.height) }
    
    public var portrait:Bool    { return self.width < self.height }
    public var landscape:Bool   { return self.width > self.height }
    
    public init(square:CGFloat) {
        self.init(width: square, height: square)
    }//initialize as square
    
    public func getNSPoint() -> NSPoint {
        
        return NSPoint(x: width, y: height)
        
    }//get as NSPoint
    
    public func flip() -> NSSize {
        return NSSize(width: self.height, height: self.width)
    }
    
}//size
/*
public extension NSSize: FloatLiteralConvertible {
    
    public init(floatLiteral value: FloatLiteralType) {
        self.init(square: CGFloat(value))
    }
}
*/