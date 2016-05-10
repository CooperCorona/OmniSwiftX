//
//  NSColor+Math.swift
//  NoisyImagesOSX
//
//  Created by Cooper Knaak on 4/9/16.
//  Copyright © 2016 Cooper Knaak. All rights reserved.
//

import Cocoa

public extension NSColor {

    public class func violetColor() -> NSColor {
        return NSColor(red: 0.4, green: 0.0, blue: 0.8, alpha: 1.0)
    }//my personal purple color
    
    public class func darkRedColor() -> NSColor {
        return NSColor(red: 0.5, green: 0.0, blue: 0.0, alpha: 1.0)
    }//dark red
    
    public class func darkGreenColor() -> NSColor {
        return NSColor(red: 0.0, green: 0.5, blue: 0.0, alpha: 1.0)
    }//dark green
    
    public class func darkBlueColor() -> NSColor {
        return NSColor(red: 0.0, green: 0.0, blue: 0.5, alpha: 1.0)
    }//dark blue
    
    public convenience init(string:String) {
        
        let comps = string.componentsSeparatedByString(", ") as [NSString]
        let r = CGFloat(comps[0].floatValue)
        let g = CGFloat(comps[1].floatValue)
        let b = CGFloat(comps[2].floatValue)
        var a:CGFloat = 1.0
        
        if (comps.count >= 4) {
            a = CGFloat(comps[3].floatValue)
        }
        
        self.init(red: r, green: g, blue: b, alpha: a)
    }//initialize with a string
    
    public convenience init(vector3:SCVector3) {
        self.init(red: vector3.r, green: vector3.g, blue: vector3.b, alpha: 1.0)
    }//initialize
    
    public convenience init(vector4:SCVector4) {
        self.init(red: vector4.r, green: vector4.g, blue: vector4.b, alpha: vector4.a)
    }//initialize
    
    public func getComponents() -> [CGFloat] {
        
        var red:CGFloat = 0.0
        var green:CGFloat = 0.0
        var blue:CGFloat = 0.0
        var alpha:CGFloat = 0.0

        self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        return [red, green, blue, alpha]
    }//get components
    
    public func getHSBComponents() -> [CGFloat] {
        var hue:CGFloat         = 0.0
        var saturation:CGFloat  = 0.0
        var brightness:CGFloat  = 0.0
        var alpha:CGFloat       = 0.0
        self.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        return [hue, saturation, brightness, alpha]
    }
    
    public func getVector3() -> SCVector3 {
        
        let comps = self.getComponents()
        
        return SCVector3(xValue: comps[0], yValue: comps[1], zValue: comps[2])

    }//get SCVector3
    
    public func getVector4() -> SCVector4 {
        
        let comps = self.getComponents()
        
        return SCVector4(xValue: comps[0], yValue: comps[1], zValue: comps[2], wValue: comps[3])

    }//get SCVector4
    
    //Gets a string.
    //Initializing with the returned String
    //is guarunteed to return a NSColor
    //object that represents the same
    //color as this object
    public func getString() -> String {
        let comps = self.getComponents()
        return "\(comps[0]), \(comps[1]), \(comps[2]), \(comps[3])"
    }
    
    ///Returns either black or white, whichever would show up better when displayed over this color.
    public func absoluteContrastingColor() -> NSColor {
        var comps = self.getComponents()
        
        let brightness = comps[0] * 0.2 + comps[1] * 0.7 + comps[2] * 0.1
        if brightness > 0.5 {
            return NSColor.blackColor()
        } else {
            return NSColor.whiteColor()
        }
    }
    
    ///Lightens or darkens only the RGB values (not the alpha).
    public func scaleRGB(factor:CGFloat) -> NSColor {
        let rgba = self.getComponents()
        return NSColor(red: rgba[0] * factor, green: rgba[1] * factor, blue: rgba[2] * factor, alpha: rgba[3])
    }
    
}// UIKit + Math

public func +(left:NSColor, right:NSColor) -> NSColor {
    let lComps = left.getComponents()
    let rComps = right.getComponents()
    
    return NSColor(red: lComps[0] + rComps[0], green: lComps[1] + rComps[1], blue: lComps[2] + rComps[2], alpha: lComps[3] + rComps[3])
}// +

public func -(left:NSColor, right:NSColor) -> NSColor {
    let lComps = left.getComponents()
    let rComps = right.getComponents()
    
    return NSColor(red: lComps[0] - rComps[0], green: lComps[1] - rComps[1], blue: lComps[2] - rComps[2], alpha: lComps[3] - rComps[3])
}// -

