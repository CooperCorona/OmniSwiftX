//
//  NSURL+Convenience.swift
//  OmniSwift
//
//  Created by Cooper Knaak on 11/25/15.
//  Copyright © 2015 Cooper Knaak. All rights reserved.
//

import Foundation

extension NSURL {
    
    public class func URLForPath(path:String, pathExtension:String) -> NSURL {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let documentURL = NSURL(fileURLWithPath: paths[0] as String, isDirectory: true)
        return documentURL.URLByAppendingPathComponent(path).URLByAppendingPathExtension(pathExtension)
    }
    
}