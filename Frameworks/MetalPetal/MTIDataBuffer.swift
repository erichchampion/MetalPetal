//
//  MTIDataBuffer.swift
//  MetalPetal
//
//  Created by Yu Ao on 2019/1/24.
//

import Foundation
import Metal

#if SWIFT_PACKAGE
import MetalPetalObjectiveC.Core
#endif

extension MTIDataBuffer {
    
    public convenience init?<T>(values: [T], options: MTLResourceOptions = []) {
        // Use withUnsafeBytes to safely access the array's memory and copy it to Data
        // This avoids the warning about forming unsafe pointers to generic arrays
        let data = values.withUnsafeBytes { bytes in
            Data(bytes: bytes.baseAddress!, count: bytes.count)
        }
        self.init(data: data, options: options)
    }
    
    public func unsafeAccess<ReturnType, BufferContentType>(_ block: (UnsafeMutableBufferPointer<BufferContentType>) throws -> ReturnType) rethrows -> ReturnType {
        var buffer: UnsafeMutableBufferPointer<BufferContentType>!
        self.unsafeAccess { (pointer: UnsafeMutableRawPointer, length: UInt) -> Void in
            precondition(Int(length) % MemoryLayout<BufferContentType>.stride == 0)
            let count = Int(length) / MemoryLayout<BufferContentType>.stride
            buffer = UnsafeMutableBufferPointer(start: pointer.bindMemory(to: BufferContentType.self, capacity: count), count: count)
        }
        return try block(buffer)
    }
}
