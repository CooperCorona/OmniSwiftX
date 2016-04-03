//
//  CombineIteration.swift
//  OmniSwift
//
//  Created by Cooper Knaak on 11/11/15.
//  Copyright © 2015 Cooper Knaak. All rights reserved.
//

import Foundation

public struct IterateWithGenerator<T: GeneratorType, U: GeneratorType>: GeneratorType, SequenceType {
    
    public typealias Generator = IterateWithGenerator
    public typealias Element   = (T.Element, U.Element)
    
    private var firstGenerator:T
    private var secondGenerator:U
    
    public init(first:T, second:U) {
        self.firstGenerator     = first
        self.secondGenerator    = second
    }
    
    public mutating func next() -> Element? {
        guard let first = self.firstGenerator.next(), second = self.secondGenerator.next() else {
            return nil
        }
        return (first, second)
    }
    
    public func generate() -> IterateWithGenerator {
        return self
    }
    
}

public struct EnumerateWithGenerator<T: GeneratorType, U: GeneratorType>: GeneratorType, SequenceType {
    
    public typealias Generator  = EnumerateWithGenerator
    public typealias Element    = (Int, T.Element, U.Element)
    
    private var firstGenerator:T
    private var secondGenerator:U
    private var index = 0
    
    public init(first:T, second:U) {
        self.firstGenerator     = first
        self.secondGenerator    = second
    }
    
    public mutating func next() -> Element? {
        guard let first = self.firstGenerator.next(), second = self.secondGenerator.next() else {
            return nil
        }
        let currentIndex = self.index
        self.index += 1
        return (currentIndex, first, second)
    }
    
    public func generate() -> Generator {
        return self
    }
}

public struct EnumerateRangeWithGenerator<T: GeneratorType, U: GeneratorType>: GeneratorType, SequenceType {
    
    public typealias Generator  = EnumerateRangeWithGenerator
    public typealias Element    = (Int, T.Element, U.Element)
    
    private var firstGenerator:T
    private var secondGenerator:U
    private let range:Range<Int>
    private var index = 0
    
    public init(first:T, second:U, range:Range<Int>) {
        self.firstGenerator     = first
        self.secondGenerator    = second
        self.range              = range
    }
    
    public mutating func next() -> Element? {
        
        //Must generate until elements start at correct spot.
        while self.index < self.range.startIndex {
            if self.firstGenerator.next() == nil || self.secondGenerator.next() == nil {
                return nil
            }
            self.index += 1
        }
        
        guard let first = self.firstGenerator.next(), second = self.secondGenerator.next() where self.index < range.endIndex else {
            return nil
        }
        let currentIndex = self.index
        self.index += 1
        return (currentIndex, first, second)
    }
    
    public func generate() -> Generator {
        return self
    }
}

extension SequenceType {
    
    public func iterateWith<T: SequenceType>(otherSequence:T) -> IterateWithGenerator<Self.Generator, T.Generator> {
        return IterateWithGenerator(first: self.generate(), second: otherSequence.generate())
    }
    
    public func enumerateWith<T: SequenceType>(otherSequence:T) -> EnumerateWithGenerator<Self.Generator, T.Generator> {
        return EnumerateWithGenerator(first: self.generate(), second: otherSequence.generate())
    }
    
    public func enumerateWith<T: SequenceType>(otherSequence:T, range:Range<Int>) -> EnumerateRangeWithGenerator<Self.Generator, T.Generator> {
        return EnumerateRangeWithGenerator(first: self.generate(), second: otherSequence.generate(), range: range)
    }
    
}