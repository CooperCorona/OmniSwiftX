//
//  NSRect+Math.swift
//  InverseKinematicsTest
//
//  Created by Cooper Knaak on 10/23/14.
//  Copyright (c) 2014 Cooper Knaak. All rights reserved.
//

import Foundation


// MARK: - Initializers

public extension NSRect {
    
    public init(size:NSSize) {
        self.init(origin: NSPoint.zero, size: size)
    }
    
    public init(width:CGFloat, height:CGFloat, centered:Bool = false) {
        let x = (centered ? -width / 2.0 : 0.0)
        let y = (centered ? -height / 2.0 : 0.0)
        self.init(x: x, y: y, width: width, height: height)
    }
    
    public init(square:CGFloat) {
        self.init(origin: NSPoint.zero, size: NSSize(square: square))
    }
    
    public init(center:NSPoint, size:NSSize) {
        self.init(x: center.x - size.width / 2.0, y: center.y - size.height / 2.0, width: size.width, height: size.height)
    }//initialize
    
    ///Creates a rect containing all points.
    public init(points:[NSPoint]) {
        if let p1 = points.first {
            var minX = p1.x
            var maxX = p1.x
            var minY = p1.y
            var maxY = p1.y
            for point in points {
                if minX > point.x {
                    minX = point.x
                } else if maxX < point.x {
                    maxX = point.x
                }
                if minY > point.y {
                    minY = point.y
                } else if maxY < point.y {
                    maxY = point.y
                }
            }
            
            self = NSRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
        } else {
            self = NSRect.zero
        }
    }
    ///Creates a rect containing all rects.
    public init(rects:[NSRect]) {
        if let r1 = rects.first {
            var minX = r1.minX
            var maxX = r1.maxX
            var minY = r1.minY
            var maxY = r1.maxY
            for rect in rects {
                if minX > rect.minX {
                    minX = rect.minX
                } else if maxX < rect.maxX {
                    maxX = rect.maxX
                }
                if minY > rect.minY {
                    minY = rect.minY
                } else if maxY < rect.maxY {
                    maxY = rect.maxY
                }
            }
            
            self = NSRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
        } else {
            self = NSRect.zero
        }
    }
    
}//initializers

// MARK: - Custom Getters
public extension NSRect {
    
    public var center:NSPoint {
        get {
            return NSPoint(x: self.midX, y: self.midY)
        }
        set {
            self = NSRect(center: newValue, size: self.size)
        }
    }//get center

    // MARK: - Corners
    
    public var topLeft:NSPoint {
        get {
            return NSPoint(x: self.minX, y: self.minY)
        }
        set {
            // I originally had the topLeft & bottomLeft setters
            // switched. There are correct now, but only for UI.
            // If I want to use them in OpenGL, they will need
            // to be switched back.
            self = NSRect(origin: newValue, size: self.size)
        }
    }
    
    public var bottomLeft:NSPoint {
        get {
            return NSPoint(x: self.minX, y: self.maxY)
        }
        set {
            self = NSRect(x: newValue.x, y: newValue.y - self.size.height, width: self.size.width, height: self.size.height)
        }
    }
    
    public var topRight:NSPoint {
        get {
            return NSPoint(x: self.maxX, y: self.minY)
        }
        set {
            self = NSRect(x: newValue.x - self.size.width, y: newValue.y, width: self.size.width, height: self.size.height)
        }
    }
    
    public var bottomRight:NSPoint {
        get {
            return NSPoint(x: self.maxX, y: self.maxY)
        }
        set {
            self = NSRect(x: newValue.x - self.size.width, y: newValue.y - self.size.height, width: self.size.width, height: self.size.height)
        }
    }
    
    // MARK: - Middles
    
    public var leftMiddle:NSPoint {
        get {
            return NSPoint(x: self.minX, y: self.midY)
        }
        set {
            self = NSRect(x: newValue.x, y: newValue.y - self.size.height / 2.0, width: self.size.width, height: self.size.height)
        }
    }
    
    public var rightMiddle:NSPoint {
        get {
            return NSPoint(x: self.maxX, y: self.midY)
        }
        set {
            self = NSRect(x: newValue.x - self.size.width, y: newValue.y - self.size.height / 2.0, width: self.size.width, height: self.size.height)
        }
    }
    
