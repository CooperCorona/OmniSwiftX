//
//  NSFileManager+Convenience.swift
//  OmniSwift
//
//  Created by Cooper Knaak on 8/30/15.
//  Copyright (c) 2015 Cooper Knaak. All rights reserved.
//

import Foundation

extension NSFileManager {
    
    /**
    Gets all files of a bundle with a given file extension.
    
    - parameter type: The file extension (png, pdf, vsh)
    - parameter removeExtensions: Whether to remove the file extensions in the returned array. Default value is true.
    - returns: An array of all file paths with a given extension in the bundle.
    */
    public func allFilesOfType(type:String, removeExtensions:Bool = true) -> [NSURL] {
        var paths:[NSURL] = []
        let omniSwiftBundle = NSBundle.allFrameworks().filter() { $0.bundlePath.hasSuffix(("OmniSwift.framework")) } .objectAtIndex(0)
//        if let path = NSBundle.mainBundle().resourcePath, let enumerator = self.enumeratorAtPath(path) {
        if let path = omniSwiftBundle?.resourcePath, let enumerator = self.enumeratorAtPath(path) {
            while let currentPath = enumerator.nextObject() as? String, let currentURL = NSURL(string: currentPath) {
                if currentURL.pathExtension == type {
                    paths.append(currentURL)
                }
            }
        }
        
        if removeExtensions {
            return paths.flatMap() { $0.URLByDeletingPathExtension }
        } else {
            return paths
        }
    }
    
    /**
    Gets all files of a bundle with given file extensions.
    
    - parameter type: An array containing the desired file extensions (png, pdf, vsh)
    - parameter removeExtensions: Whether to remove the file extensions in the returned dictionary. Default value is true.
    - returns: An dictionary of all file paths with given extensions in the bundle.
    */
    public func allFilesOfTypes(types:[String], removeExtensions:Bool = true) -> [String:String] {
        
        var paths:[String:String] = [:]
        
        if let path = NSBundle.mainBundle().resourcePath, let enumerator = self.enumeratorAtPath(path) {
            while let currentPath = enumerator.nextObject() as? String, let currentURL = NSURL(string: currentPath), pathExtension = currentURL.pathExtension {
                if let index = types.indexOf(pathExtension) {
                    let key = (removeExtensions ? currentURL.URLByDeletingPathExtension?.absoluteString : currentURL.absoluteString) ?? currentURL.absoluteString
                    paths[key] = types[index]
                }
            }
        }
        
        return paths
    }
    
    public func documentsDirectory() -> NSURL? {
        return NSFileManager.defaultManager().URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask).first
    }
    
    public class func fileExistsInDocuments(file:String, fileExtension:String) -> Bool {
        let path = UniversalSaverBase.pathForFile(file, fileExtension: fileExtension)
        return NSFileManager.defaultManager().fileExistsAtPath(path)
    }
}