//
//  GLSCamera.swift
//  Gravity
//
//  Created by Cooper Knaak on 2/19/15.
//  Copyright (c) 2015 Cooper Knaak. All rights reserved.
//

import Foundation
import AppKit

public class GLSCamera: NSObject {
    
    public var position:NSPoint { return /*self.controller?.container.position ??*/ NSPoint.zero }
    public var size = NSSize.zero
    public var controller:NSViewController? = nil
    
    public func centerForPosition(position:NSPoint) -> NSPoint {
        
        if let cont = self.controller {
            
            let vSize = cont.view.frame.size
            
            return NSPoint(x: vSize.width / 2.0 - position.x, y: vSize.height / 2.0 - position.y)
        } else {
            return NSPoint(x: -1.0, y: -1.0)
        }
        
    }//get center of container (so that 'position' is in center of screen)
    
    public func clampCenter(center:NSPoint) -> NSPoint {
        
        if let cont = self.controller {
            
            let vSize = cont.view.frame.size
            
            //These coordinates assume that the given andreturned
            //'center' correspond to a bottom-left origin
            let maxX:CGFloat = 0.0
            let maxY:CGFloat = 0.0
            let minX = vSize.width - self.size.width
            let minY = vSize.height - self.size.height
            
            let xpos = min(max(center.x, minX), maxX)
            let ypos = min(max(center.y, minY), maxY)
            
            return NSPoint(x: xpos, y: ypos)
            
        } else {
            return center
        }
        
    }//clamp center so you never see off-screen

}

public extension GLSCamera {
    
    public func convertPointToOpenGL(point:NSPoint) -> NSPoint {
        
        var glPoint = point
        if let vSize = self.controller?.view.frame.size {
            glPoint = NSPoint(x: glPoint.x, y: vSize.height - glPoint.y)
        }
        
        return glPoint - self.position
    }//convert UI point to GL point
    
    public func convertPointFromOpenGL(point:NSPoint) -> NSPoint {
        
        var glPoint = point + self.position
        
        if let vSize = self.controller?.view.frame.size {
            glPoint = NSPoint(x: glPoint.x, y: vSize.height - glPoint.y)
        }
        
        return glPoint
    }//convert GL point to UI point
    
    public func convertRectToOpenGL(rect:NSRect) -> NSRect {
        var origin = rect.origin
        var maxPoint = origin + rect.size.getNSPoint()
        
        origin = self.convertPointToOpenGL(origin)
        maxPoint = self.convertPointToOpenGL(maxPoint)
        
        var glRect = NSRect(x: origin.x, y: origin.y, width: maxPoint.x - origin.x, height: maxPoint.y - origin.y)
        glRect.standardizeInPlace()
        return glRect
    }//convert rect to OpenGL
    
    public func convertRectFromOpenGL(rect:NSRect) -> NSRect {
        var origin = rect.origin
        var maxPoint = origin + rect.size.getNSPoint()
        
        origin = self.convertPointFromOpenGL(origin)
        maxPoint = self.convertPointFromOpenGL(maxPoint)
        
        var uiRect = NSRect(x: origin.x, y: origin.y, width: maxPoint.x - origin.x, height: maxPoint.y - origin.y)
        uiRect.standardizeInPlace()
        return uiRect
    }//convert rect to OpenGL
    
}//Conversions