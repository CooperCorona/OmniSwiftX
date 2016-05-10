//
//  Array+Convenience.swift
//  InverseKinematicsTest
//
//  Created by Cooper Knaak on 10/13/14.
//  Copyright (c) 2014 Cooper Knaak. All rights reserved.
//

import Foundation

extension Array {
    
    public var range:Range<Int> { return 0..<self.count }
    
    public func size() -> Int {
        
            if (self.count == 0) {
                    return 0
            }//no elements
        
        return sizeofValue(self[0]) * self.count
    }//get size
    
    /*
     *  For some reason, casting arc4random() to Int
     *  crashes on iPad 2 device. Casting the result
     *  of arc4random() % self.count (where self.count
     *  is itself cast to UInt32) to Int succeeds
     */
    public func randomObject() -> Element? {
        
        if (self.count <= 0) {
            return nil
        }
        
        let index = Int(arc4random() % UInt32(self.count))
        return self[index]
    }//get a random object
    
    /**
    Removes a random object from the array.
    
    - returns: The element removed, or nil if the array was empty.
    */
    public mutating func removeRandomObject() -> Element? {
        if self.count <= 0 {
            return nil
        }
        
        let index = Int(arc4random() % UInt32(self.count))
        return self.removeAtIndex(index)
    }
    
    /**
    Safely gets the object at the index from the array.
    
    - parameter index: The index of the object to get.
    - returns: The object at *index*, or nil if no object exists.
    */
    public func objectAtIndex(index:Int) -> Element? {
        if index < 0 || index >= self.count {
            return nil
        }

        return self[index]
    }
    
    public func findObject(predicate:(Element) -> Bool) -> Element? {
        for object in self {
            if predicate(object) {
                return object
            }
        }
        return nil
    }
    
    /**
    Adds enough values to the end the array so that it has a specified length.
    
    - parameter value: The value to be repeated.
    - parameter length: The final length of the array.
    */
    public mutating func pad(value:Element, toLength length:Int) {
        
        while self.count < length {
            self.append(value)
        }
    }
    
    /**
    Iterates through the array, comparing elements to find which is the desired one.
    
    - parameter isBetter: A closure that takes two elements and returns which one is considered better.
    - returns: The element that was determined to be the best, according to *isBetter* or nil if the array is empty.
    */
    public func findBest(isBetter:(Element, Element) -> Element) -> Element? {
        guard var bestElement = self.first else {
            return nil
        }
        for (_, element) in self.enumerateSkipFirst() {
            bestElement = isBetter(bestElement, element)
        }
        
        return bestElement
    }
    
    /**
    Iterates through the array, comparing elements to find which is the desired one.
    
    - parameter isBetter: A closure that takes two elements and returns true if the first is considered better.
    - returns: The element that was determined to be the best, according to *isBetter* or nil if the array is empty.
    */
    public func findBest(isBetter:(Element, Element) -> Bool) -> Element? {
        guard var bestElement = self.first else {
            return nil
        }
        for (_, element) in self.enumerateSkipFirst() {
            bestElement = isBetter(bestElement, element) ? bestElement : element
        }
        return bestElement
    }
    
    /**
    Copies this array and adds enough values to the end so that it has a specified length.
    
    - parameter value: The value to be repeated.
    - parameter length: The final length of the array.
    - returns: An array with length *length*.
    */
    public func arrayByPadding(value:Element, toLength length:Int) -> [Element] {
        
        var newArray = self
        newArray.pad(value, toLength: length)
        return newArray
    }
    
    
    public func recursiveReduce(firstValue:Element, handler:(Element) -> [Element]) -> [Element] {
        return [firstValue] + handler(firstValue).recursiveReduce(handler)
    }
    
    public func recursiveReduce(handler:(Element) -> [Element]) -> [Element] {
        var array:[Element] = []
        for value in self {
            array.append(value)
            array += handler(value).recursiveReduce(handler)
        }
        return array
    }
    
    
    /**
    Uses the insertion sort algorithm to sort this array. Stable.
    
    - parameter isOrderedBefore: A closure taking two elements and returning whether the 1st should be placed before the 2nd.
    */
    public mutating func insertionSortInPlace(@noescape isOrderedBefore:(Element, Element) -> Bool) {
        
        if self.count <= 1 {
            return
        }
        
        for iii in 1..<self.count {
            var jjj = iii
            while jjj > 0 && isOrderedBefore(self[jjj], self[jjj - 1]) {
                swap(&self[jjj - 1], &self[jjj])
                jjj -= 1
            }
        }
        
    }
    
    /**
    Uses the insertion sort algorithm to sort a copy of this array. Stable.
    
    - parameter isOrderedBefore: A closure taking two elements and returning whether the 1st should be placed before the 2nd.
    - returns: A copy of this array, sorted according to isOrderedBefore.
    */
    public func insertionSort(@noescape isOrderedBefore:(Element, Element) -> Bool) -> [Element] {
        var sortedArray = self
        sortedArray.insertionSortInPlace(isOrderedBefore)
        return sortedArray
    }
    
    
    
