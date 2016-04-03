//
//  GLSFrameBuffer.swift
//  Fields and Forces
//
//  Created by Cooper Knaak on 1/9/15.
//  Copyright (c) 2015 Cooper Knaak. All rights reserved.
//

import Foundation
import GLKit
import QuartzCore
import OpenGL

public class GLSFrameBuffer: GLSNode {
    
    private var framebufferName:GLuint = 0
    public var framebuffer:GLuint { return self.framebufferName }
    private var internalTextureName:GLuint = 0
    public var textureName:GLuint { return self.internalTextureName }
    private(set) public var renderBuffer:GLuint = 0
    
    public let internalSize:NSSize
    public let internalScale:CGFloat
    public let size:NSSize
    
    public var clearColor = SCVector4()
    
    public let ccTexture:CCTexture
    public let sprite:GLSSprite
    /**
    If true, then framebuffer renders normally.
    If false, then you are responsible for rendering.
    The 'sprite' property is provided for you.
    */
    public var renderAutomatically = true
    /**
    If *true*, then framebuffer renders children to self in render method.
    If *false*, then contents of framebuffer do not change automatically.
    */
    public var renderChildren = true
    
    /**
    Texture Parameters must be *GL_LINEAR* and *GL_CLAMP_TO_EDGE*
    for non-power of 2 sizes to work
    */
    public convenience init(size:NSSize) {
        self.init(size: size, scale: GLSFrameBuffer.getRetinaScale())
    }//initialize
    
    ///Initializes a GLSFrameBuffer with a given size and retina scale.
    public init(size:NSSize, scale:CGFloat) {
        self.size = size
        self.internalScale = scale
        self.internalSize = self.size * self.internalScale
        
        glGenFramebuffers(1, &self.framebufferName)
        glBindFramebuffer(GLenum(GL_FRAMEBUFFER), self.framebufferName)
        
        glGenTextures(1, &self.internalTextureName)
        
        let enumTex = GLenum(GL_TEXTURE_2D)
        glBindTexture(enumTex, self.internalTextureName)
        glTexParameteri(enumTex, GLenum(GL_TEXTURE_MAG_FILTER), GL_LINEAR)
        glTexParameteri(enumTex, GLenum(GL_TEXTURE_MIN_FILTER), GL_LINEAR)
        glTexParameteri(enumTex, GLenum(GL_TEXTURE_WRAP_S), GL_CLAMP_TO_EDGE)
        glTexParameteri(enumTex, GLenum(GL_TEXTURE_WRAP_T), GL_CLAMP_TO_EDGE)
        
        let width = GLsizei(self.internalSize.width)
        let height = GLsizei(self.internalSize.height)
        glTexImage2D(enumTex, 0, GLint(GL_RGBA), width, height, 0, GLenum(GL_RGBA), GLenum(GL_UNSIGNED_BYTE), nil)
        glFramebufferTexture2D(GLenum(GL_FRAMEBUFFER), GLenum(GL_COLOR_ATTACHMENT0), enumTex, self.internalTextureName, 0)
        
        glGenRenderbuffers(1, &self.renderBuffer)
        glBindRenderbuffer(GLenum(GL_RENDERBUFFER), self.renderBuffer)
        glRenderbufferStorage(GLenum(GL_RENDERBUFFER), GLenum(GL_RGBA8), width, height)
        glFramebufferRenderbuffer(GLenum(GL_FRAMEBUFFER), GLenum(GL_COLOR_ATTACHMENT1), GLenum(GL_RENDERBUFFER), self.renderBuffer)
        let status = glCheckFramebufferStatus(GLenum(GL_FRAMEBUFFER))
        if (status != GLenum(GL_FRAMEBUFFER_COMPLETE)) {
            print("Framebuffer binding failed.")
            
            let statusAsHex = NSString(format: "%x", status)
            let errorAsHex  = NSString(format: "%x", glGetError())
            print("Status:\(statusAsHex) Error code:\(errorAsHex)")
            print("Size:\(self.size) Internal:\(self.internalSize)")
            print("Width:\(width) Height:\(height)")
        }
        
        let ccSize = self.size * self.internalScale / self.internalSize
        self.ccTexture = CCTexture(name: self.internalTextureName, frame: NSRect(x: 0.0, y: 0.0, width: ccSize.width, height: ccSize.height))
        self.sprite = GLSSprite(position: NSPoint.zero, size: self.size, texture: self.ccTexture)
 
        super.init(position:NSPoint.zero, size: self.size)
        
        self.vertices = self.sprite.vertices
        self.texture = self.ccTexture
    }
    
