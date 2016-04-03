//
//  NSRegularExpression+Convenience.swift
//  EQParser
//
//  Created by Cooper Knaak on 2/1/16.
//  Copyright © 2016 Cooper Knaak. All rights reserved.
//

import Foundation

extension NSRange {
    
    public var range:Range<Int> { return self.location..<self.location + self.length }
    
}

func +(lhs:Range<Int>, rhs:Int) -> Range<Int> {
    return lhs.startIndex+rhs..<lhs.endIndex+rhs
}

extension NSRegularExpression {
    
    public convenience init?(regex:String) {
        do {
            try self.init(pattern: regex, options: [])
        } catch {
            return nil
        }
    }
    
    public func matchesInString(string:String) -> [NSTextCheckingResult] {
        return self.matchesInString(string, options: [], range: NSRange(location: 0, length: string.characterCount))
    }
    
    public func matchedStringsInString(string:String) -> [String] {
        return self.rangesInString(string).map() { string[$0] }
    }
    
    public func rangesInString(string:String) -> [Range<Int>] {
        return self.matchesInString(string).map() { $0.range.range }
    }
}

extension String {
    
    public func matchesRegex(regex:String) -> Bool {
        guard let regExpress = NSRegularExpression(regex: regex) else {
            return false
        }
        return regExpress.matchesInString(self).count > 0
    }
    
    public func replaceRegex(regex:String, with replaceStr:String) -> String {
        guard let expression = NSRegularExpression(regex: regex) else {
            return self
        }
        let matches = expression.matchesInString(self)
        
        var copiedString = self
        copiedString.replaceRanges(matches.map() { ($0.range.location..<$0.range.location+$0.range.length, replaceStr) })
        return copiedString
    }
    
    public mutating func replaceRegex(regex:String, with replacements:[String]) -> [String] {
        guard let expression = NSRegularExpression(regex: regex) else {
            return []
        }
        let matches = expression.matchesInString(self)
        
        var replacementIndex = 0
        let replaces = self.replaceRanges(matches.map() { ($0.range.location..<$0.range.location+$0.range.length, replacements.objectAtIndex(replacementIndex++) ?? "?") })
        return replaces
    }
    
    public mutating func replaceRegex<T: GeneratorType where T.Element == String>(regex:String, var with replacements:T) -> [String] {
        guard let expression = NSRegularExpression(regex: regex) else {
            return []
        }
        let matches = expression.matchesInString(self)
        
        var copiedString = self
        let replaces = copiedString.replaceRanges(matches.map() { ($0.range.location..<$0.range.location+$0.range.length, replacements.next() ?? "?") })
        return replaces
    }
    
    public func componentsSeperatedByRegex(str:String) -> [String] {
        guard let regex = NSRegularExpression(regex: str) else {
            return [self]
        }
        
        let ranges = regex.rangesInString(self)
        guard let firstRange = ranges.first else {
            return [self]
        }
        var strings:[String] = []
        strings.append(self[0..<firstRange.startIndex])
        var previousEnd = firstRange.endIndex
        for (_, range) in ranges.enumerateSkipFirst() {
            strings.append(self[previousEnd..<range.startIndex])
            previousEnd = range.endIndex
        }
        strings.append(self[previousEnd..<self.characterCount])
        return strings
    }
    
}