//
//  GLSRepeatedNoiseSprite.swift
//  OmniSwift
//
//  Created by Cooper Knaak on 7/23/15.
//  Copyright (c) 2015 Cooper Knaak. All rights reserved.
//

import Foundation
import GLKit

public class GLSRepeatedNoiseSprite: GLSSprite {
    
    // MARK: - Types
    
    public class RepeatedNoiseProgram {
        
        var program:GLuint { return self.attributeBridger.program }
        let attributeBridger:GLAttributeBridger
        
        let u_Projection:GLint
        let u_TextureInfo:GLint
        let u_NoiseTextureInfo:GLint
        let u_GradientInfo:GLint
        let u_PermutationInfo:GLint
        let u_Offset:GLint
        let u_NoiseDivisor:GLint
        let u_Alpha:GLint
        let a_Position:GLint
        let a_Texture:GLint
        let a_NoiseTexture:GLint
        let a_ScaleZero:GLint
        
        init() {
            
            
            let program = ShaderHelper.programForString("Repeated Noise Shader")!
            
            while glGetError() != GLenum(GL_NO_ERROR) {
                
            }
            self.u_Projection       = glGetUniformLocation(program, "u_Projection")
            self.u_TextureInfo      = glGetUniformLocation(program, "u_TextureInfo")
            self.u_NoiseTextureInfo = glGetUniformLocation(program, "u_NoiseTextureInfo")
            self.u_GradientInfo     = glGetUniformLocation(program, "u_GradientInfo")
            self.u_PermutationInfo  = glGetUniformLocation(program, "u_PermutationInfo")
            self.u_Offset           = glGetUniformLocation(program, "u_Offset")
            self.u_NoiseDivisor     = glGetUniformLocation(program, "u_NoiseDivisor")
            self.u_Alpha            = glGetUniformLocation(program, "u_Alpha")
            self.a_Position     = glGetAttribLocation(program, "a_Position")
            self.a_Texture      = glGetAttribLocation(program, "a_Texture")
            self.a_NoiseTexture = glGetAttribLocation(program, "a_NoiseTexture")
            self.a_ScaleZero    = glGetAttribLocation(program, "a_ScaleZero")
            
            self.attributeBridger = GLAttributeBridger(program: program)
            
            let atts = [self.a_Position, self.a_Texture, self.a_NoiseTexture, self.a_ScaleZero]
            self.attributeBridger.addAttributes(atts)
        }//initialize
        
    }
    
    public struct RepeatedNoiseVertex {
        var position:(GLfloat, GLfloat) = (0.0, 0.0)
        var texture:(GLfloat, GLfloat)  = (0.0, 0.0)
        public var noiseTexture:(GLfloat, GLfloat, GLfloat) = (0.0, 0.0, 0.0)
        var scaleZero:(GLfloat, GLfloat) = (1.0, 1.0)
    }
    
    // MARK: - Properties
    
    public let noiseProgram = RepeatedNoiseProgram()
    
    ///Texture used to find, generate, and interpolate between noise values.
    public var noiseTexture:Noise3DTexture2D
    ///Gradient of colors that noise is mapped to.
    public var gradient:GLGradientTexture2D
    ///Texture multiplied into the final output color.
    public var shadeTexture:CCTexture? {
        didSet {
            self.noiseSizeChanged()
        }
    }
    
    public let quads = MultiTexturedQuad(vertex: RepeatedNoiseVertex(), quads: 4)
    public let buffer:GLSFrameBuffer
    
    ///Conceptually, the size of the noise. How much noise you can see.
    public var noiseSize:NSSize = NSSize(square: 1.0) {
        didSet {
            self.noiseSizeChanged()
            if self.shouldRedraw && !(noiseSize.width ~= oldValue.width || noiseSize.height ~= oldValue.height) {
                self.renderToTexture()
            }
        }
    }
    ///Accessor for *noiseSize.width*
    public var noiseWidth:CGFloat {
        get {
            return self.noiseSize.width
        }
        set {
            self.noiseSize.width = newValue
        }
    }
    ///Accessor for *noiseSize.height*
    public var noiseHeight:CGFloat {
        get {
            return self.noiseSize.height
        }
        set {
            self.noiseSize.height = newValue
        }
    }
    
