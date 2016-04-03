//
//  NSRect+Enumeration.swift
//  OmniSwift
//
//  Created by Cooper Knaak on 10/17/15.
//  Copyright © 2015 Cooper Knaak. All rights reserved.
//

import Foundation

extension NSRect {
    
    public func enumerateInnerRectsWithSize(size:NSSize) -> [(x:Int, y:Int, rect:NSRect)] {
        var rects:[(x:Int, y:Int, rect:NSRect)] = []
        
        let xIter = Int(self.size.width / size.width)
        let yIter = Int(self.size.height / size.height)
        
        for j in 0..<yIter {
            for i in 0..<xIter {
                let origin = self.origin + (size * NSSize(width: i, height: j)).getNSPoint()
                rects.append((x: i, y: j, rect: NSRect(origin: origin, size: size)))
            }
        }
        
        return rects
    }
    
}