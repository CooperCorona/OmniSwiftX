//
//  Int+Convenience.swift
//  OmniSwift
//
//  Created by Cooper Knaak on 6/11/15.
//  Copyright (c) 2015 Cooper Knaak. All rights reserved.
//

import Foundation

extension Int {
    
    ///Enumerates from 0..<x and 0..<y, as if this int was a 2-dimensional array.
    public func enumerate2D(length:Int) -> [(x:Int, y:Int)] {
        var values:[(x:Int, y:Int)] = []
        for i in 0..<self {
            let x = i % length
            let y = i / length
            values.append((x: x, y: y))
        }
        return values
    }
    
}

infix operator /% { precedence 150 associativity left }

/**
Performs floating point division with integers.

- parameter lhs: Left integer parameter.
- parameter rhs: Right integer parameter.
- returns: Quotient of *lhs* / *rhs* after casting them to CGFloat.
*/
public func /%(lhs:Int, rhs:Int) -> CGFloat {
    return CGFloat(lhs) / CGFloat(rhs)
}