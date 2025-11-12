//
//  MTISIMDArgumentEncoder.swift
//  MetalPetal
//
//  Auto-generated.
//

import Foundation
import Metal

#if SWIFT_PACKAGE
import MetalPetalObjectiveC.Core
#endif

@objc(MTISIMDArgumentEncoder) public class MTISIMDArgumentEncoder: NSObject, MTIFunctionArgumentEncoding {
    
    public enum Error: String, Swift.Error, LocalizedError {
        case argumentTypeMismatch
        public var errorDescription: String? {
            return self.rawValue
        }
    }
    
    public static func encodeValue(_ value: Any, argument: Any, proxy: MTIFunctionArgumentEncodingProxy) throws {
        guard let dataType = Self.bufferDataType(for: argument) else {
            return
        }
        switch value {
        case let v as SIMD2<Float>:
            guard dataType == .float2 else {
                throw Error.argumentTypeMismatch
            }
            encode(v, proxy: proxy)
        case let v as SIMD3<Float>:
            guard dataType == .float3 else {
                throw Error.argumentTypeMismatch
            }
            encode(v, proxy: proxy)
        case let v as SIMD4<Float>:
            guard dataType == .float4 else {
                throw Error.argumentTypeMismatch
            }
            encode(v, proxy: proxy)
        case let v as float2x2:
            guard dataType == .float2x2 else {
                throw Error.argumentTypeMismatch
            }
            encode(v, proxy: proxy)
        case let v as float2x3:
            guard dataType == .float2x3 else {
                throw Error.argumentTypeMismatch
            }
            encode(v, proxy: proxy)
        case let v as float2x4:
            guard dataType == .float2x4 else {
                throw Error.argumentTypeMismatch
            }
            encode(v, proxy: proxy)
        case let v as float3x2:
            guard dataType == .float3x2 else {
                throw Error.argumentTypeMismatch
            }
            encode(v, proxy: proxy)
        case let v as float3x3:
            guard dataType == .float3x3 else {
                throw Error.argumentTypeMismatch
            }
            encode(v, proxy: proxy)
        case let v as float3x4:
            guard dataType == .float3x4 else {
                throw Error.argumentTypeMismatch
            }
            encode(v, proxy: proxy)
        case let v as float4x2:
            guard dataType == .float4x2 else {
                throw Error.argumentTypeMismatch
            }
            encode(v, proxy: proxy)
        case let v as float4x3:
            guard dataType == .float4x3 else {
                throw Error.argumentTypeMismatch
            }
            encode(v, proxy: proxy)
        case let v as float4x4:
            guard dataType == .float4x4 else {
                throw Error.argumentTypeMismatch
            }
            encode(v, proxy: proxy)
        case let v as SIMD2<Int32>:
            guard dataType == .int2 else {
                throw Error.argumentTypeMismatch
            }
            encode(v, proxy: proxy)
        case let v as SIMD3<Int32>:
            guard dataType == .int3 else {
                throw Error.argumentTypeMismatch
            }
            encode(v, proxy: proxy)
        case let v as SIMD4<Int32>:
            guard dataType == .int4 else {
                throw Error.argumentTypeMismatch
            }
            encode(v, proxy: proxy)
        case let v as SIMD2<UInt32>:
            guard dataType == .uint2 else {
                throw Error.argumentTypeMismatch
            }
            encode(v, proxy: proxy)
        case let v as SIMD3<UInt32>:
            guard dataType == .uint3 else {
                throw Error.argumentTypeMismatch
            }
            encode(v, proxy: proxy)
        case let v as SIMD4<UInt32>:
            guard dataType == .uint4 else {
                throw Error.argumentTypeMismatch
            }
            encode(v, proxy: proxy)
        case let v as SIMD2<Int16>:
            guard dataType == .short2 else {
                throw Error.argumentTypeMismatch
            }
            encode(v, proxy: proxy)
        case let v as SIMD3<Int16>:
            guard dataType == .short3 else {
                throw Error.argumentTypeMismatch
            }
            encode(v, proxy: proxy)
        case let v as SIMD4<Int16>:
            guard dataType == .short4 else {
                throw Error.argumentTypeMismatch
            }
            encode(v, proxy: proxy)
        case let v as SIMD2<UInt16>:
            guard dataType == .ushort2 else {
                throw Error.argumentTypeMismatch
            }
            encode(v, proxy: proxy)
        case let v as SIMD3<UInt16>:
            guard dataType == .ushort3 else {
                throw Error.argumentTypeMismatch
            }
            encode(v, proxy: proxy)
        case let v as SIMD4<UInt16>:
            guard dataType == .ushort4 else {
                throw Error.argumentTypeMismatch
            }
            encode(v, proxy: proxy)
        case let v as SIMD2<Int8>:
            guard dataType == .char2 else {
                throw Error.argumentTypeMismatch
            }
            encode(v, proxy: proxy)
        case let v as SIMD3<Int8>:
            guard dataType == .char3 else {
                throw Error.argumentTypeMismatch
            }
            encode(v, proxy: proxy)
        case let v as SIMD4<Int8>:
            guard dataType == .char4 else {
                throw Error.argumentTypeMismatch
            }
            encode(v, proxy: proxy)
        case let v as SIMD2<UInt8>:
            guard dataType == .uchar2 else {
                throw Error.argumentTypeMismatch
            }
            encode(v, proxy: proxy)
        case let v as SIMD3<UInt8>:
            guard dataType == .uchar3 else {
                throw Error.argumentTypeMismatch
            }
            encode(v, proxy: proxy)
        case let v as SIMD4<UInt8>:
            guard dataType == .uchar4 else {
                throw Error.argumentTypeMismatch
            }
            encode(v, proxy: proxy)
#if !os(tvOS)
        case let v as MTLPackedFloat3:
            guard dataType == .float3 else {
                throw Error.argumentTypeMismatch
            }
            encode(v, proxy: proxy)
#endif
        default:
            break
        }
    }
    
    @inline(__always)
    private static func bufferDataType(for argument: Any) -> MTLDataType? {
        if let argument = argument as? MTLArgument {
            return argument.bufferDataType
        }
        if #available(iOS 16.0, macOS 13.0, tvOS 16.0, *) {
            if let binding = argument as AnyObject?,
               binding.responds(to: Selector(("bufferDataType"))) {
                if binding.responds(to: Selector(("type"))),
                   let typeValue = binding.value(forKey: "type") as? NSNumber,
                   typeValue.uintValue != UInt(MTLBindingType.buffer.rawValue) {
                    return nil
                }
                if let value = binding.value(forKey: "bufferDataType") as? NSNumber,
                   let dataType = MTLDataType(rawValue: value.uintValue) {
                    return dataType
                }
            }
        }
        return nil
    }

    private static func encode<T>(_ value: T, proxy: MTIFunctionArgumentEncodingProxy) {
        withUnsafePointer(to: value) { ptr in
            proxy.encodeBytes(ptr, length: UInt(MemoryLayout.size(ofValue: value)))
        }
    }
}
