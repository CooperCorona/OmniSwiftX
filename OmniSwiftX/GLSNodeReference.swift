//
//  GLSNodeReference.swift
//  Gravity
//
//  Created by Cooper Knaak on 2/18/15.
//  Copyright (c) 2015 Cooper Knaak. All rights reserved.
//

import Foundation
import GLKit

public class GLSNodeReference: NSObject {
   
    public var node:GLSNode? = nil
    public var index:Int = 0 { willSet { self.node?.universalRenderIndex = newValue } }
    public var startIndex = 0
    public var vertexCount = 0
    
    public var endIndex:Int { return self.startIndex + self.vertexCount }
    public var vertexRange:Range<Int> { return self.startIndex..<self.endIndex }
    
    public var hidden:Bool {
        return self.node?.hidden ?? true
    }
    public var textureName:GLuint {
        return self.node?.texture?.name ?? CCTextureOrganizer.defaultName
    }
    public var shouldRemove:Bool {
        return self.node?.removeFromUniversalRenderer ?? true
    }
    
    public init(node:GLSNode, index:Int, startIndex:Int, vertexCount:Int) {
        
        self.node = node
        self.index = index
        self.startIndex = startIndex
        self.vertexCount = vertexCount
        self.node?.universalRenderIndex = self.index
        
        super.init()
    }//initialize
    
}
