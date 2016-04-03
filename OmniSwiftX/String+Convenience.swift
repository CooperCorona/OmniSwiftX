//
//  String+Convenience.swift
//  Gravity
//
//  Created by Cooper Knaak on 4/20/15.
//  Copyright (c) 2015 Cooper Knaak. All rights reserved.
//

import Foundation

extension String {
    
    // MARK: - Typecasting
    
    public func getIntegerValue() -> Int       { return (self as NSString).integerValue }
    
    public func getCGFloatValue() -> CGFloat   { return CGFloat((self as NSString).floatValue) }
    
    public func getBoolValue() -> Bool          { return (self as NSString).boolValue }
    
    // MARK: - Characters
    
    public var characterCount:Int {
        return self.startIndex.distanceTo(self.endIndex)
    }
    
    public subscript(index:Int) -> Character? {
        
        if index < 0 || index >= self.characterCount {
            return nil
        }
        
        let stringIndex = self.startIndex.advancedBy(index)
        return self[stringIndex]
    }
    
    ///Returns the substring at a given range.
    public subscript(range:Range<Int>) -> String {
        let startIndex  = self.startIndex.advancedBy(range.startIndex)
        let endIndex    = self.startIndex.advancedBy(range.endIndex)
        return self.substringWithRange(startIndex..<endIndex)
    }
    
    public var firstCharacter:Character? {
        
        if self == "" {
            return nil
        }
        
        return self[self.startIndex]
    }
    
    public var lastCharacter:Character? {
        
        if self == "" {
            return nil
        }
        
        return self[self.endIndex.advancedBy(-1)]
    }
    
    public mutating func removeCharacterAtIndex(index:Int) -> Character? {
        
        if index < 0 || index >= self.characterCount {
            return nil
        }
        
        let stringIndex = self.startIndex.advancedBy(index)
        return self.removeAtIndex(stringIndex)
    }
    
    public mutating func setCharacter(char:Character, atIndex index:Int) {
        
        if index >= 0 && index < self.characterCount {
            let stringIndex = self.startIndex.advancedBy(index)
            self.replaceRange(stringIndex...stringIndex, with: "\(char)")
        }
        
        
    }
    
    public mutating func removeFirst() -> Character? {
        if self == "" {
            return nil
        }
        
        return self.removeAtIndex(self.startIndex)
    }
    
    public mutating func removeLast() -> Character? {
        
        if self == "" {
            return nil
        }
        
        let index = self.startIndex.advancedBy(self.startIndex.distanceTo(self.endIndex) - 1)
        return self.removeAtIndex(index)
    }
    
    public func convertCamelCaseToSpaces() -> String {
        let uppercaseSet = NSCharacterSet.uppercaseLetterCharacterSet()
        var str = self[0...0]
        for (iii, character) in self.utf16.enumerateRange(1..<self.characterCount) {
            if uppercaseSet.characterIsMember(character) {
                str += " "
            }
            if let curChar = self[iii] {
                str.append(curChar)
            }
        }
        return str
    }
    
    public func removeAllWhiteSpace() -> String {
        return self.componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceCharacterSet()).filter() { $0 != "" } .reduce("") { $0 + $1 }
    }
}



public struct StringCharacterGenerator: GeneratorType, SequenceType {
    
    public typealias Element   = Character
    public typealias Generator = StringCharacterGenerator
    
    private let base:String
    private var index = 0
    
    public init(base:String) {
        self.base = base
    }
    
    public mutating func next() -> Element? {
        self.index += 1
        return self.base[self.index]
    }
    
    public func generate() -> Generator {
        return self
    }
    
}

extension String: SequenceType {
    
    public typealias Generator = StringCharacterGenerator
    
    public func generate() -> Generator {
        return StringCharacterGenerator(base: self)
    }
    
}