    public var topMiddle:NSPoint {
        get {
            return NSPoint(x: self.midX, y: self.minY)
        }
        set {
            self = NSRect(x: newValue.x - self.size.width / 2.0, y: newValue.y, width: self.size.width, height: self.size.height)
        }
    }
    
    public var bottomMiddle:NSPoint {
        get {
            return NSPoint(x: self.midX, y: self.maxY)
        }
        set {
            self = NSRect(x: newValue.x - self.size.width / 2.0, y: newValue.y - self.size.height, width: self.size.width, height: self.size.height)
        }
    }
    
    
    public subscript(vertex:TexturedQuad.VertexName) -> NSPoint {
        get {
            switch vertex {
            case .BottomLeft:
                return self.bottomLeft
            case .BottomRight:
                return self.bottomRight
            case .TopLeft:
                return self.topLeft
            case .TopRight:
                return self.topRight
            }
        }
        set {
            switch vertex {
            case .BottomLeft:
                self.bottomLeft     = newValue
                
            case .BottomRight:
                self.bottomRight    = newValue
                
            case .TopLeft:
                self.topLeft        = newValue
                
            case .TopRight:
                self.topRight       = newValue
            }
        }
    }
    
    ///Returns a random point in or on the rectangle.
    public func randomPoint() -> NSPoint {
        let xPercent = GLSParticleEmitter.randomFloat()
        let yPercent = GLSParticleEmitter.randomFloat()
        return self.origin + NSPoint(x: xPercent, y: yPercent) * self.size
    }
    
    ///Returns the value from *NSStringFromNSRect*.
    public func getString() -> String {
        return NSStringFromRect(self)
    }
    
}//NSRect

// MARK: - Overridden Setters
//Overriden methods
//I added setters
public extension NSRect {
    
    public mutating func setSizeCentered(size:NSSize) {
        self = NSRect(center: self.center, size: size)
    }
    
    public mutating func setSizeCenteredWidth(width:CGFloat, height:CGFloat) {
        self = NSRect(center: self.center, size: NSSize(width: width, height: height))
    }
    
    public mutating func setWidthCentered(width:CGFloat) {
        self = NSRect(center: self.center, size: NSSize(width: width, height: self.size.height))
    }
    
    public mutating func setHeightCentered(height:CGFloat) {
        self = NSRect(center: self.center, size: NSSize(width: self.size.width, height: height))
    }
    
    
    public mutating func setMinX(newValue:CGFloat) {
        self = NSRect(x: newValue, y: self.minY, width: self.width, height: self.height)
    }
    
    public mutating func setMinY(newValue:CGFloat) {
        self = NSRect(x: self.minX, y: newValue, width: self.width, height: self.height)
    }
    
    public mutating func setMaxX(newValue:CGFloat) {
        self = NSRect(x: newValue - self.width, y: self.minY, width: self.width, height: self.height)
    }
    
    public mutating func setMaxY(newValue:CGFloat) {
        self = NSRect(x: self.minX, y: newValue - self.height, width: self.width, height: self.height)
    }

}

extension NSRect {
    
    // MARK: - Custom GL Getters
    
    public var topLeftGL:NSPoint {
        get {
            return NSPoint(x: self.minX, y: self.maxY)
        }
        set {
            // I originally had the topLeft & bottomLeft setters
            // switched. There are correct now, but only for UI.
            // If I want to use them in OpenGL, they will need
            // to be switched back.
            self = NSRect(x: newValue.x, y: newValue.y - self.size.height, width: self.size.width, height: self.size.height)
        }
    }
    
    public var bottomLeftGL:NSPoint {
        get {
            return NSPoint(x: self.minX, y: self.minY)
        }
        set {
            self = NSRect(origin: newValue, size: self.size)
        }
    }
    
    public var topRightGL:NSPoint {
        get {
            return NSPoint(x: self.maxX, y: self.maxY)
        }
        set {
            self = NSRect(x: newValue.x - self.size.width, y: newValue.y - self.size.height, width: self.size.width, height: self.size.height)
        }
    }
    
    public var bottomRightGL:NSPoint {
        get {
            return NSPoint(x: self.maxX, y: self.minY)
        }
        set {
            self = NSRect(x: newValue.x - self.size.width, y: newValue.y, width: self.size.width, height: self.size.height)
        }
    }
}

public extension NSRect {
    
    // MARK: - Convenience
    
