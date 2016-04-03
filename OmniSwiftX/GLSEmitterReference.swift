//
//  GLSEmitterReference.swift
//  Gravity
//
//  Created by Cooper Knaak on 2/20/15.
//  Copyright (c) 2015 Cooper Knaak. All rights reserved.
//

import GLKit

public class GLSEmitterReference: NSObject {

    weak var emitter:GLSParticleEmitter? = nil
    public var framebuffer:GLuint { return self.emitter?.buffer.framebuffer ?? 0 }
    public var textureName:GLuint {
        return self.emitter?.particleTexture?.name ?? CCTextureOrganizer.textureForString("White Tile")!.name
    }
    
    public var startIndex = 0
    public var vertexCount = 0
    public var endIndex:Int { return self.startIndex + self.vertexCount }
    
    public var hidden:Bool {
        return self.emitter?.hidden ?? true
    }
    public var shouldRemove:Bool {
        return self.emitter?.removeFromUniversalRenderer ?? true
    }

    
    public init(emitter:GLSParticleEmitter, startIndex:Int) {
        self.emitter = emitter
        self.startIndex = startIndex
        
        super.init()
    }
    
    public func updateIndices(start:Int) {
        self.startIndex = start
        self.vertexCount = self.emitter?.particles.count ?? 0
    }
    
}
