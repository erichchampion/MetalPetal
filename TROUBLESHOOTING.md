# Troubleshooting Build Errors

## Error: "No such module 'MetalPetal'" when building MetalPetal.swift

### Problem
You're seeing this error when trying to build the MetalPetal framework:
```
/Users/erich/git/github/erichchampion/MetalPetal/MetalPetalExamples/Shared/ImageFilterView.swift:9:8 No such module 'MetalPetal'
```

### Cause
This happens when:
1. You're building the **Swift Package Manager workspace** (`.swiftpm/xcode/package.xcworkspace`) and Xcode is trying to compile files from the **examples project**
2. The examples project files are being included in the wrong workspace context
3. The MetalPetal module isn't available in that build context

### Solution

**Option 1: Build the Examples Project (Recommended)**
- Open `MetalPetalExamples.xcworkspace` (NOT the Swift Package Manager workspace)
- Select the "MetalPetalExamples (iOS)" or "MetalPetalExamples (macOS)" scheme
- Build (⌘B)

**Option 2: Build the Framework Only**
- Open `.swiftpm/xcode/package.xcworkspace` 
- Select the "MetalPetal" scheme
- Choose your platform (macOS, iOS Simulator, etc.)
- Build (⌘B)
- **Important**: Don't include the examples project in this workspace

**Option 3: Use Command Line**
```bash
# Build the framework
swift build -c release

# Build the examples project
xcodebuild -workspace MetalPetalExamples.xcworkspace -scheme "MetalPetalExamples (iOS)" -sdk iphonesimulator build
```

### Quick Fix
1. Close all Xcode windows
2. Delete DerivedData: `rm -rf ~/Library/Developer/Xcode/DerivedData/MetalPetalExamples-*`
3. Open the **correct workspace**:
   - For examples: `open MetalPetalExamples.xcworkspace`
   - For framework only: `open .swiftpm/xcode/package.xcworkspace`
4. Clean build folder (⌘Shift+K)
5. Build again

## Warning: "art.scnassets Couldn't load because it is already opened"

### Problem
```
Couldn't load art.scnassets because it is already opened from another project or workspace
```

### Cause
The asset catalog is open in multiple Xcode windows/workspaces.

### Solution
1. Close the asset catalog in all Xcode windows
2. Or close the extra Xcode workspace window
3. This is harmless and won't prevent builds

## Summary

- **Examples Project**: Use `MetalPetalExamples.xcworkspace`
- **Framework Only**: Use `.swiftpm/xcode/package.xcworkspace` or `swift build`
- **Never mix**: Don't include examples project files when building the framework workspace