public func *(left:NSColor, right:NSColor) -> NSColor {
    let lComps = left.getComponents()
    let rComps = right.getComponents()
    
    return NSColor(red: lComps[0] * rComps[0], green: lComps[1] * rComps[1], blue: lComps[2] * rComps[2], alpha: lComps[3] * rComps[3])
}// *

public func /(left:NSColor, right:NSColor) -> NSColor {
    let lComps = left.getComponents()
    let rComps = right.getComponents()
    
    return NSColor(red: lComps[0] / rComps[0], green: lComps[1] / rComps[1], blue: lComps[2] / rComps[2], alpha: lComps[3] / rComps[3])
}// /

public func +=(inout left:NSColor, right:NSColor) {
    left = left + right
}// +=

public func -=(inout left:NSColor, right:NSColor) {
    left = left - right
}// -=

public func *=(inout left:NSColor, right:NSColor) {
    left = left * right
}// *=

public func /=(inout left:NSColor, right:NSColor) {
    left = left / right
}// /=


public func +(left:NSColor, right:CGFloat) -> NSColor {
     let lComps = left.getComponents()
    
    return NSColor(red: lComps[0] + right, green: lComps[1] + right, blue: lComps[2] + right, alpha: lComps[3] + right)
}// + scalar

public func -(left:NSColor, right:CGFloat) -> NSColor {
     let lComps = left.getComponents()
    
    return NSColor(red: lComps[0] - right, green: lComps[1] - right, blue: lComps[2] - right, alpha: lComps[3] - right)
}// - scalar

public func *(left:NSColor, right:CGFloat) -> NSColor {
     let lComps = left.getComponents()
    
    return NSColor(red: lComps[0] * right, green: lComps[1] * right, blue: lComps[2] * right, alpha: lComps[3] * right)
}// * scalar

public func /(left:NSColor, right:CGFloat) -> NSColor {
     let lComps = left.getComponents()
    
    return NSColor(red: lComps[0] / right, green: lComps[1] / right, blue: lComps[2] / right, alpha: lComps[3] / right)
}// / scalar

public func +=(inout left:NSColor, right:CGFloat) {
    left = left + right
}// +=

public func -=(inout left:NSColor, right:CGFloat) {
    left = left - right
}// -=

public func *=(inout left:NSColor, right:CGFloat) {
    left = left * right
}// *=

public func /=(inout left:NSColor, right:CGFloat) {
    left = left / right
}// /=


//Tuples
public typealias NSColorTuple4 = (CGFloat, CGFloat, CGFloat, CGFloat)

public func +(left:NSColor, right:NSColorTuple4) -> NSColor {
     let comps = left.getComponents()
    return NSColor(red: comps[0] + right.0, green: comps[1] + right.1, blue: comps[2] + right.2, alpha: comps[3] + right.3)
}

public func -(left:NSColor, right:NSColorTuple4) -> NSColor {
     let comps = left.getComponents()
    return NSColor(red: comps[0] - right.0, green: comps[1] - right.1, blue: comps[2] - right.2, alpha: comps[3] - right.3)
}

public func *(left:NSColor, right:NSColorTuple4) -> NSColor {
     let comps = left.getComponents()
    return NSColor(red: comps[0] * right.0, green: comps[1] * right.1, blue: comps[2] * right.2, alpha: comps[3] * right.3)
}

public func /(left:NSColor, right:NSColorTuple4) -> NSColor {
     let comps = left.getComponents()
    return NSColor(red: comps[0] / right.0, green: comps[1] / right.1, blue: comps[2] / right.2, alpha: comps[3] / right.3)
}

public func +(left:NSColorTuple4, right:NSColor) -> NSColor {
    return right + left
}

public func -(left:NSColorTuple4, right:NSColor) -> NSColor {
     let comps = right.getComponents()
    return NSColor(red: left.0 - comps[0], green: left.1 - comps[1], blue: left.2 - comps[2], alpha: left.3 - comps[3])
}

public func *(left:NSColorTuple4, right:NSColor) -> NSColor {
    return right * left
}

public func /(left:NSColorTuple4, right:NSColor) -> NSColor {
     let comps = right.getComponents()
    return NSColor(red: left.0 / comps[0], green: left.1 / comps[1], blue: left.2 / comps[2], alpha: left.3 / comps[3])
}

public func +=(inout left:NSColor, right:NSColorTuple4) {
    left = left + right
}

public func -=(inout left:NSColor, right:NSColorTuple4) {
    left = left - right
}

public func *=(inout left:NSColor, right:NSColorTuple4) {
    left = left * right
}

public func /=(inout left:NSColor, right:NSColorTuple4) {
    left = left / right
}