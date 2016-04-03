//
//  GLSNoiseSprite.swift
//  Gravity
//
//  Created by Cooper Knaak on 2/24/15.
//  Copyright (c) 2015 Cooper Knaak. All rights reserved.
//

import GLKit

///**DEPRECATED**
public class GLSNoiseSprite: GLSNode, DoubleBuffered {
    
    public struct NoiseVertex {
        
        public var position:(GLfloat, GLfloat) = (0.0, 0.0)
        public var texture:(GLfloat, GLfloat)  = (0.0, 0.0)
        public var color:(GLfloat, GLfloat, GLfloat) = (0.0, 0.0, 0.0)
        public var noiseColor:(GLfloat, GLfloat, GLfloat, GLfloat) = (0.0, 0.0, 0.0, 0.0)
        public var noiseTexture:(GLfloat, GLfloat) = (0.0, 0.0)
        
        public init() {
            
        }
    }
    
    public var noiseVertices:[NoiseVertex] = []
    
    public let noiseTexture:CCTexture?
    public var color:SCVector3 = SCVector3()       { didSet { self.applyNoiseVertices() } }
    public var noiseColor:SCVector4 = SCVector4()  { didSet { self.applyNoiseVertices() } }
    public var tiles = 1
    public var offset = NSPoint.zero
    public var textureAnchor:SCVector4 = SCVector4()
    
    public let buffer:GLSFrameBuffer
    public var shouldRedraw = false
    public var bufferIsDirty = false
    
    
    private var vertexBuffer:GLuint = 0
    public let program:GLuint
    public let u_Projection:GLint
    public let u_ModelMatrix:GLint
    public let u_TextureInfo:GLint
    public let u_Tiles:GLint
    public let u_Offset:GLint
    public let a_Position:GLint
    public let a_Texture:GLint
    public let a_NoiseTexture:GLint
    public let a_Color:GLint
    public let a_NoiseColor:GLint
    
    
    public init(size:NSSize, texture:CCTexture?, color:SCVector3, noiseColor:SCVector4, tiles:Int) {
        
        self.noiseTexture = texture
        self.color = color
        self.noiseColor = noiseColor
        self.tiles = tiles
        
        self.buffer = GLSFrameBuffer(size: size)
        self.buffer.bindClearColor()
        
        glGenBuffers(1, &self.vertexBuffer)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), self.vertexBuffer)
        
        self.program = ShaderHelper.programForString("Noise Shader")!
        self.u_Projection = glGetUniformLocation(self.program, "u_Projection")
        self.u_ModelMatrix = glGetUniformLocation(self.program, "u_ModelMatrix")
        self.u_TextureInfo = glGetUniformLocation(self.program, "u_TextureInfo")
        self.u_Tiles = glGetUniformLocation(self.program, "u_Tiles")
        self.u_Offset = glGetUniformLocation(self.program, "u_Offset")
        self.a_Position = glGetAttribLocation(self.program, "a_Position")
        self.a_Texture = glGetAttribLocation(self.program, "a_Texture")
        self.a_NoiseTexture = glGetAttribLocation(self.program, "a_NoiseTexture")
        self.a_Color = glGetAttribLocation(self.program, "a_Color")
        self.a_NoiseColor = glGetAttribLocation(self.program, "a_NoiseColor")
        
        if let vTex = texture {
            self.textureAnchor = SCVector4(x: vTex.frame.origin.x, y: vTex.frame.origin.y, z: vTex.frame.size.width, w: vTex.frame.size.height)
        }
        
        super.init(position: NSPoint.zero, size: size)
        
        self.vertices = self.buffer.sprite.vertices
        self.texture = self.buffer.sprite.texture
        
        self.applyNoiseVertices()
    }//initialize
    
    public func applyNoiseVertices() {
        
        for iii in 0..<TexturedQuad.verticesPerQuad {
            
            self.noiseVertices.append(NoiseVertex())
            
            let texture = TexturedQuad.pointForIndex(iii)
            let point = texture * NSPoint(x: self.contentSize.width, y: self.contentSize.height)
            
            self.noiseVertices[iii].position = point.getGLTuple()
            self.noiseVertices[iii].color = self.color.getGLTuple()
            self.noiseVertices[iii].noiseColor = self.noiseColor.getGLTuple()
            self.noiseVertices[iii].noiseTexture = texture.getGLTuple()
            
            if let vTex = self.noiseTexture {
                
                let sizeP = NSPoint(x: vTex.frame.size.width, y: vTex.frame.size.height)
                let origin = vTex.frame.origin
                
                self.noiseVertices[iii].texture = ((sizeP * texture) + origin).getGLTuple()
            } else {
                self.noiseVertices[iii].texture = texture.getGLTuple()
            }
            
        }
        
    }//apply variables to noise vertices
    
    //Ignores model matrix because I render to
    //background buffer
    override public func render(model: SCMatrix4) {
        
        let childModel = self.modelMatrix() * model
        
        glUseProgram(self.program)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), self.vertexBuffer)
        glBufferData(GLenum(GL_ARRAY_BUFFER), sizeof(NoiseVertex) * self.noiseVertices.count, self.noiseVertices, GLenum(GL_STATIC_DRAW))
        
        glBindTexture(GLenum(GL_TEXTURE_2D), self.noiseTexture?.name ?? CCTextureOrganizer.defaultName)
        glUniform1i(self.u_TextureInfo, 0)
        
        //        let proj = GLSUniversalRenderer.sharedInstance.projection
        let proj = self.projection
        glUniformMatrix4fv(self.u_Projection, 1, 0, proj.values)
        glUniformMatrix4fv(self.u_ModelMatrix, 1, 0, childModel.values)
        
        glUniform1i(self.u_Tiles, GLint(self.tiles))
        glUniform2f(self.u_Offset, GLfloat(self.offset.x), GLfloat(self.offset.y))
        
        let stride = sizeof(NoiseVertex)
        self.bridgeAttribute(self.a_Position, size: 2, stride: stride, position: 0)
        self.bridgeAttribute(self.a_Texture, size: 2, stride: stride, position: 2)
        self.bridgeAttribute(self.a_Color, size: 3, stride: stride, position: 4)
        self.bridgeAttribute(self.a_NoiseColor, size: 4, stride: stride, position: 7)
        self.bridgeAttribute(self.a_NoiseTexture, size: 2, stride: stride, position: 11)
        
        glDrawArrays(TexturedQuad.drawingMode, 0, GLsizei(self.noiseVertices.count))
        
        super.render(model)
    }//render
    
    public func renderToTexture() {
        
        /*
        *  Since 'render' applies this sprite's model matrix in transformation,
        *  I must supply a model matrix that completely inverts it.
        *  Scaling down instead of scaling up, translating in the
        *  opposite direction, etc.
        */
        var modelMatrix = SCMatrix4(scaleX: 1.0 / self.scaleX, scaleY: 1.0 / self.scaleY, scaleZ: 1.0)
        modelMatrix = modelMatrix.rotate2D(-self.rotation)
        modelMatrix = modelMatrix.translateByX(self.contentSize.width * self.anchor.x - self.position.x, byY: self.contentSize.height * self.anchor.y - self.position.y, byZ: 0.0)
        
        self.framebufferStack?.pushGLSFramebuffer(self.buffer)
        self.buffer.bindClearColor()
        
        
        self.render(modelMatrix)
        
        self.framebufferStack?.popFramebuffer()
    }//render to texture
    
    deinit {
        glDeleteBuffers(1, &self.vertexBuffer)
        self.vertexBuffer = 0
    }
}