    public func enumerateSkipFirst() -> SliceEnumerateSequence<Array> {
        if self.count == 0 {
            return SliceEnumerateSequence(base: self, range: 0..<0)
        } else {
            return self.enumerateRange(1..<self.count)
        }
    }
    
    public func enumerateSkipLast() -> SliceEnumerateSequence<Array> {
        if self.count == 0 {
            return SliceEnumerateSequence(base: self, range: 0..<0)
        } else {
            return self.enumerateRange(0..<self.count - 1)
        }
    }
    
    
    /**
     Removes the elements at the given indices, making sure to remove them in the correct order so the right indices are removed.
     
     - parameter indices: The indices to remove. It is a set because trying to remove the same index twice would screw up.
     - returns: The elements at the removed indices.
    */
    public mutating func removeAtIndices(indices:Set<Int>) -> [Element] {
        var removedElements:[Element] = []
        for index in indices.sort({ $0 > $1 }) {
            removedElements.append(self.removeAtIndex(index))
        }

        return removedElements
    }
    
}//extend Array

public func removeObject<T: AnyObject>(object:T, inout fromArray:Array<T>) -> T? {
    
    for iii in 0..<fromArray.count {
        
        if (object === fromArray[iii])
        {//found object
            fromArray.removeAtIndex(iii)
            return object
        }//found object
        
    }//loop through array
    
    return nil
}//remove object

public func removeObjects<T: AnyObject>(objects:[T], inout fromArray:[T]) {
    
    for curObject in objects {
        
        /*for iii in 0..<fromArray.count {
            if (curObject === fromArray[iii]) {
                fromArray.removeAtIndex(iii)
                break
            }
        }*/
        removeObject(curObject, fromArray: &fromArray)
        
    }
    
}//remove objects

public func object<T>(array:[T], atIndex index:Int) -> T? {
    
    if index < 0 || index >= array.count {
        return nil
    }
    
    return array[index]
}

public func pad<T>(value:T, inout array:[T], toLength length:Int) {
    while array.count < length {
        array.append(value)
    }
}

public func array<T>(array:[T], byPadding value:T, toLength length:Int) -> [T] {
    var paddedArray = array
    pad(value, array: &paddedArray, toLength: length)
    return paddedArray
}

// MARK: - Sliced Enumeration
public struct SliceEnumerateGenerator<Base: GeneratorType>: GeneratorType, SequenceType {
    
    public typealias Element = (index: Int, element: Base.Element)
    public typealias Generator = SliceEnumerateGenerator
    
    private var base:Base
    private let range:Range<Int>
//    private var index = 0
    private var index:RangeGenerator<Int>
    private var firstTime = true
    
    init(base: Base, range:Range<Int>) {
        self.base   = base
        self.range  = range
        self.index  = range.generate()
    }
    
    mutating public func next() -> Element? {
        
        //Makes sure you start at right index,
        //otherwise you start generating at the
        //first index, which is not what I want.
        if self.firstTime {
            
            for _ in 0..<self.range.startIndex {
                if self.base.next() == nil {
                    return nil
                }
            }
            
            self.firstTime = false
        }
        
        if let nextBase = base.next(), currentIndex = self.index.next() {
            return (index: currentIndex, element: nextBase)
        } else {
            return nil
        }
    }
    
    public func generate() -> Generator {
        return self
    }
    
}

public struct SliceEnumerateSequence<Base: SequenceType>: SequenceType {
    
    public typealias Generator = SliceEnumerateGenerator<Base.Generator>
    
    private var base:Base
    private let range:Range<Int>
    
    init(base:Base, range:Range<Int>) {
        self.base   = base
        self.range  = range
    }

    public func generate() -> Generator {
        return SliceEnumerateGenerator(base: base.generate(), range: range)
    }
    
}

public func enumerate<Seq : SequenceType>(sequence:Seq, range:Range<Int>) -> SliceEnumerateSequence<Seq> {
    return SliceEnumerateSequence(base: sequence, range: range)
}

extension SequenceType {
    
    ///Enumerates the array, returning (index, element) pairs, but only for a given range.
    public func enumerateRange(range:Range<Int>) -> SliceEnumerateSequence<Self> {
        return SliceEnumerateSequence(base: self, range: range)
    }
    
}

extension CollectionType {
    
    public func randomElement() -> Self.Generator.Element? {
        
        guard self.count > 0 else {
            return nil
        }
        
        let index = Int(arc4random() % UInt32(self.count.toIntMax()))
        for (i, element) in self.enumerate() where i == index {
            return element
        }
        return nil
    }
    
}
