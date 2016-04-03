//
//  Stack.swift
//  OmniSwift
//
//  Created by Cooper Knaak on 7/3/15.
//  Copyright (c) 2015 Cooper Knaak. All rights reserved.
//

import Foundation

///A first-in, last-out array (stack) where only the top element is accessible.
public class Stack<T>: CustomStringConvertible {

    // MARK: - Types
    
    public typealias StackAlteredHandler = (Stack<T>) -> Void
    
    // MARK: - Properties
    
    private var array:[T] = []
    
    ///Number of items on stack.
    public var count:Int { return self.array.count }
    
    ///The top element of the stack, or nil if there is none.
    public var topValue:T? {
        return self.array.last
    }
    
    public var pushHandler:StackAlteredHandler? = nil
    public var popHandler:StackAlteredHandler?  = nil
    
    // MARK: - Setup
    
    public init() {
//        super.init()
    }
    
    // MARK: - Logic
    
    /**
    Pushes a value onto the top of the stack. Invokes *pushHandler* when finished.
    
    - parameter value: The value to push.
    */
    public func push(value:T) {
        self.array.append(value)
        self.pushHandler?(self)
    }
    
    /**
    Pops a value from the top of the stack, if possible. Invokes *popHandler* if successful.

    - returns: The popped value, or nil if the stack was empty.
    */
    public func pop() -> T? {
      
        if self.array.count <= 0 {
            return nil
        }
        
        let lastValue = self.array.removeLast()
        self.popHandler?(self)
        
        return lastValue
    }
    
    
    // MARK: - CustomStringConvertible
    
    public var description:String {
        var string = "[\n"
        for iii in 0..<self.count {
            string += "\(self.array[self.count - iii - 1])\n"
        }
        return string + "]"
    }
}
