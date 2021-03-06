//
//  GLSFramebufferStack.swift
//  Fields and Forces
//
//  Created by Cooper Knaak on 1/9/15.
//  Copyright (c) 2015 Cooper Knaak. All rights reserved.
//

import GLKit

public class GLSFramebufferStack: NSObject {
   
    private let initialBuffer:NSOpenGLView?
    private var buffers:[GLuint] = []
    private var renderBuffers:[GLuint] = []
    public let internalContext:NSOpenGLContext?
    
    public init(initialBuffer:NSOpenGLView?) {
        
        self.initialBuffer = initialBuffer
        /*if let pixelFormat = self.initialBuffer?.pixelFormat {
            self.internalContext = NSOpenGLContext(format: pixelFormat, shareContext: self.initialBuffer?.openGLContext)
        } else {
            self.internalContext = nil
        }*/
        self.internalContext = GLSFrameBuffer.globalContext
        super.init()
    }//initialize
    
    
    public func pushFramebuffer(buffer:GLuint) -> Bool {
        
        glBindFramebuffer(GLenum(GL_FRAMEBUFFER), buffer)
        self.buffers.append(buffer)
        
        return true
    }//push a framebuffer
    
    public func pushGLSFramebuffer(buffer:GLSFrameBuffer) -> Bool {
        self.internalContext?.makeCurrentContext()
        /*if let buffer = self.initialBuffer {
            glViewport(0, 0, GLsizei(buffer.frame.width), GLsizei(buffer.frame.height))
        }*/
        
        glBindFramebuffer(GLenum(GL_FRAMEBUFFER), buffer.framebuffer)
        glBindRenderbuffer(GLenum(GL_RENDERBUFFER), buffer.renderBuffer)
        
        self.buffers.append(buffer.framebuffer)
        self.renderBuffers.append(buffer.renderBuffer)
        
        return true
    }//push a framebuffer
    
    public func popFramebuffer() -> Bool {
        
        if (self.buffers.count <= 0) {
            return false
        }//can't pop initial framebuffer
        
        //renderBuffers is guarunteed to be the same length as buffers.
        self.buffers.removeLast()
        self.renderBuffers.removeLast()
        
        if let topBuffer = self.buffers.last, renderBuffer = self.renderBuffers.last {
            glBindFramebuffer(GLenum(topBuffer), topBuffer)
            glBindRenderbuffer(GLenum(GL_RENDERBUFFER), renderBuffer)
        } else {
            glFlush()
            self.initialBuffer?.openGLContext?.makeCurrentContext()
        }
        
        return true
    }//pop the top framebuffer
    
}
