//
//  RecursiveRenderer.swift
//  Batcher
//
//  Created by Cooper Knaak on 7/7/15.
//  Copyright (c) 2015 Cooper Knaak. All rights reserved.
//

import Foundation
import GLKit

public class RecursiveRenderer: NSObject {
   
    // MARK: - Types
    
    public class RecursiveProgram: GLProgramDictionary {
        
        private(set) var indexBuffer:GLuint = 0
        /*
        let u_Projection:GLint
        let u_ModelMatrix:GLint
        let u_TintColor:GLint
        let u_TintIntensity:GLint
        let u_ShadeColor:GLint
        let u_Alpha:GLint
        
        let u_TextureInfo:GLint
        
        let a_Position:GLint
        let a_Texture:GLint
        let a_Index:GLint
        */
        public init() {
            
            let program = ShaderHelper.programForString("Universal2 D Shader")
            
            if program == nil {
                print("Error: Universal 2D Shader does not exist!")
            }
            
            glGenBuffers(1, &self.indexBuffer)
            glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), self.indexBuffer)
            
            super.init(program: program!, locations: [
                "u_Projection",
                "u_ModelMatrix",
                "u_TintColor",
                "u_TintIntensity",
                "u_ShadeColor",
                "u_Alpha",
                "u_TextureInfo",
                "a_Position",
                "a_Texture",
                "a_Index"
                ])
            
            glUseProgram(program!)
        }
        
        deinit {
            glDeleteBuffers(1, &self.indexBuffer)
            self.indexBuffer = 0
        }
        
    }
    
    // MARK: - Properties
    
    public let program = RecursiveProgram()

    public var projection = SCMatrix4() {
        didSet {
            if !self.shouldBindProjection {
                glUseProgram(self.program.program)
                glUniformMatrix4fv(self.program["u_Projection"], 1, 0, self.projection.values)
            }
        }
    }
    public var shouldBindProgram       = false
    public var shouldBindProjection    = false
    public var clearColor = SCVector4(x: 0.0, y: 0.0, z: 0.0, w: 0.0)
    
    public /*private*/ var references:[GLSNodeReference]   = []
    private var emitters:[GLSEmitterReference]  = []
    private var modelMatrices:SCMatrix4Array    = SCMatrix4Array(matrices: [])
    private var tintColors:SCVector3Array       = SCVector3Array()
    private var tintIntensities:SCVector3Array  = SCVector3Array()
    private var shadeColors:SCVector3Array      = SCVector3Array()
    private var alphas:[GLfloat]                = []
    private var vertices:[UVertex]              = []
    
