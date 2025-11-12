# Building MetalPetal Framework

## Overview

The MetalPetal framework can be built in several ways:

1. **Swift Package Manager** (recommended for framework development)
2. **CocoaPods** (for integration into apps)
3. **Xcode** (via Swift Package Manager workspace)

## Building Methods

### Method 1: Swift Package Manager (Command Line)

```bash
# Build for macOS (default)
swift build -c release

# Build for iOS (requires Xcode)
# This builds the framework in the build directory
swift build -c release
```

The built products will be in `.build/` directory.

### Method 2: Swift Package Manager (Xcode)

1. Open the Swift Package Manager workspace:
   ```bash
   open .swiftpm/xcode/package.xcworkspace
   ```
   
2. Select the `MetalPetal` scheme
3. Choose your target platform (iOS, macOS, tvOS)
4. Build (⌘B) or Product → Build

### Method 3: CocoaPods

The framework is automatically built when you:
1. Install pods: `pod install`
2. Build the examples project: `xcodebuild -workspace MetalPetalExamples.xcworkspace -scheme "MetalPetalExamples (iOS)" build`

The built framework will be in `Pods/Pods.xcodeproj` and the output in DerivedData.

## Important Notes

### ❌ Don't Build Single Files

**You cannot build `Frameworks/MetalPetal/MetalPetal.swift` directly** because:
- It's just one file in a larger framework
- It depends on `MetalPetalObjectiveC` module
- It requires the entire framework structure to compile

### ✅ Build the Entire Framework

Always build the complete framework using one of the methods above.

## Understanding the Errors/Warnings

### Critical Errors

1. **"No such module 'MetalPetal'"** - This happens when:
   - Trying to build a single file in isolation
   - Build settings are incorrect (see previous fixes)
   - Framework dependencies aren't resolved

### Warnings (Non-Critical)

Most warnings are informational and don't prevent the framework from working:

1. **Deprecation Warnings** (e.g., `MTLArgument` deprecated in iOS 16.0)
   - These are warnings about future API changes
   - The framework still works, but should be updated eventually

2. **Variable Length Array Warnings**
   - Clang extensions that are safe to use
   - Can be suppressed with compiler flags if needed

3. **Extension Conformance Warnings**
   - Warnings about potential future conflicts
   - Safe to ignore unless the underlying framework adds these conformances

4. **Sendability Warnings** (Swift 6)
   - Future compatibility warnings for Swift 6
   - Current code works fine with Swift 5.x

5. **Test Deprecations** (`assign(repeating:count:)`)
   - Test code warnings, doesn't affect the framework
   - Can be fixed by updating to `update(repeating:count:)`

## Building for Release/Distribution

### For Swift Package Manager

```bash
swift build -c release
```

### For CocoaPods

1. Build the framework:
   ```bash
   xcodebuild -workspace MetalPetalExamples.xcworkspace \
     -scheme "MetalPetalExamples (iOS)" \
     -configuration Release \
     -sdk iphoneos \
     build
   ```

2. The framework will be in:
   ```
   ~/Library/Developer/Xcode/DerivedData/MetalPetalExamples-*/Build/Products/Release-iphoneos/MetalPetal-Core-Swift/MetalPetal.framework
   ```

### Creating a Universal Framework

For distribution, you may want to create a universal (fat) binary:

```bash
# Build for iOS device
xcodebuild -workspace MetalPetalExamples.xcworkspace \
  -scheme "MetalPetalExamples (iOS)" \
  -configuration Release \
  -sdk iphoneos \
  build

# Build for iOS Simulator  
xcodebuild -workspace MetalPetalExamples.xcworkspace \
  -scheme "MetalPetalExamples (iOS)" \
  -configuration Release \
  -sdk iphonesimulator \
  build

# Then use lipo to combine them (if needed)
```

## Troubleshooting

### "No such module 'MetalPetal'" Error

If you see this when building the framework itself (not when using it):

1. Make sure you're building the entire framework, not individual files
2. Check that dependencies are resolved:
   ```bash
   swift package resolve
   ```
3. For CocoaPods:
   ```bash
   pod install
   ```

### Build Settings Issues

If you have module resolution issues in consuming projects, ensure:
- `SWIFT_INCLUDE_PATHS` is set correctly
- `FRAMEWORK_SEARCH_PATHS` includes the framework directory
- `OTHER_SWIFT_FLAGS` includes `-F` flag for framework search paths

## Running Tests

```bash
# Swift Package Manager
swift test

# Xcode
xcodebuild test -scheme MetalPetal -destination 'platform=iOS Simulator,name=iPhone 11'
```