    ///Offset of noise texture. Note that the texture is not redrawn when *offset* is changed.
    public var offset:SCVector3 = SCVector3() {
        didSet {
            if self.shouldRedraw && !(self.offset ~= oldValue) {
                self.renderToTexture()
            }
        }
    }
    ///Speed at with offset changes. Note that the texture is not redrawn when *offset* is changed.
    public var offsetVelocity = SCVector3()
    ///How much the noise is blended with the rest of the texture. 0.0 for no noise and 1.0 for full noise.
    public var noiseAlpha:CGFloat = 1.0
    
    /**
    What to divide the 3D Noise Value by.
    
    Since perlin noise actually returns values
    in the range [-0.7, 0.7] (according to http://paulbourke.net/texture_colour/perlin/ ),
    I don't get the full range of the gradient. Thus,
    by adding a divisor, I can scale the noise to
    the full range. Default value is 0.7, because
    that should cause noise to range from [-1.0, 1.0].
    */
    public var noiseDivisor:CGFloat = 0.7 {
        didSet {
            if self.noiseDivisor <= 0.0 {
                self.noiseDivisor = 1.0
            }
        }
    }
    
    ///Whether the sprite should render to its background buffer every time its offset changes.
    public var shouldRedraw = false
    
    // MARK: - Setup
    
    public init(size:NSSize, texture:CCTexture?, noise:Noise3DTexture2D, gradient:GLGradientTexture2D) {
        
        self.buffer         = GLSFrameBuffer(size: size)
        self.shadeTexture   = texture
        self.noiseTexture   = noise
        self.gradient       = gradient
        
//        var p:[GLint] = []
        /*for cur in self.noiseTexture.noise.permutations {
        p.append(GLint(cur))
        }*/
        /*let perms = self.noiseTexture.noise.permutations
        for iii in 0..<1028 {
        let cur = perms[iii % perms.count]
        p.append(GLint(cur))
        }
        self.permutations = p*/
        
        //        super.init(position: NSPoint.zero, size: size)
        super.init(position: size.center, size: size, texture: self.buffer.ccTexture)
        
//        let positionRect = NSRect(size: size)
//        let textureRect = NSRect(square: 1.0)
        /*
        for iii in 0..<TexturedQuad.verticesPerQuad {
        let point = TexturedQuad.pointForIndex(iii)
        self.quads[iii].position = (point * size).getGLTuple()
        
        let tex = point.getGLTuple()
        self.quads[iii].texture  = tex
        self.quads[iii].noiseTexture = (tex.0, tex.1, 0.0)
        }
        */
        self.quads.iterateWithHandler() { quad, index, vertex in
            let point = TexturedQuad.pointForIndex(index)
            vertex.position = (point * size).getGLTuple()
            
            let tex = point.getGLTuple()
            vertex.texture = tex
            vertex.noiseTexture = (tex.0, tex.1, 0.0)
            
            switch quad {
            case 0:
                vertex.scaleZero = (1.0, 0.0)
            case 1:
                vertex.scaleZero = (1.0, 1.0)
            case 2:
                vertex.scaleZero = (0.0, 0.0)
            case 3:
                vertex.scaleZero = (0.0, 1.0)
            default:
                break
            }
        }
        
        //        self.shadeTextureChanged()
    }
    
    // MARK: - Logic
    
    public override func update(dt: CGFloat) {
        super.update(dt)
        
        self.offset += self.offsetVelocity * dt
    }//update
    
