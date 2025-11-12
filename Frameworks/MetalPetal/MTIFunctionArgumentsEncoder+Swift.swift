//
//  MTIFunctionArgumentsEncoder+Swift.swift
//  MetalPetal
//
//  Created by GPT-5 Codex on 2025/11/11.
//

import Foundation
import Metal

#if SWIFT_PACKAGE
import MetalPetalObjectiveC.Core
#endif

extension MTIFunctionArgumentsEncoder {
    
    /// Convenience overload preserving the historical Swift signature that accepts `MTLArgument` arrays.
    @discardableResult
    public static func encode(_ arguments: [MTLArgument],
                              values: [String: Any],
                              functionType: MTLFunctionType,
                              encoder: MTLCommandEncoder) throws -> Bool {
        return try encodeArguments(arguments as [Any],
                                   values: values,
                                   functionType: functionType,
                                   encoder: encoder)
    }
}

