//
//  NSPoint+Math.swift
//  InverseKinematicsTest
//
//  Created by Cooper Knaak on 10/11/14.
//  Copyright (c) 2014 Cooper Knaak. All rights reserved.
//

import Foundation
import GLKit

// MARK: - Operations

public func +(left:NSPoint, right:NSPoint) -> NSPoint {
    return NSPoint(x: left.x + right.x, y: left.y + right.y)
}//plus

public func -(left:NSPoint, right:NSPoint) -> NSPoint {
    return NSPoint(x: left.x - right.x, y: left.y - right.y)
}//minus

public func *(left:NSPoint, right:NSPoint) -> NSPoint {
    return NSPoint(x: left.x * right.x, y: left.y * right.y)
}//multiply

public func /(left:NSPoint, right:NSPoint) -> NSPoint {
    return NSPoint(x: left.x / right.x, y: left.y / right.y)
}//divide


public prefix func -(left:NSPoint) -> NSPoint {
    return NSPoint(x: -left.x, y: -left.y)
}//negate


// MARK: - Equals

public func +=(inout left:NSPoint, right:NSPoint) {
    left = left + right
}//plus equals

public func -=(inout left:NSPoint, right:NSPoint) {
    left = left - right
}//minus equals

public func *=(inout left:NSPoint, right:NSPoint) {
    left = left * right
}//multiply equals

public func /=(inout left:NSPoint, right:NSPoint) {
    left = left / right
}//divide equals


// MARK: - Operation Scalars

public func +(left:NSPoint, right:CGFloat) -> NSPoint {
    return NSPoint(x: left.x + right, y: left.y + right)
}//plus scalar

public func -(left:NSPoint, right:CGFloat) -> NSPoint {
    return NSPoint(x: left.x - right, y: left.y - right)
}//minus scalar

public func *(left:NSPoint, right:CGFloat) -> NSPoint {
    return NSPoint(x: left.x * right, y: left.y * right)
}//multiply scalar

public func /(left:NSPoint, right:CGFloat) -> NSPoint {
    return NSPoint(x: left.x / right, y: left.y / right)
}//divide scalar

public func +(left:CGFloat, right:NSPoint) -> NSPoint {
    return NSPoint(x: left + right.x, y: left + right.y)
}//plus scalar

public func -(left:CGFloat, right:NSPoint) -> NSPoint {
    return NSPoint(x: left - right.x, y: left - right.y)
}//minus scalar

public func *(left:CGFloat, right:NSPoint) -> NSPoint {
    return NSPoint(x: left * right.x, y: left * right.y)
}//multiply scalar

public func /(left:CGFloat, right:NSPoint) -> NSPoint {
    return NSPoint(x: left / right.x, y: left * right.y)
}//divide scalar

// MARK: - Equals Scalars

public func +=(inout left:NSPoint, right:CGFloat) {
    left = left + right
}//plus equals scalar

public func -=(inout left:NSPoint, right:CGFloat) {
    left = left - right
}//minus equals scalar

public func *=(inout left:NSPoint, right:CGFloat) {
    left = left * right
}//times equals scalar

public func /=(inout left:NSPoint, right:CGFloat) {
    left = left / right
}//divide equals scalar


//Custom About Equals operator
public func ~=(lhs:NSPoint, rhs:NSPoint) -> Bool {
    return lhs.x ~= rhs.x && lhs.y ~= rhs.y
}
/*
 *  +> only adds the given CGFloat to the x-value
 *  +^ only adds the given CGFloat to the y-value
 *  (because '>' is horizontal and '^' is vertical

infix operator +>> { precedence 140 associativity left }
infix operator +^^ { precedence 140 associativity left }

public func +>(lhs:NSPoint, rhs:CGFloat) -> NSPoint {
    return NSPoint(x: lhs.x + rhs, y: lhs.y)
}

public func +^(lhs:NSPoint, rhs:CGFloat) -> NSPoint {
    return NSPoint(x: lhs.x, y: lhs.y + rhs)
}

public func +>(lhs:CGFloat, rhs:NSPoint) -> NSPoint {
    return NSPoint(x: rhs.x + lhs, y: rhs.y)
}

public func +^(lhs:CGFloat, rhs:NSPoint) -> NSPoint {
    return NSPoint(x: rhs.x, y: rhs.y + lhs)
}
*/