    ///Render noise to background texture (*buffer*).
    public func renderToTexture() {
        self.framebufferStack?.pushGLSFramebuffer(self.buffer)
        
        glClearColor(0.0, 0.0, 0.0, 0.0)
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
        
        //        self.noiseVertices.vertices += self.rightQuads.vertices
        
        glUseProgram(self.noiseProgram.program)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), self.noiseProgram.attributeBridger.vertexBuffer)
        //        glBufferData(GLenum(GL_ARRAY_BUFFER), self.noiseVertices.size, self.noiseVertices.vertices, GLenum(GL_STATIC_DRAW))
        glBufferData(GLenum(GL_ARRAY_BUFFER), self.quads.size, self.quads.vertices, GLenum(GL_STATIC_DRAW))
        
        let proj = self.projection
        glUniformMatrix4fv(self.noiseProgram.u_Projection, 1, 0, proj.values)
        
        glUniform1i(self.noiseProgram.u_TextureInfo, 0)
        glActiveTexture(GLenum(GL_TEXTURE0))
        glBindTexture(GLenum(GL_TEXTURE_2D), self.shadeTexture?.name ?? 0)
        
        glUniform1i(self.noiseProgram.u_NoiseTextureInfo, 1)
        glActiveTexture(GLenum(GL_TEXTURE1))
        glBindTexture(GLenum(GL_TEXTURE_2D), self.noiseTexture.noiseTexture)
        
        glUniform1i(self.noiseProgram.u_GradientInfo, 2)
        glActiveTexture(GLenum(GL_TEXTURE2))
        glBindTexture(GLenum(GL_TEXTURE_2D), self.gradient.textureName)
        
        glUniform1i(self.noiseProgram.u_PermutationInfo, 3)
        glActiveTexture(GLenum(GL_TEXTURE3))
        glBindTexture(GLenum(GL_TEXTURE_2D), self.noiseTexture.permutationTexture)
        
        //        glUniform1iv(self.noiseProgram.u_Permutations, 256, self.permutations)
        self.bridgeUniform3f(self.noiseProgram.u_Offset, vector: self.offset)
        glUniform1f(self.noiseProgram.u_NoiseDivisor, GLfloat(self.noiseDivisor))
        glUniform1f(self.noiseProgram.u_Alpha, GLfloat(self.noiseAlpha))
        
        self.noiseProgram.attributeBridger.enableAttributes()
        self.noiseProgram.attributeBridger.bridgeAttributesWithSizes([2, 2, 3, 2], stride: self.quads.stride)
        
        //        glDrawArrays(TexturedQuad.drawingMode, 0, GLsizei(self.noiseVertices.count))
        glDrawArrays(TexturedQuad.drawingMode, 0, GLsizei(self.quads.count))
        
        self.noiseProgram.attributeBridger.disableAttributes()
        self.framebufferStack?.popFramebuffer()
        glActiveTexture(GLenum(GL_TEXTURE0))
    }
    
    public func noiseSizeChanged() {
        
        let noisePoint = self.noiseSize.getNSPoint()
        let percent = (noisePoint - 1.0) / noisePoint
        
        let noiseRect = NSRect(size: self.noiseSize)
        let positionRect = NSRect(size: self.contentSize)
        let textureRect = self.shadeTexture?.frame ?? NSRect(square: 1.0)
        
        let noiseRects      = noiseRect.divideAtPercent(percent)
        let positionRects   = positionRect.divideAtPercent(percent)
        let textureRects    = textureRect.divideAtPercent(percent)
        
//        let iter = TexturedQuad.verticesPerQuad
        for quad in 0..<self.quads.quadCount {
            self.quads.iterateQuad(quad, forRect: noiseRects[quad]) { point, vertex in
                vertex.noiseTexture = (GLfloat(point.x), GLfloat(point.y), 0.0)
                return
            }
            self.quads.iterateQuad(quad, forRect: textureRects[quad]) { point, vertex in
                vertex.texture = (GLfloat(point.x), GLfloat(point.y))
                return
            }
            self.quads.iterateQuad(quad, forRect: positionRects[quad]) { point, vertex in
                vertex.position = (GLfloat(point.x), GLfloat(point.y))
                return
            }
        }
        
    }//noise size changed
    
}
