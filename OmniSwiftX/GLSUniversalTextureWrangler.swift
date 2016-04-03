//
//  GLSUniversalTextureWrangler.swift
//  Batcher
//
//  Created by Cooper Knaak on 4/3/15.
//  Copyright (c) 2015 Cooper Knaak. All rights reserved.
//

import GLKit

public class GLSUniversalTextureWrangler: NSObject {

    public class TextureGroup: CustomStringConvertible {
        
        let texture:GLuint
        let startIndex:GLsizei
        let vertexCount:GLsizei
        
        public init(texture:GLuint, start:Int, count:Int) {
            
            self.texture = texture
            self.startIndex = GLsizei(start)
            self.vertexCount = GLsizei(count)
            
        }//initialize
        
        public convenience init(reference:GLSNodeReference) {
            self.init(texture: reference.textureName, start: reference.startIndex, count: reference.vertexCount)
        }
        
        
        func render() {
            
            glBindTexture(GLenum(GL_TEXTURE_2D), self.texture)
            glDrawArrays(TexturedQuad.drawingMode, self.startIndex, self.vertexCount)
            
        }//render
        
        
        public var description:String {
            return "TG[\(self.startIndex), +\(self.vertexCount))-\(self.texture)"
        }
        
    }//texture group
    
    public class func getTextures(references:[GLSNodeReference]) -> [TextureGroup] {
        
        var groups:[TextureGroup] = []
        
        var currentTex:GLuint = 0
        var firstReference = true
        
        var currentStart = 0
        var currentCount = 0
        
        for cur in references {
            
            if (firstReference) {
                currentStart = cur.startIndex
                currentCount = cur.vertexCount
                if (cur.vertexCount > 0) {
                    firstReference = false
                    currentTex = cur.textureName
                }
                continue
            }
            
            if (cur.textureName == currentTex || cur.vertexCount <= 0) {
                
                currentCount += cur.vertexCount
                
            } else {
                
                let tGroup = TextureGroup(texture: currentTex, start: currentStart, count: currentCount)
                groups.append(tGroup)
                
                currentStart = cur.startIndex
                currentCount = cur.vertexCount
                
                currentTex = cur.textureName
            }
            
        }
        
        //Need to add one last group
        //that never finished
        if (currentCount > 0) {
            let tGroup = TextureGroup(texture: currentTex, start: currentStart, count: currentCount)
            groups.append(tGroup)
        }
        
        return groups
    }//get textures
    
}
