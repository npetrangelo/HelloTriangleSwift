//
//  Triangle.swift
//  HelloTriangleSwift
//
//  Created by qe on 4/5/22.
//

import Foundation
import Metal
import MetalKit

class Triangle : NSObject {
    let vertices : [VertexIn]
    
    init?(vertices : [VertexIn]) {
        self.vertices = vertices
    }
    
    func makeBuffer(device : MTLDevice) -> MTLBuffer {
        return device.makeBuffer(bytes: vertices, length: 3 * MemoryLayout<VertexIn>.stride, options: [])!
    }
    
    func draw(encoder : MTLRenderCommandEncoder) {
        encoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3)
    }
}
