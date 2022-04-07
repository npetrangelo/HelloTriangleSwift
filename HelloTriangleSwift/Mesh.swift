//
//  Mesh.swift
//  HelloTriangleSwift
//
//  Created by qe on 4/5/22.
//

import Foundation
import Metal
import MetalKit

class Mesh : NSObject {
    let vertices: [VertexIn]
    let triangles: [[Int]]
    
    init?(vertices: [VertexIn], triangles: [[Int]]) {
        self.vertices = vertices
        self.triangles = triangles
    }
    
    class func initCube() -> Mesh {
        let vertices: [VertexIn] = [
            VertexIn(pos: [0,0,0], color: [0,0,0,1]),
            VertexIn(pos: [0,0,1], color: [0,0,1,1]),
            VertexIn(pos: [0,1,0], color: [0,1,0,1]),
            VertexIn(pos: [0,1,1], color: [0,1,1,1]),
            VertexIn(pos: [1,0,0], color: [1,0,0,1]),
            VertexIn(pos: [1,0,1], color: [1,0,1,1]),
            VertexIn(pos: [1,1,0], color: [1,1,0,1]),
            VertexIn(pos: [1,1,1], color: [1,1,1,1])
        ]
        
        let triangles: [[Int]] = [
            [0,1,2], [1,3,2], // Front
            [4,6,5], [5,6,7], // Back
            [2,3,7], [2,7,6], // Top
            [0,4,5], [0,5,1], // Bottom
            [0,2,6], [0,6,4], // Left
            [1,5,7], [1,7,3]  // Right
        ]
        
        return Mesh.init(vertices: vertices, triangles: triangles)!
    }
    
    func makeBuffer(device: MTLDevice) -> MTLBuffer {
        var bytes: [VertexIn] = []
        for triangle in triangles {
            bytes.append(contentsOf: [vertices[triangle[0]], vertices[triangle[1]], vertices[triangle[2]]])
        }
        return device.makeBuffer(bytes: bytes, length: 3 * triangles.count * MemoryLayout<VertexIn>.stride, options: [])!
    }
    
    /**
     * Add a command to the command buffer to draw the mesh
     */
    func draw(commandBuffer: MTLCommandBuffer, renderPassDescriptor: MTLRenderPassDescriptor, pipelineState: MTLRenderPipelineState) {
        guard let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else { return }
        encoder.setRenderPipelineState(pipelineState)
        encoder.setVertexBuffer(makeBuffer(device: commandBuffer.device), offset: 0, index: 0)
//        encoder.setVertexBuffer(sceneBuffer, offset: 0, index: 1)
        encoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3)
        encoder.endEncoding()
    }
}
