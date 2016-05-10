//
//  GLSSprite.swift
//  Fields and Forces
//
//  Created by Cooper Knaak on 12/13/14.
//  Copyright (c) 2014 Cooper Knaak. All rights reserved.
//

import Foundation
import GLKit

public class GLSSprite: GLSNode {
   
//    var projection:SCMatrix4 = SCMatrix4()
    
    override public var texture:CCTexture? {
        didSet {
            self.setQuadForTexture()
        }
    }
    /*
    public var program:GLuint = 0
    public var vertexBuffer:GLuint = 0
    public var u_Projection:GLint = 0
    public var u_ModelMatrix:GLint = 0
    public var u_TextureInfo:GLint = 0
    public var u_Alpha:GLint = 0
    public var u_TintColor:GLint = 0
    public var u_TintIntensity:GLint = 0
    public var u_ShadeColor:GLint = 0
    public var a_Position:GLint = 0
    public var a_Texture:GLint = 0
    */
    public let program = ShaderHelper.programDictionaryForString("Basic Shader")!
    
    public var storedMatrix = SCMatrix4()
    
    public init(position:NSPoint, size:NSSize, texture:CCTexture?) {
        
        super.init(position:position, size:size)
        
        let sizeAsPoint = size.getNSPoint()
        for iii in 0..<TexturedQuad.verticesPerQuad {
            self.vertices.append(UVertex())
            
            let pnt = TexturedQuad.pointForIndex(iii)
            vertices[iii].texture = pnt.getGLTuple()
            vertices[iii].position = (pnt * sizeAsPoint).getGLTuple()
        }
        
        self.texture = texture
        self.setQuadForTexture()
    }//initialize
    
    public convenience init(size:NSSize, texture:CCTexture?) {
        self.init(position: NSPoint.zero, size: size, texture: texture)
    }//initialize (without specifiying position)
    
    public convenience init(texture:CCTexture?) {
        self.init(size: NSSize.zero, texture: texture)
    }//initialize (only using texture)
    
    override public func contentSizeChanged() {
        let sizeAsPoint = self.contentSize.getNSPoint()
        for iii in 0..<TexturedQuad.verticesPerQuad {
            self.vertices[iii].position = (TexturedQuad.pointForIndex(iii) * sizeAsPoint).getGLTuple()
        }
        self.verticesAreDirty = true
    }
    
    override public func loadProgram() {
        /*
        glGenBuffers(1, &vertexBuffer)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), vertexBuffer)
        
        program = ShaderHelper.programForString("Basic Shader")!
        
        u_Projection = glGetUniformLocation(program, "u_Projection")
        u_ModelMatrix = glGetUniformLocation(program, "u_ModelMatrix")
        u_TextureInfo = glGetUniformLocation(program, "u_TextureInfo")
        u_Alpha = glGetUniformLocation(program, "u_Alpha")
        u_TintColor = glGetUniformLocation(program, "u_TintColor")
        u_TintIntensity = glGetUniformLocation(program, "u_TintIntensity")
        u_ShadeColor = glGetUniformLocation(program, "u_ShadeColor")
        a_Position = glGetAttribLocation(program, "a_Position")
        a_Texture = glGetAttribLocation(program, "a_Texture")
        */
    }//load program
    
    public func setQuadForTexture() {
        /*
        if let tex = texture {
            
            let minX = GLfloat(NSRectGetMinX(tex.frame))
            let maxX = GLfloat(NSRectGetMaxX(tex.frame))
            let minY = GLfloat(NSRectGetMinY(tex.frame))
            let maxY = GLfloat(NSRectGetMaxY(tex.frame))
            
            vertices[0].texture = (minX, maxY)
            vertices[1].texture = (minX, minY)
            vertices[2].texture = (maxX, maxY)
            vertices[3].texture = (maxX, minY)
            
        } else {
            for iii in 0..<4 {
                vertices[iii].texture = TexturedQuad.pointForIndex(iii).getGLTuple()
            }//loop through vertices
            
        }
        */
        
        let tFrame = self.texture?.frame ?? NSRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
        TexturedQuad.setTexture(tFrame, ofVertices: &self.vertices)
        self.verticesAreDirty = true
    }//set quad for texture
    
    override public func render(model: SCMatrix4) {
        
        if (self.hidden) {
            return
        }//hidden: don't render
        
        let childModel = self.modelMatrix() * model
        
        self.program.use()
        glBufferData(GLenum(GL_ARRAY_BUFFER), sizeof(UVertex) * self.vertices.count, self.vertices, GLenum(GL_STATIC_DRAW))
        
        self.program.bindTexture(self.texture?.name)
        self.program.uniformMatrix4fv("u_Projection", matrix: self.projection)
        self.program.uniformMatrix4fv("u_ModelMatrix", matrix: childModel)
        self.program.uniform1f("u_Alpha", value: self.alpha)
        self.program.uniform3f("u_TintIntensity", value: self.tintIntensity)
        self.program.uniform3f("u_TintColor", value: self.tintColor)
        self.program.uniform3f("u_ShadeColor", value: self.shadeColor)
        
        self.program.enableAttributes()
        self.program.bridgeAttributesWithSizes([2, 2], stride: sizeof(UVertex))
        
        glDrawArrays(TexturedQuad.drawingMode, 0, GLsizei(self.vertices.count))
        
        self.program.disable()
 
        super.render(model)
    }//render
    
    /*deinit {
        glDeleteBuffers(1, &self.vertexBuffer)
    }*/
    
    
    override public func clone() -> GLSSprite {
        
        let copiedSprite = GLSSprite(position: self.position, size: self.contentSize, texture: self.texture)
        
        copiedSprite.copyFromSprite(self)
        
        return copiedSprite
        
    }//clone
    
    public func copyFromSprite(node:GLSSprite) {
        
        super.copyFromNode(node)
        
        self.tintColor = node.tintColor
        self.tintIntensity = node.tintIntensity
        self.shadeColor = node.shadeColor
        
    }//copy from 'node'
    
}
