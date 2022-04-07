//
//  ShaderDefinitions.h
//  HelloTriangleSwift
//
//  Created by qe on 3/30/22.
//

#include <simd/simd.h>

struct VertexIn {
    vector_float3 pos;
    vector_float4 color;
};

struct Scene {
    matrix_float4x4 modelTransform;
    matrix_float4x4 modelViewProjectionTransform;
    matrix_float4x4 modelViewTransform;
    matrix_float4x4 normalTransform;
    matrix_float2x3 boundingBox;
};
