//
//  GLSNode+UniversalRendering.swift
//  Gravity
//
//  Created by Cooper Knaak on 2/19/15.
//  Copyright (c) 2015 Cooper Knaak. All rights reserved.
//

import GLKit

//Handles adding/removing nodes from the universal
//render tree. Just have these methods return immediately
//if you later decide not to let GLSNode handle this.
//Or just never set the superparent's 'universalRenderer' property
public extension GLSNode {
    
    // MARK: - RecursiveRenderer
    
    public func nodeAddedAsChild_Recursive(node:GLSNode) {
        
        if let rRend = self.recursiveRenderer {
            
            var index = self.universalRenderIndex + 1
            if self.children.count >= 2 {
                let childNode = self.children[self.children.count - 2]
                index = childNode.universalRenderIndex + 1
                childNode.iterateChildrenRecursively() {
                    index = $0.universalRenderIndex + 1
                }
            }
            
            node.recursiveRenderer = rRend
            node.universalRenderIndex = index
            rRend.insertNode(node, atIndex: index)
            node.iterateChildrenRecursively() { [unowned self] in
                index += 1
                $0.universalRenderIndex = index
                rRend.insertNode($0, atIndex: index)
                $0.recursiveRenderer = rRend
                $0.framebufferStack = self.framebufferStack
            }
        }
        
    }
    
    public func nodeRemovedFromParent_Recursive(node:GLSNode) {
        
        if let rRend = self.recursiveRenderer {
            
            node.removeFromUniversalRenderer = true
            node.recursiveRenderer = nil
            
            
            let totalCount = node.recursiveChildrenCount()
            rRend.removeNodesInRange(node.universalRenderIndex...(node.universalRenderIndex + totalCount))
            
            node.universalRenderIndex = -1
            node.iterateChildrenRecursively() { childNode in
                childNode.recursiveRenderer = nil
                childNode.universalRenderIndex = -1
            }

            /*
            rRend.removeNodeAtIndex(node.universalRenderIndex)
            node.universalRenderIndex = 0
            
            node.iterateChildrenRecursively() { childNode in
                rRend.removeNodeAtIndex(childNode.universalRenderIndex)
                childNode.recursiveRenderer = nil
                childNode.universalRenderIndex = 0
            }
            */
        }
        
    }
    
}//Universal Rendering