    /**
    Divides self into 4 different rects which all meet at *point*.
    
    - parameter point: The point where the divisions meet.
    - returns: An array of NSRect values. (OpenGL Coordinates)
    [0]: Top Left
    [1]: Bottom Left
    [2]: Top Right
    [3]: Bottom Right
    */
    public func divideAt(point:NSPoint) -> [NSRect] {
        
        let topLeft = NSRect(x: self.topLeftGL.x, y: point.y, width: point.x - self.topLeftGL.x, height: self.topLeftGL.y - point.y)
        let bottomLeft = NSRect(x: self.bottomLeftGL.x, y: self.bottomLeftGL.y, width: point.x - self.bottomLeftGL.x, height: point.y - self.bottomLeftGL.y)
        let bottomRight = NSRect(x: point.x, y: self.bottomRightGL.y, width: self.bottomRightGL.x - point.x, height: point.y - self.bottomRightGL.y)
        let topRight = NSRect(x: point.x, y: point.y, width: self.topRightGL.x - point.x, height: self.topRightGL.y - point.y)
        
        return [topLeft, bottomLeft, topRight, bottomRight]
    }
    
    /**
    Divides self into 4 different rects which all meet *percent* of the way through self.
    
    - parameter percent: The percent, in range [0.0, 1.0].
    - returns: An array of NSRect values that meet at the given percent.
    */
    public func divideAtPercent(percent:NSPoint) -> [NSRect] {
        return self.divideAt(self.origin + percent * self.size)
    }
    
}

// MARK: - Operators

public func +(lhs:NSRect, rhs:NSRect) -> NSRect {
    return NSRect(origin: lhs.origin + rhs.origin, size: lhs.size + rhs.size)
}

public func -(lhs:NSRect, rhs:NSRect) -> NSRect {
    return NSRect(origin: lhs.origin - rhs.origin, size: lhs.size - rhs.size)
}

public func *(lhs:NSRect, rhs:NSRect) -> NSRect {
    return NSRect(origin: lhs.origin * rhs.origin, size: lhs.size * rhs.size)
}

public func /(lhs:NSRect, rhs:NSRect) -> NSRect {
    return NSRect(origin: lhs.origin / rhs.origin, size: lhs.size / rhs.size)
}

public func +=(inout lhs:NSRect, rhs:NSRect) {
    lhs = NSRect(origin: lhs.origin + rhs.origin, size: lhs.size + rhs.size)
}

public func -=(inout lhs:NSRect, rhs:NSRect) {
    lhs = NSRect(origin: lhs.origin - rhs.origin, size: lhs.size - rhs.size)
}

public func *=(inout lhs:NSRect, rhs:NSRect) {
    lhs = NSRect(origin: lhs.origin * rhs.origin, size: lhs.size * rhs.size)
}

public func /=(inout lhs:NSRect, rhs:NSRect) {
    lhs = NSRect(origin: lhs.origin / rhs.origin, size: lhs.size / rhs.size)
}

// MARK: - Operators (CGFloat)

public func +(lhs:NSRect, rhs:CGFloat) -> NSRect {
    return NSRect(origin: lhs.origin + rhs, size: lhs.size + rhs)
}

public func -(lhs:NSRect, rhs:CGFloat) -> NSRect {
    return NSRect(origin: lhs.origin - rhs, size: lhs.size - rhs)
}

public func *(lhs:NSRect, rhs:CGFloat) -> NSRect {
    return NSRect(origin: lhs.origin * rhs, size: lhs.size * rhs)
}

public func /(lhs:NSRect, rhs:CGFloat) -> NSRect {
    return NSRect(origin: lhs.origin / rhs, size: lhs.size / rhs)
}

public func +(lhs:CGFloat, rhs:NSRect) -> NSRect {
    return NSRect(origin: lhs + rhs.origin, size: lhs + rhs.size)
}

public func -(lhs:CGFloat, rhs:NSRect) -> NSRect {
    return NSRect(origin: lhs - rhs.origin, size: lhs - rhs.size)
}

public func *(lhs:CGFloat, rhs:NSRect) -> NSRect {
    return NSRect(origin: lhs * rhs.origin, size: lhs * rhs.size)
}

public func /(lhs:CGFloat, rhs:NSRect) -> NSRect {
    return NSRect(origin: lhs / rhs.origin, size: lhs / rhs.size)
}

public func +=(inout lhs:NSRect, rhs:CGFloat) {
    lhs = NSRect(origin: lhs.origin + rhs, size: lhs.size + rhs)
}