//    private var backgroundModelMatrices         = SCMatrix4Array(matrices: [])
    
    private var indices:[GLushort]              = []
    public let backgroundQueue = dispatch_queue_create("RecursiveRenderer Queue", DISPATCH_QUEUE_SERIAL)
    public let operationQueue = NSOperationQueue()
    public let updateOperationQueue = NSOperationQueue()
    private var operations:[NSOperation] = []

    private var backgroundReferences:[GLSNodeReference]   = []
    private var backgroundEmitters:[GLSEmitterReference]  = []
    private var backgroundModelMatrices:SCMatrix4Array    = SCMatrix4Array(matrices: [])
    private var backgroundTintColors:SCVector3Array       = SCVector3Array()
    private var backgroundTintIntensities:SCVector3Array  = SCVector3Array()
    private var backgroundShadeColors:SCVector3Array      = SCVector3Array()
    private var backgroundAlphas:[GLfloat]                = []
    private var backgroundVertices:[UVertex]              = []

    ///Gets number of _ to bind, be it 4x4 matrices, 3-component vectors, or floating point arrays.
    private var count:GLsizei { return GLsizei(self.alphas.count) }
    
    private var firstTime = true
    private var currentTexture:GLuint = 0
    private var universalRenderIndex = 0
    
    // MARK: - Setup
    
    public override init() {
        
        self.operationQueue.underlyingQueue = self.backgroundQueue
        self.operationQueue.maxConcurrentOperationCount = 1
        self.updateOperationQueue.maxConcurrentOperationCount = 1
        
        super.init()
    }
    
    // MARK: - Logic
    
    public func insertNode(node:GLSNode, atIndex:Int) {
        
        let index = max(min(self.references.count, atIndex), 0)
    
        let startIndex:Int
        if self.references.count >= index && self.references.count > 0 && index > 0 {
            startIndex = self.references[index - 1].endIndex
        } else {
            startIndex = 0
        }
        
        let reference = GLSNodeReference(node: node, index: index, startIndex: startIndex, vertexCount: node.vertices.count)
        self.modelMatrices.insertMatrix(node.recursiveModelMatrix(), atIndex: index)
        self.tintColors.insertVector(node.tintColor, atIndex: index)
        self.tintIntensities.insertVector(node.tintIntensity, atIndex: index)
        self.shadeColors.insertVector(node.shadeColor, atIndex: index)
        self.alphas.insert(GLfloat(node.alpha), atIndex: index)
//        self.vertices.replaceRange(reference.startIndex..<reference.endIndex, with: node.vertices)
        self.references.insert(reference, atIndex: index)
        
        for iii in 0..<node.vertices.count {
            self.vertices.insert(node.vertices[iii], atIndex: reference.startIndex + iii)
        }
        
        self.setIndicesStartingAt(index)
        
        if let emitter = node as? GLSParticleEmitter {
            let eRef = GLSEmitterReference(emitter: emitter, startIndex: 0)
            self.emitters.append(eRef)
        }
        
    }
    
    public func setIndicesStartingAt(index:Int) {
        
        if index > self.references.count {
            return
        }
        
        var startIndex = 0
        if self.references.count > 1 && index < self.references.count && index > 0 {
            startIndex = self.references[index - 1].endIndex
        }
        for iii in index..<self.references.count {
            
            self.references[iii].index = iii
            self.references[iii].startIndex = startIndex
            startIndex = self.references[iii].endIndex
            for jjj in self.references[iii].startIndex..<self.references[iii].endIndex {
                
                self.vertices[jjj].index = GLfloat(iii)
            }
        }
        
    }
    
    public func removeNodeAtIndex(index:Int) {
        
        if index < 0 || index >= self.references.count {
            return
        }
        
        if let emitter = self.references[index].node as? GLSParticleEmitter {
            self.emitters = self.emitters.filter() { $0.emitter !== emitter }
        }
        
        self.modelMatrices.removeMatrixAtIndex(index)
        self.tintColors.removeVectorAtIndex(index)
        self.tintIntensities.removeVectorAtIndex(index)
        self.shadeColors.removeVectorAtIndex(index)
        self.alphas.removeAtIndex(index)
        self.vertices.removeRange(self.references[index].startIndex..<self.references[index].endIndex)
        self.references.removeAtIndex(index)
        
        self.setIndicesStartingAt(index)
    }
    
    public func removeNodesInRange(range:Range<Int>) {
        
        if range.startIndex < 0 || range.endIndex > self.references.count {
            return
        }
        
        for iii in range {
            if self.references[iii].node is GLSParticleEmitter {
                self.emitters = self.emitters.filter() { $0.emitter != self.references[iii].node && $0.emitter != nil }
            }
        }
        
        self.modelMatrices.removeMatricesInRange(range)
        self.tintColors.removeVectorsInRange(range)
        self.tintIntensities.removeVectorsInRange(range)
        self.shadeColors.removeVectorsInRange(range)
        self.alphas.removeRange(range)
        
        let startIndex  = self.references[range.startIndex].startIndex
        let endIndex    = self.references[range.endIndex - 1].endIndex
        self.vertices.removeRange(startIndex..<endIndex)
        
        self.references.removeRange(range)
        
        self.setIndicesStartingAt(range.startIndex)
    }
    
    var times = 0
    public func update() {
        
        for op in self.operations {
            if let name = op.name where name == "Update" {
                return
            }
        }
        
        self.operations = self.operations.filter() { !$0.finished }
        
        let operation = NSBlockOperation() { /*[unowned self] in*/
            self.backgroundModelMatrices.values = self.modelMatrices.values
            var backgroundVertices = self.vertices
            
            for (iii, ref) in self.references.enumerate() {
            
                if let node = ref.node {
                    if node.modelMatrixIsDirty {
                        let rm = node.recursiveModelMatrix()
//                        self.backgroundModelMatrices.changeMatrix(rm, atIndex: iii)
                        self.backgroundModelMatrices.changeMatrix_Fast2D(rm, atIndex: iii)
                        node.modelMatrixIsDirty = false
                    }
                    
                    if node.tintColorIsDirty {
                        self.tintColors[iii] = node.tintColor
                        node.tintColorIsDirty = false
                    }
                    
                    if node.tintIntensityIsDirty {
                        self.tintIntensities[iii] = node.tintIntensity
                        node.tintIntensityIsDirty = false
                    }
                    
                    if node.shadeColorIsDirty {
                        self.shadeColors[iii] = node.shadeColor
                        node.shadeColorIsDirty = false
                    }
                    
                    if node.alphaIsDirty {
                        self.alphas[iii] = GLfloat(node.alpha)
                        node.alphaIsDirty = false
                    }
                    
                    if node.verticesAreDirty {
                        backgroundVertices.replaceRange(ref.vertexRange, with: node.vertices)
                        for jjj in ref.vertexRange {
                            backgroundVertices[jjj].index = GLfloat(iii)
                        }
//                        self.vertices.replaceRange(ref.vertexRange, with: node.vertices)
                        node.verticesAreDirty = false
                    }
                }
                
            }
            
            self.modelMatrices.values = self.backgroundModelMatrices.values
            self.vertices = backgroundVertices
        }
        operation.name = "Update"
        
        for op in self.operations {
            operation.addDependency(op)
        }
        
//        self.updateOperationQueue.addOperation(operation)
//        self.operations.append(operation)
        self.addOperation(operation)
    }
    
    // MARK: - Operations
    
    public func addOperation(operation:NSOperation) {
        /*
        for op in self.operations {
//            operation.addDependency(op)
        }
        */
        self.operationQueue.addOperation(operation)
//        self.operations.append(operation)
    }
    
    public func addBlockOperation(block:() -> Void) {
        self.addOperation(NSBlockOperation(block: block))
    }
    
    public func addBlockOperation(title: String, block: () -> Void) {
        let operation = NSBlockOperation(block: block)
        operation.name = title
        self.addOperation(operation)
    }
    
    // MARK: - Rendering
    
    public func render() {
//        var backgroundVertices = self.vertices
//        let rCount = self.references.count
        
        self.backgroundReferences       = self.references
        self.backgroundEmitters         = self.emitters
//        self.backgroundModelMatrices    = self.modelMatrices
        self.backgroundTintColors       = self.tintColors
        self.backgroundTintIntensities  = self.tintIntensities
        self.backgroundShadeColors      = self.shadeColors
        self.backgroundAlphas           = self.alphas
        self.backgroundVertices         = self.vertices
        
        self.renderEmitters()
        
        if self.shouldBindProgram {
            glUseProgram(self.program.program)
            glBlendFunc(GLenum(GL_SRC_ALPHA), GLenum(GL_ONE_MINUS_SRC_ALPHA))
            
            glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), self.program.indexBuffer)
        }
        if self.shouldBindProjection {
            glUniformMatrix4fv(self.program["u_Projection"], 1, 0, self.projection.values)
        }
        
        self.clearColor.bindGLClearColor()
        
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), self.program.vertexBuffer)
        glBufferData(GLenum(GL_ARRAY_BUFFER), sizeof(UVertex) * self.backgroundVertices.count, self.backgroundVertices, GLenum(GL_STATIC_DRAW))
        
        glUniform1i(self.program["u_TextureInfo"], 0)
        
        glUniformMatrix4fv(self.program["u_ModelMatrix"], self.count, 0, self.modelMatrices.values)
        glUniform3fv(self.program["u_TintColor"], self.count, self.backgroundTintColors.values)
        glUniform3fv(self.program["u_TintIntensity"], self.count, self.backgroundTintIntensities.values)
        glUniform3fv(self.program["u_ShadeColor"], self.count, self.backgroundShadeColors.values)
        glUniform1fv(self.program["u_Alpha"], self.count, self.backgroundAlphas)
        /*
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), self.program.vertexBuffer)
        glBufferData(GLenum(GL_ARRAY_BUFFER), sizeof(UVertex) * self.vertices.count, self.vertices, GLenum(GL_STATIC_DRAW))
        
        glUniform1i(self.program["u_TextureInfo"], 0)
        
        glUniformMatrix4fv(self.program["u_ModelMatrix"], self.count, 0, self.modelMatrices.values)
        glUniform3fv(self.program["u_TintColor"], self.count, self.tintColors.values)
        glUniform3fv(self.program["u_TintIntensity"], self.count, self.tintIntensities.values)
        glUniform3fv(self.program["u_ShadeColor"], self.count, self.shadeColors.values)
        glUniform1fv(self.program["u_Alpha"], self.count, self.alphas)
        */

        self.program.enableAttributes()
        self.program.bridgeAttributesWithSizes([2, 2, 1], stride: sizeof(UVertex))
        
        self.resetArrays()
        
        self.indices = []
        var firstTime = true
