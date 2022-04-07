//
//  Shaders.metal
//  HelloTriangleSwift
//
//  Created by qe on 3/30/22.
//

#include <metal_stdlib>
//#include "ShaderDefinitions.h"

using namespace metal;

struct VertexIn {
    float3 pos [[attribute(0)]];
    float4 color [[attribute(1)]];
};

struct Scene {
    float4x4 modelTransform;
    float4x4 modelViewProjectionTransform;
    float4x4 modelViewTransform;
    float4x4 normalTransform;
    float2x3 boundingBox;
};

struct VertexOut {
    float4 pos [[position]];
    float4 color;
};

vertex VertexOut vertexShader(VertexIn in [[stage_in]], constant Scene& scn [[buffer(1)]]) {
    VertexOut out;
    
    // Pass the already normalized screen-space coordinates to the rasterizer
    out.pos = scn.modelViewProjectionTransform * float4(in.pos, 1);
    
    // Pass the vertex color directly to the rasterizer
    out.color = in.color;
    
    return out;
}

fragment float4 fragmentShader(VertexOut interpolated [[stage_in]]) {
    return interpolated.color;
}
