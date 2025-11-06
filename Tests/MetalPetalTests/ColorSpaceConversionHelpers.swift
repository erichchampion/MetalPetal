//
//  ColorSpaceConversionHelpers.swift
//  MetalPetalTests
//
//  Created for MetalPetal test utilities
//

import Foundation

/// Utility functions for color space conversions in tests.
/// These formulas implement the standard sRGB gamma correction as defined by IEC 61966-2-1.
enum ColorSpaceConversion {

    // MARK: - sRGB Constants

    /// Threshold below which the linear segment is used in sRGB to linear conversion
    private static let sRGBToLinearThreshold: Double = 0.04045

    /// Threshold below which the linear segment is used in linear to sRGB conversion
    private static let linearToSRGBThreshold: Double = 0.0031308

    /// Slope of the linear segment in sRGB space
    private static let linearSegmentSlope: Double = 12.92

    /// Scale factor for the gamma segment
    private static let gammaSegmentScale: Double = 1.055

    /// Offset for the gamma segment
    private static let gammaSegmentOffset: Double = 0.055

    /// Gamma exponent for sRGB conversion
    private static let gammaExponent: Double = 2.4

    // MARK: - Conversion Functions

    /// Convert a color value from sRGB to linear color space.
    ///
    /// - Parameter c: Color component value in sRGB space (typically 0.0 to 1.0)
    /// - Returns: Color component value in linear space
    static func sRGBToLinear(_ c: Double) -> Double {
        if c <= sRGBToLinearThreshold {
            return c / linearSegmentSlope
        } else {
            return pow((c + gammaSegmentOffset) / gammaSegmentScale, gammaExponent)
        }
    }

    /// Convert a color value from linear to sRGB color space.
    ///
    /// - Parameter c: Color component value in linear space
    /// - Returns: Color component value in sRGB space
    static func linearToSRGB(_ c: Double) -> Double {
        if c < linearToSRGBThreshold {
            return linearSegmentSlope * c
        } else {
            return gammaSegmentScale * pow(c, 1.0 / gammaExponent) - gammaSegmentOffset
        }
    }

    /// Convert a UInt8 color value (0-255) from sRGB to linear and back to UInt8.
    ///
    /// - Parameter value: UInt8 value in sRGB space (0-255)
    /// - Returns: UInt8 value representing the linear color (0-255)
    static func sRGBToLinearUInt8(_ value: UInt8) -> UInt8 {
        let normalized = Double(value) / 255.0
        let linear = sRGBToLinear(normalized)
        return UInt8(round(linear * 255.0))
    }

    /// Convert a UInt8 color value (0-255) from linear to sRGB.
    ///
    /// - Parameter value: UInt8 value in linear space (0-255)
    /// - Returns: UInt8 value in sRGB space (0-255)
    static func linearToSRGBUInt8(_ value: UInt8) -> UInt8 {
        let normalized = Double(value) / 255.0
        let srgb = linearToSRGB(normalized)
        return UInt8(round(srgb * 255.0))
    }

    /// Convert a linear color value to sRGB, scaled by alpha for premultiplied output.
    ///
    /// - Parameters:
    ///   - c: Color component value in linear space
    ///   - alpha: Alpha value (0.0 to 1.0)
    /// - Returns: sRGB value scaled by alpha and multiplied by 255
    static func linearToSRGBWithAlpha(_ c: Float, alpha: Float) -> Float {
        let srgb = linearToSRGB(Double(c))
        return Float(srgb) * 255.0 * alpha
    }
}
