//
//  Set+Convenience.swift
//  OmniSwift
//
//  Created by Cooper Knaak on 11/29/15.
//  Copyright © 2015 Cooper Knaak. All rights reserved.
//

import Foundation

extension Set {
    
    public init(array:[Element]) {
        self.init(minimumCapacity: array.count)
        for value in array {
            self.insert(value)
        }
    }
    
    public mutating func removeRandomObject() -> Element? {
        guard let element = self.randomElement() else {
            return nil
        }
        self.remove(element)
        return element
    }
    
}