//
//  File.swift
//  
//
//  Created by YuAo on 2020/7/11.
//

import Foundation
import SIMDType

fileprivate let template: String = """
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
{MTI_SIMD_SHADER_ARGUMENT_ENCODER_GENERATED}
        default:
            break
        }
    }

    private static func encode<T>(_ value: T, proxy: MTIFunctionArgumentEncodingProxy) {
        withUnsafePointer(to: value) { ptr in
            proxy.encodeBytes(ptr, length: UInt(MemoryLayout.size(ofValue: value)))
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
}

"""

public struct MTISIMDShaderArgumentEncoderGenerator {
    public static func generate() -> [String: String] {
        var content: String = ""
        for simdType in SIMDType.metalSupportedSIMDTypes {
            switch simdType.dimension {
            case .vector(let count):
                content.append(
                """
                        case let v as SIMD\(count)<\(simdType.scalarType.swiftTypeName)>:
                            guard dataType == .\(simdType.scalarType.description(capitalized: false))\(count) else {
                                throw Error.argumentTypeMismatch
                            }
                            encode(v, proxy: proxy)
                
                """)
            case .matrix(let c, let r):
                content.append(
                """
                        case let v as \(simdType.scalarType.description(capitalized: false))\(c)x\(r):
                            guard dataType == .\(simdType.scalarType.description(capitalized: false))\(c)x\(r) else {
                                throw Error.argumentTypeMismatch
                            }
                            encode(v, proxy: proxy)
                
                """)
            }
        }
        content.append(
                """
                #if !os(tvOS)
                        case let v as MTLPackedFloat3:
                            guard dataType == .float3 else {
                                throw Error.argumentTypeMismatch
                            }
                            encode(v, proxy: proxy)
                #endif
                """)
        return ["MTISIMDArgumentEncoder.swift": template.replacingOccurrences(of: "{MTI_SIMD_SHADER_ARGUMENT_ENCODER_GENERATED}", with: content)]
    }
}