    override public func render(model: SCMatrix4) {
        
        let childModel = self.modelMatrix() * model
        
        if self.renderChildren {
            self.framebufferStack?.pushGLSFramebuffer(self)
            
            self.bindClearColor()
            //        super.render(SCMatrix4())
            let identityMatrix = SCMatrix4()
            for cur in self.children {
                cur.render(identityMatrix)
            }
            
            self.framebufferStack?.popFramebuffer()
        }
        //If 'renderAutomatically' is false, then framebuffer
        //does not handle rendering to screen, but it does
        //handle rendering to framebuffer
        if (!self.renderAutomatically) {
            return
        }
        
        //Make sure sprite's values are equal to framebuffer's values
        self.sprite.position = self.contentSize.center
        self.sprite.anchor = self.anchor
        self.sprite.alpha = self.alpha
        self.sprite.scaleX = self.scaleX
        self.sprite.scaleY = self.scaleY
        self.sprite.rotation = self.rotation
        self.sprite.projection = self.projection
        self.sprite.render(childModel)
    }//render
    
    public func bindClearColor() {
        
        glClearColor(GLfloat(self.clearColor.r), GLfloat(self.clearColor.g), GLfloat(self.clearColor.b), GLfloat(self.clearColor.a))
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
        
    }//bind clear color
    
    
    public func getImage() -> NSImage {
        
        glBindFramebuffer(GLenum(GL_FRAMEBUFFER), self.framebufferName)
        glBindRenderbuffer(GLenum(GL_RENDERBUFFER), self.renderBuffer)
        glReadBuffer(GLenum(GL_COLOR_ATTACHMENT0))
        
        let width = Int(ceil(self.internalSize.width))
        let height = Int(ceil(self.internalSize.height))
        
        let dataLength = width * height * 4
        
        var buffer:[GLubyte] = Array<GLubyte>(count: dataLength, repeatedValue: 255)
        
        while (glGetError() != GLenum(GL_NO_ERROR)) {
            
        }
        
        glReadPixels(0, 0, GLsizei(width), GLsizei(height), GLenum(GL_RGBA), GLenum(GL_UNSIGNED_BYTE), &buffer)
        let dProvider = CGDataProviderCreateWithData(nil, buffer, Int(dataLength), nil)
        let bitsPerComponent = 8
        let bitsPerPixel = bitsPerComponent * 4
        let bytesPerRow = width * 4
        let cSpace = CGColorSpaceCreateDeviceRGB()
        let bInfo = CGBitmapInfo(rawValue: CGBitmapInfo.ByteOrder32Big.rawValue | CGImageAlphaInfo.PremultipliedLast.rawValue)
        let rIntent = CGColorRenderingIntent.RenderingIntentDefault
        
        let cgIm = CGImageCreate(width, height, bitsPerComponent, bitsPerPixel, bytesPerRow, cSpace, bInfo, dProvider, nil, false, rIntent)
        
        let context = CGBitmapContextCreate(nil, width, height, bitsPerComponent, bytesPerRow, cSpace, bInfo.rawValue)
        CGContextSaveGState(context)
        
        CGContextSetBlendMode(context, CGBlendMode.Copy)
        CGContextDrawImage(context, CGRect(width: CGFloat(width), height: CGFloat(height), centered: false), cgIm)
        
        let cgIm2 = CGBitmapContextCreateImage(context)
        CGContextRestoreGState(context)
        let im = NSImage(CGImage: cgIm2!, size: self.contentSize)
        return im
        
        let bitmapIm = NSBitmapImageRep(CGImage: cgIm2!)
        
    }//get framebuffer as image

    
    override public func clone() -> GLSFrameBuffer {
        
        let copiedBuffer = GLSFrameBuffer(size: self.size)
        
        copiedBuffer.copyFromFrameBuffer(self)
        
        return copiedBuffer
        
    }//clone
    
