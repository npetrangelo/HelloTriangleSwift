//
//  Renderer.swift
//  HelloTriangleSwift
//
//  Created by qe on 3/30/22.
//

import Foundation
import Metal
import MetalKit
import ModelIO
import simd

class Renderer : NSObject, MTKViewDelegate {
    let device: MTLDevice
    let commandQueue: MTLCommandQueue
    let pipelineState: MTLRenderPipelineState
    var vertices : [VertexIn]
    var vertexBuffer: MTLBuffer
    var cube: MDLMesh
    var sceneBuffer: MTLBuffer
    var t : Float
    
    // This is the initializer for the Renderer class.
    // We will need access to the mtkView later, so we add it as a parameter here.
    init?(mtkView: MTKView) {
        device = mtkView.device!
        commandQueue = device.makeCommandQueue()!
        
        // This is how Metal knows the vertex format to enable [[stage_in]]
        let vertexDescriptor = MTLVertexDescriptor()
        
        // Position
        vertexDescriptor.attributes[0].format = .float3
        vertexDescriptor.attributes[0].bufferIndex = 0
        vertexDescriptor.attributes[0].offset = 0
        
        // Color
        vertexDescriptor.attributes[1].format = .float4
        vertexDescriptor.attributes[1].bufferIndex = 0
        vertexDescriptor.attributes[1].offset = MemoryLayout<SIMD3<Float>>.size
        
        vertexDescriptor.layouts[0].stride = MemoryLayout<VertexIn>.stride
        
        // Create the Render Pipeline
        do {
            pipelineState = try Renderer.buildRenderPipelineWith(device: device, metalKitView: mtkView, vertexDescriptor: vertexDescriptor)
        } catch {
            print("Unable to compile render pipeline state: \(error)")
            return nil
        }
        
        t = 0
        
        vertices = [
            VertexIn(pos: [-1,  1, 0], color: [1,1,0,0]),
            VertexIn(pos: [-1, -1, 0], color: [1,0,0,1]),
            VertexIn(pos: [ 0,  1, 0], color: [0,1,0,1]),
            VertexIn(pos: [ 1, -1, 0], color: [0,0,1,1]),
            VertexIn(pos: [ 1,  1, 0], color: [0,1,1,0])
        ]
        
        cube = MDLMesh.newBox(withDimensions: [1,1,1], segments: [1,1,1], geometryType: .quads, inwardNormals: false, allocator: MTKMeshBufferAllocator(device: device))
                
        // And copy it to a Metal buffer...
        vertexBuffer = device.makeBuffer(bytes: vertices, length: vertices.count * MemoryLayout<VertexIn>.stride, options: [])!
        
        let boundingBox = simd_float2x3(columns: (simd_float3(1,0,0), simd_float3(0,1,0)))
        
        let scene = Scene(modelTransform: matrix_identity_float4x4, modelViewProjectionTransform: matrix_identity_float4x4, modelViewTransform: matrix_identity_float4x4, normalTransform: matrix_identity_float4x4, boundingBox: boundingBox)
        
        sceneBuffer = device.makeBuffer(bytes: [scene], length: MemoryLayout<Scene>.stride, options: [])!
    }
    
    // mtkView will automatically call this function
    // whenever it wants new content to be rendered.
    func draw(in view: MTKView) {
        t += 0.05
        vertices[1].color[0] = cos(t)*cos(t)
        vertices[2].color[1] = cos(t-Float.pi/3)*cos(t-Float.pi/3)
        vertices[3].color[2] = cos(t-2*Float.pi/3)*cos(t-2*Float.pi/3)
        vertexBuffer = device.makeBuffer(bytes: vertices, length: vertices.count * MemoryLayout<VertexIn>.stride, options: [])!
        
        // Get an available command buffer
        guard let commandBuffer = commandQueue.makeCommandBuffer() else { return }
        
        // Get the default MTLRenderPassDescriptor from the MTKView argument
        guard let renderPassDescriptor = view.currentRenderPassDescriptor else { return }
        
        // Change default settings. For example, we change the clear color from black to red.
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(1, 1, 1, 1)
        
        // We compile renderPassDescriptor to a MTLRenderCommandEncoder.
        guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else { return }
        
        // Setup render commands to encode
        // We tell it what render pipeline to use
        renderEncoder.setRenderPipelineState(pipelineState)
        // What vertex buffer data to use
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        // Scene buffer, with matrix transformations
        renderEncoder.setVertexBuffer(sceneBuffer, offset: 0, index: 1)
        // And what to draw
        renderEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 5)
        
        // This finalizes the encoding of drawing commands.
        renderEncoder.endEncoding()
        
        // Tell Metal to send the rendering result to the MTKView when rendering completes
        commandBuffer.present(view.currentDrawable!)
        
        // Finally, send the encoded command buffer to the GPU.
        commandBuffer.commit()
    }
    
    // mtkView will automatically call this function
    // whenever the size of the view changes (such as resizing the window).
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        
    }
    
    class func buildRenderPipelineWith(device: MTLDevice, metalKitView: MTKView, vertexDescriptor: MTLVertexDescriptor) throws -> MTLRenderPipelineState {
        // Create a new pipeline descriptor
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        
        pipelineDescriptor.vertexDescriptor = vertexDescriptor
        
        // Setup the shaders in the pipeline
        let library = device.makeDefaultLibrary()
        pipelineDescriptor.vertexFunction = library?.makeFunction(name: "vertexShader")
        pipelineDescriptor.fragmentFunction = library?.makeFunction(name: "fragmentShader")
        
        let renderbufferAttachment = pipelineDescriptor.colorAttachments[0]!
        
        // Setup the output pixel format to match the pixel format of the metal kit view
        renderbufferAttachment.pixelFormat = metalKitView.colorPixelFormat
                
        // Setup alpha blending
        renderbufferAttachment.isBlendingEnabled = true
        renderbufferAttachment.rgbBlendOperation = MTLBlendOperation.add
        renderbufferAttachment.alphaBlendOperation = MTLBlendOperation.add
        renderbufferAttachment.sourceRGBBlendFactor = MTLBlendFactor.sourceAlpha
        renderbufferAttachment.sourceAlphaBlendFactor = MTLBlendFactor.sourceAlpha
        renderbufferAttachment.destinationRGBBlendFactor = MTLBlendFactor.oneMinusSourceAlpha
        renderbufferAttachment.destinationAlphaBlendFactor = MTLBlendFactor.oneMinusSourceAlpha
        
        // Compile the configured pipeline descriptor to a pipeline state object
        return try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
    }
}