public func -=(inout lhs:NSRect, rhs:CGFloat) {
    lhs = NSRect(origin: lhs.origin - rhs, size: lhs.size - rhs)
}

public func *=(inout lhs:NSRect, rhs:CGFloat) {
    lhs = NSRect(origin: lhs.origin * rhs, size: lhs.size * rhs)
}

public func /=(inout lhs:NSRect, rhs:CGFloat) {
    lhs = NSRect(origin: lhs.origin / rhs, size: lhs.size / rhs)
}

// MARK: - Operators (NSPoint)

public func +(lhs:NSRect, rhs:NSPoint) -> NSRect {
    return NSRect(origin: lhs.origin + rhs, size: lhs.size)
}

public func -(lhs:NSRect, rhs:NSPoint) -> NSRect {
    return NSRect(origin: lhs.origin - rhs, size: lhs.size)
}

public func *(lhs:NSRect, rhs:NSPoint) -> NSRect {
    return NSRect(origin: lhs.origin * rhs, size: lhs.size)
}

public func /(lhs:NSRect, rhs:NSPoint) -> NSRect {
    return NSRect(origin: lhs.origin / rhs, size: lhs.size)
}

public func +(lhs:NSPoint, rhs:NSRect) -> NSRect {
    return NSRect(origin: lhs + rhs.origin, size: rhs.size)
}

public func -(lhs:NSPoint, rhs:NSRect) -> NSRect {
    return NSRect(origin: lhs - rhs.origin, size: rhs.size)
}

public func *(lhs:NSPoint, rhs:NSRect) -> NSRect {
    return NSRect(origin: lhs * rhs.origin, size: rhs.size)
}

public func /(lhs:NSPoint, rhs:NSRect) -> NSRect {
    return NSRect(origin: lhs / rhs.origin, size: rhs.size)
}

public func +=(inout lhs:NSRect, rhs:NSPoint) {
    lhs = NSRect(origin: lhs.origin + rhs, size: lhs.size)
}

public func -=(inout lhs:NSRect, rhs:NSPoint) {
    lhs = NSRect(origin: lhs.origin - rhs, size: lhs.size)
}

public func *=(inout lhs:NSRect, rhs:NSPoint) {
    lhs = NSRect(origin: lhs.origin * rhs, size: lhs.size)
}

public func /=(inout lhs:NSRect, rhs:NSPoint) {
    lhs = NSRect(origin: lhs.origin / rhs, size: lhs.size)
}

// MARK: - Operators (NSSize)

public func +(lhs:NSRect, rhs:NSSize) -> NSRect {
    return NSRect(origin: lhs.origin, size: lhs.size + rhs)
}

public func -(lhs:NSRect, rhs:NSSize) -> NSRect {
    return NSRect(origin: lhs.origin, size: lhs.size - rhs)
}

public func *(lhs:NSRect, rhs:NSSize) -> NSRect {
    return NSRect(origin: lhs.origin, size: lhs.size * rhs)
}

public func /(lhs:NSRect, rhs:NSSize) -> NSRect {
    return NSRect(origin: lhs.origin, size: lhs.size / rhs)
}

public func +(lhs:NSSize, rhs:NSRect) -> NSRect {
    return NSRect(origin: rhs.origin, size: lhs + rhs.size)
}

public func -(lhs:NSSize, rhs:NSRect) -> NSRect {
    return NSRect(origin: rhs.origin, size: lhs - rhs.size)
}

public func *(lhs:NSSize, rhs:NSRect) -> NSRect {
    return NSRect(origin: rhs.origin, size: lhs * rhs.size)
}

public func /(lhs:NSSize, rhs:NSRect) -> NSRect {
    return NSRect(origin: rhs.origin, size: lhs / rhs.size)
}

public func +=(inout lhs:NSRect, rhs:NSSize) {
    lhs = NSRect(origin: lhs.origin, size: lhs.size + rhs)
}

public func -=(inout lhs:NSRect, rhs:NSSize) {
    lhs = NSRect(origin: lhs.origin, size: lhs.size - rhs)
}

public func *=(inout lhs:NSRect, rhs:NSSize) {
    lhs = NSRect(origin: lhs.origin, size: lhs.size * rhs)
}

public func /=(inout lhs:NSRect, rhs:NSSize) {
    lhs = NSRect(origin: lhs.origin, size: lhs.size / rhs)
}