//        for ref in self.references {
        for ref in self.backgroundReferences {
            
            if !(firstTime || ref.textureName == self.currentTexture || ref.vertexCount == 0 || ref.hidden) {
                self.renderCurrent()
                self.currentTexture = ref.textureName
                self.indices = []
            }
            
            if !ref.hidden {
                for iii in ref.startIndex..<ref.endIndex {
                    self.indices.append(GLushort(iii))
                }
                
            }
            
            if firstTime {
                self.currentTexture = ref.textureName
                firstTime = false
            }
            
        }
        
        self.renderCurrent()
        self.program.disableAttributes()
    }//render node
    
    private func resetArrays() {
        /*
        self.modelMatrices      = []
        self.tintColors         = []
        self.tintIntensities    = []
        self.shadeColors        = []
        self.alphas             = []
        self.vertices           = []
        */
        self.universalRenderIndex = 0
    }
    
    private func addNode(node:GLSNode) {
//        self.modelMatrices += [1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1]
        /*
        self.modelMatrices      += node.recursiveModelMatrix().values
        self.tintColors         += node.tintColor.getGLComponents()
        self.tintIntensities    += node.tintIntensity.getGLComponents()
        self.shadeColors        += node.shadeColor.getGLComponents()
        self.alphas.append(GLfloat(node.alpha))

        let i = self.universalRenderIndex
        */
        
        for iii in 0..<node.vertices.count {
            node.vertices[iii].index = GLfloat(node.universalRenderIndex)
        }
        self.vertices += node.vertices
        
        
        self.universalRenderIndex += 1
    }
    
    private func renderCurrent() {

        if self.indices.count <= 0 {
            return
        }
        
        glBufferData(GLenum(GL_ELEMENT_ARRAY_BUFFER), sizeof(GLushort) * self.indices.count, self.indices, GLenum(GL_STATIC_DRAW))
        
        glBindTexture(GLenum(GL_TEXTURE_2D), self.currentTexture)
        
        glDrawElements(TexturedQuad.drawingMode, GLsizei(self.indices.count), GLenum(GL_UNSIGNED_SHORT), nil)
        
        /*
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), self.program.vertexBuffer)
        glBufferData(GLenum(GL_ARRAY_BUFFER), sizeof(UVertex) * self.vertices.count, self.vertices, GLenum(GL_STATIC_DRAW))
        
        glBindTexture(GLenum(GL_TEXTURE_2D), self.currentTexture?.name ?? 0)
        glUniform1i(self.program["u_TextureInfo"], 0)
        
        glUniformMatrix4fv(self.program["u_ModelMatrix"], self.count, 0, self.modelMatrices)
        glUniform3fv(self.program["u_TintColor"], self.count, self.tintColors)
        glUniform3fv(self.program["u_TintIntensity"], self.count, self.tintIntensities)
        glUniform3fv(self.program["u_ShadeColor"], self.count, self.shadeColors)
        glUniform1fv(self.program["u_Alpha"], self.count, self.alphas)
        
        self.program.enableAttributes()
        self.program.bridgeAttributesWithSizes([2, 2, 1], stride: sizeof(UVertex))
        
        glDrawArrays(TexturedQuad.drawingMode, 0, GLsizei(self.vertices.count))
        
        self.program.disableAttributes()
        */
    }
    
    public func insertedNode(node:GLSNode) {
        self.setArraysForNode(node, atIndex: node.universalRenderIndex)
    }
    
    public func setArraysForNode(node:GLSNode, atIndex index:Int) {
        self.modelMatrices.changeMatrix(node.recursiveModelMatrix(), atIndex: index)
        self.tintColors.changeVector(node.tintColor, atIndex: index)
        self.tintIntensities.changeVector(node.tintIntensity, atIndex: index)
        self.shadeColors.changeVector(node.shadeColor, atIndex: index)
        self.alphas[index] = GLfloat(node.alpha)
    }
    
    public func indexOfNode(node:GLSNode) -> Int {
        
        var index = 0
//        var superNode = node.superNode
        while let sNode = node.superNode {
            for child in sNode.children {
                index += 1
                if child === node {
                    break
                }
            }
//            superNode = sNode.superNode
        }
        
        return index
    }
    
    
    public func renderEmitters() {
        glBlendColor(0, 0, 0, 1.0);
        glBlendFunc(GLenum(GL_SRC_ALPHA), GLenum(GL_CONSTANT_ALPHA));
        
        for eRef in self.emitters {
            if let emitter = eRef.emitter where emitter.particles.count > 0 {
                emitter.renderToTexture()
            }
        }
    }
    
}