    public func copyFromFrameBuffer(buffer:GLSFrameBuffer) {
        
        self.copyFromNode(buffer)
        
        self.clearColor = buffer.clearColor
        
        self.sprite.copyFromSprite(buffer.sprite)
    }//copy from buffer
    
    deinit {
        glDeleteFramebuffers(1, &framebufferName)
        glDeleteTextures(1, &internalTextureName)
    }
    
    
    //Override Properties
    
    override public var position:NSPoint {
        didSet {
            self.sprite.position = self.position
        }
    }
    override public var rotation:CGFloat {
        didSet {
            self.sprite.rotation = self.rotation
        }
    }
    override public var scaleX:CGFloat {
        didSet {
            self.sprite.scaleX = self.scaleX
        }
    }
    override public var scaleY:CGFloat {
        didSet {
            self.sprite.scaleX = self.scaleY
        }
    }
    override public var alpha:CGFloat {
        didSet {
            self.sprite.alpha = self.alpha
        }
    }
    override public var anchor:NSPoint {
        didSet {
            self.sprite.anchor = self.anchor
        }
    }
    override public var tintColor:SCVector3 {
        didSet {
            self.sprite.tintColor = self.tintColor
        }
    }
    override public var tintIntensity:SCVector3 {
        didSet {
            self.sprite.tintIntensity = self.tintIntensity
        }
    }
    override public var shadeColor:SCVector3 {
        didSet {
            self.sprite.shadeColor = self.shadeColor
        }
    }
}

//Convenience
public extension GLSFrameBuffer {
    /*
    public var shadeColor:SCVector3 {
    get { return self.sprite.shadeColor }
    set { self.sprite.shadeColor = newValue }
    }
    
    public var tintColor:SCVector3 {
    get { return self.sprite.tintColor }
    set { self.sprite.tintColor = newValue }
    }
    
    public var tintIntensity:SCVector3 {
    get { return self.sprite.tintIntensity }
    set { self.sprite.tintIntensity = newValue }
    }
    */
}//Access 'sprite's properties conveniently

//Getters / public class Functions
public extension GLSFrameBuffer {
    
    
    public class func isPowerOf2(value:Int) -> Bool {
        return (value & (value - 1)) == 0
    }
    
    public class func getValidPowerOf2(value:Int) -> Int {
        
        if (GLSFrameBuffer.isPowerOf2(value)) {
            return value
        }
        
        let bitCount = 8 * sizeof(Int)
        var bitShift = 0
        for iii in 1..<bitCount {
            if (value & (1 << iii) != 0) {
                bitShift = iii
            }
        }
        
        //Add 1 to bitShift because bitShift
        //finds highest bit, so you must
        //go one higher to get a higher
        //power of 2
        return 1 << (bitShift + 1)
    }
    
    public class func getValidSize(size:NSSize) -> NSSize {
        return size
        /*
         *  DEPRECATED
         *
         *  Framebuffers no longer need to be powers of 2.
         *
        var width = GLSFrameBuffer.getValidPowerOf2(Int(size.width))
        var height = GLSFrameBuffer.getValidPowerOf2(Int(size.height))
        
        return NSSize(width: width, height: height)
        */
    }//check if size is valid
    
    public class func getRetinaScale() -> CGFloat {
//        fatalError("Implement GLSFramebuffer.getRetinaScale()")
        return 1.0
    }//get retina scale
    
}