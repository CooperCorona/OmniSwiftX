//
//  HasComponentsProtocol.swift
//  OmniSwift
//
//  Created by Cooper Knaak on 6/18/15.
//  Copyright (c) 2015 Cooper Knaak. All rights reserved.
//

import Foundation

// MARK: - Protocol Definition
public typealias ComponentFunction = (CGFloat) -> CGFloat
public protocol HasComponents {
    
    static var numberOfComponents:Int { get }
    
    var components:[CGFloat] { get }
    
    init(components:[CGFloat])
    
}

// MARK: - Functions
public func iterateComponents(array:[CGFloat], withBlock block:ComponentFunction) -> [CGFloat] {
    
    var comps:[CGFloat] = []
    
    for comp in array {
        comps.append(block(comp))
    }
    
    return comps
}

public func iterateComponents<T: HasComponents>(c:T, withBlock block:ComponentFunction) -> T {
    
    let comps = iterateComponents(c.components, withBlock: block)
    return T(components: comps)
}

// MARK: - Operator
infix operator >>> { associativity left precedence 151 }
public func >>><T: HasComponents>(lhs:T, rhs:ComponentFunction) -> T {
    return iterateComponents(lhs, withBlock: rhs)
}

public func >>>(lhs:[CGFloat], rhs:ComponentFunction) -> [CGFloat] {
    return iterateComponents(lhs, withBlock: rhs)
}

public func >>><T: HasComponents>(LHS:T.Type, rhs:(Int) -> CGFloat) -> T {
    
    var comps:[CGFloat] = []
    for iii in 0..<LHS.numberOfComponents {
        comps.append(rhs(iii))
    }
    return LHS.init(components: comps)
}

// MARK: - Conformance Extensions
extension CGFloat: HasComponents {
    
    public static let numberOfComponents = 1
    
    public var components:[CGFloat] { return [self] }
    
    public init(components:[CGFloat]) {
        let comps = components.arrayByPadding(0.0, toLength: 1)
        
        self = comps[0]
    }
    
}

extension NSPoint: HasComponents {
    
    public static let numberOfComponents = 2
    
    public var components:[CGFloat] { return [self.x, self.y] }
    
    public init(components:[CGFloat]) {
        let comps = components.arrayByPadding(0.0, toLength: 2)
        
        self.init(x: comps[0], y: comps[1])
    }
    
}

extension NSSize: HasComponents {
    
    public static let numberOfComponents = 2
    public var components:[CGFloat] { return [self.width, self.height] }
    public init(components:[CGFloat]) {
        let comps = components.arrayByPadding(0.0, toLength: NSSize.numberOfComponents)
        self.init(width: comps[0], height: comps[1])
    }
}

extension NSRect: HasComponents {
    
    public static let numberOfComponents = 4
    public var components:[CGFloat] { return [self.origin.x, self.origin.y, self.size.width, self.size.height] }
    public init(components:[CGFloat]) {
        let comps = components.arrayByPadding(0.0, toLength: NSRect.numberOfComponents)
        self.init(x: comps[0], y: comps[1], width: comps[2], height: comps[3])
    }
}

extension SCVector3: HasComponents {
    
    public static let numberOfComponents = 3
    
    public var components:[CGFloat] { return [self.x, self.y, self.z] }
    
    public init(components:[CGFloat]) {
        
        let comps = components.arrayByPadding(0.0, toLength: 3)
        
        self.init(x: comps[0], y: comps[1], z: comps[2])
    }
    
}

extension SCVector4: HasComponents {
    
    public static let numberOfComponents = 4
    
    public var components:[CGFloat] { return [self.x, self.y, self.z, self.w] }
    
    public init(components:[CGFloat]) {
        
        let comps = components.arrayByPadding(0.0, toLength: 4)
        
        self.init(x: comps[0], y: comps[1], z: comps[2], w: comps[3])
    }
    
}