// MARK: - NSSize

/**
I have decided that NSPoint times a NSSize will return a NSPoint.
I don't define NSSize * NSPoint so as not to clutter the global
namespace and to make it explicit that I'm not quite pleased with my decision.
*/
public func *(lhs:NSPoint, rhs:NSSize) -> NSPoint {
    return NSPoint(x: lhs.x * rhs.width, y: lhs.y * rhs.height)
}

// MARK: - Extension
public extension NSPoint {

    public var isZero:Bool { return self.x ~= 0.0 && self.y ~= 0.0 }
    
    public init(x:CGFloat) {
        self.init(x: x, y: 0.0)
    }
    
    public init(y:CGFloat) {
        self.init(x: 0.0, y: y)
    }
    
    ///Initializes x and y values with the same value.
    public init(xy:CGFloat) {
        self.init(x: xy, y: xy)
    }
    
    public init(angle:CGFloat, length:CGFloat=1.0) {
        self.init(x: length * cos(angle), y: length * sin(angle))
    }//normalized vector with angle
    
    public init(tupleCG:(CGFloat, CGFloat)) {
        self.init(x: tupleCG.0, y: tupleCG.1)
    }//initialize with tuple
    
    public init(tuple:(Float, Float)) {
        self.init(x: CGFloat(tuple.0), y: CGFloat(tuple.1))
    }//initialize with tuple
    
    public init(tupleGL:(GLfloat, GLfloat)) {
        self.init(x: CGFloat(tupleGL.0), y: CGFloat(tupleGL.1))
    }//initialize with tuple (GLfloat)
    
    public func length() -> CGFloat {
        return sqrt(x * x + y * y)
    }//get length
    
    public func getTuple() -> (CGFloat, CGFloat) {
        return (x, y)
    }//get point as tuple
    
    public func getTupleCG() -> (CGFloat, CGFloat) {
        return (x, y)
    }//get point as tuple (CGFloat)
    
    public func getGLTuple() -> (GLfloat, GLfloat) {
        return (GLfloat(x), GLfloat(y))
    }//get point as tuple (GLfloat)
    
    
    public func distanceFrom(point:NSPoint) -> CGFloat {
        return sqrt((x - point.x) * (x - point.x) + (y - point.y) * (y - point.y))
    }//distance from/to other point
    
    public func angleTo(point:NSPoint) -> CGFloat {
        return atan2(point.y - self.y, point.x - self.x)
    }//angle to point
    
    public func angle() -> CGFloat {
        return atan2(self.y, self.x)
    }//returns angle (using atan2)
    
    public func unit() -> NSPoint {
        let len = self.length()
        if (len ~= 0.0) {
            return NSPoint.zero
        } else {
            return self / len
        }
    }//get unit vector
    
    ///Returns a vector (point) in the same direction as *self* but with the given length *length*
    public func makeLength(length:CGFloat) -> NSPoint {
        return self.unit() * length
    }
    
    public func dot(point:NSPoint) -> CGFloat {
        return self.x * point.x + self.y * point.y
    }
    
    public func componentsInDirection(vector:NSPoint) -> NSPoint {
        
        if (self.isZero || vector.isZero) {
            return NSPoint.zero
        }
        
        let unitVector = vector.unit()
        return self.dot(unitVector) * unitVector
    }//components in direction of 'vector'
    
    public func flip() -> NSPoint {
        return NSPoint(x: self.y, y: self.x)
    }
}//extend