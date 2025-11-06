# MetalPetal Framework - Build and Release Guide

## Overview

MetalPetal is distributed via:
1. **Swift Package Manager** (SPM) - via `Package.swift`
2. **CocoaPods** - via `MetalPetal.podspec.json` and `Frameworks/MetalPetal/MetalPetal.podspec`
3. **Xcode Workspaces** - for development and testing

## Project Structure

```
MetalPetal/
├── Package.swift                    # Swift Package Manager manifest
├── MetalPetal.podspec.json          # Published CocoaPods spec (generated)
├── Frameworks/MetalPetal/
│   └── MetalPetal.podspec          # Development podspec (source of truth)
├── Sources/                         # Swift Package Manager sources
│   ├── MetalPetal/                 # Swift sources
│   └── MetalPetalObjectiveC/       # Objective-C sources
├── Utilities/                       # Code generation tools
│   └── Sources/
│       ├── PodspecGenerator/       # Generates MetalPetal.podspec.json
│       ├── SwiftPackageGenerator/  # Generates Sources/ from Frameworks/
│       ├── UmbrellaHeaderGenerator/ # Generates MetalPetal.h
│       └── BoilerplateGenerator/    # Generates boilerplate code
└── test.sh                          # Cross-platform test script
```

## Building the Framework

### For Development

#### Swift Package Manager (Recommended)

```bash
# Build for macOS (default)
swift build -c release

# Build for specific platform
swift build -c release --triple arm64-apple-ios14.0

# Run tests
swift test
```

Or open in Xcode:
```bash
open .swiftpm/xcode/package.xcworkspace
```

#### CocoaPods (For Examples Project)

```bash
# Install pods
pod install

# Build examples
xcodebuild -workspace MetalPetalExamples.xcworkspace \
  -scheme "MetalPetalExamples (iOS)" \
  -sdk iphonesimulator \
  build
```

### For Testing

Run the comprehensive test suite:
```bash
./test.sh
```

This tests:
- macOS
- iOS Simulator
- iOS Device
- tvOS Simulator
- tvOS Device
- Mac Catalyst

## Release Process

### Prerequisites

1. All changes committed and pushed
2. Tests pass: `./test.sh`
3. Version number decided (semantic versioning: `MAJOR.MINOR.PATCH`)

### Step 1: Generate Required Files

Before releasing, generate all necessary files:

```bash
# Option 1: Use the interactive utility script
./utilities.sh
# Select "All" to generate everything

# Option 2: Run individually
cd Utilities
swift run main boilerplate-generator ..
swift run main umbrella-header-generator ..
swift run main swift-package-generator ..
swift run main podspec-generator ..
```

**What each generator does:**
- **boilerplate-generator**: Generates SIMD argument encoders and blend formula support code
- **umbrella-header-generator**: Generates `Frameworks/MetalPetal/MetalPetal.h` umbrella header
- **swift-package-generator**: Syncs `Sources/` from `Frameworks/MetalPetal/` for SPM
- **podspec-generator**: Generates `MetalPetal.podspec.json` from the podspec, updating version and paths

### Step 2: Update Version Number

**Important**: The version is read from the latest git tag. Update the version in `Frameworks/MetalPetal/MetalPetal.podspec`:

```ruby
s.version      = '1.24.0'  # Update this
```

Then run the podspec generator (Step 1) which will:
1. Read the latest git tag: `git describe --abbrev=0 --tags`
2. Update `MetalPetal.podspec.json` with the version
3. Update source paths for the published podspec

### Step 3: Create Git Tag

```bash
# Create and push the tag
git tag -a v1.24.0 -m "Release version 1.24.0"
git push origin v1.24.0
```

**Note**: The podspec generator reads the latest tag, so tag **after** generating the podspec, or regenerate after tagging.

### Step 4: Verify Builds

Test all platforms:
```bash
./test.sh
```

Or manually test:
```bash
# Swift Package Manager
swift build -c release
swift test

# iOS Simulator
xcodebuild build -scheme MetalPetal \
  -destination 'platform=iOS Simulator,name=iPhone 11' \
  -workspace .swiftpm/xcode/package.xcworkspace

# macOS
xcodebuild build -scheme MetalPetal \
  -destination 'platform=macOS' \
  -workspace .swiftpm/xcode/package.xcworkspace
```

### Step 5: Create GitHub Release

1. Go to GitHub Releases page
2. Click "Draft a new release"
3. Select the tag you just created
4. Add release notes
5. Publish the release

### Step 6: Publish to CocoaPods

The GitHub Actions workflow (`.github/workflows/cocoapods.yml`) automatically:
1. Triggers on release publication
2. Updates the podspec using `podspec-generator`
3. Publishes to CocoaPods Trunk

**Manual publish** (if needed):
```bash
# Ensure you have CocoaPods trunk access
pod trunk me

# Publish
pod trunk push MetalPetal.podspec.json
```

## Distribution Methods

### Swift Package Manager

Users add via `Package.swift`:
```swift
dependencies: [
    .package(url: "https://github.com/MetalPetal/MetalPetal.git", from: "1.24.0")
]
```

The `Package.swift` file is manually maintained and should be updated when:
- Adding new targets
- Changing dependencies
- Updating platform requirements

### CocoaPods

Users add via `Podfile`:
```ruby
pod 'MetalPetal/Swift', '~> 1.24.0'
```

Two podspec files:
- `Frameworks/MetalPetal/MetalPetal.podspec` - Development version (local path)
- `MetalPetal.podspec.json` - Published version (generated, includes version and full paths)

### Xcode Project

For development, users can:
1. Add the Swift Package directly in Xcode
2. Use CocoaPods with `pod install`
3. Use the examples workspace: `MetalPetalExamples.xcworkspace`

## Release Checklist

- [ ] All code changes committed
- [ ] Version number updated in `Frameworks/MetalPetal/MetalPetal.podspec`
- [ ] Generated all required files (`./utilities.sh` → "All")
- [ ] All tests pass (`./test.sh`)
- [ ] Swift Package Manager build succeeds (`swift build -c release`)
- [ ] CocoaPods build succeeds (`pod install && xcodebuild`)
- [ ] Created git tag (`git tag -a v1.24.0`)
- [ ] Pushed tag to remote (`git push origin v1.24.0`)
- [ ] Created GitHub release with release notes
- [ ] Verified CocoaPods publish (automatic via GitHub Actions)
- [ ] Updated CHANGELOG.md (if maintained)

## Version Numbering

Follow [Semantic Versioning](https://semver.org/):
- **MAJOR**: Breaking API changes
- **MINOR**: New features, backward compatible
- **PATCH**: Bug fixes, backward compatible

Example: `1.23.0` → `1.24.0` (minor release)

## Troubleshooting

### Podspec Generation Fails

Ensure you have the latest git tag:
```bash
git fetch --tags
git describe --abbrev=0 --tags
```

### Swift Package Sources Out of Sync

Regenerate from Frameworks:
```bash
cd Utilities
swift run main swift-package-generator ..
```

### CocoaPods Release Fails

Check:
1. CocoaPods trunk access: `pod trunk me`
2. Version tag exists: `git tag -l`
3. Podspec is valid: `pod spec lint MetalPetal.podspec.json`

## CI/CD

### GitHub Actions Workflows

1. **`.github/workflows/swift.yml`** - Tests on push/PR:
   - macOS build/test
   - iOS Simulator build/test
   - tvOS Simulator build/test
   - iOS Device build
   - tvOS Device build
   - Mac Catalyst build/test

2. **`.github/workflows/cocoapods.yml`** - Publishes on release:
   - Generates podspec
   - Publishes to CocoaPods Trunk

## Development vs Release Podspecs

- **Development** (`Frameworks/MetalPetal/MetalPetal.podspec`):
  - Uses relative paths: `**/*.{h,m,c,mm,metal}`
  - Version: `1.0` (placeholder)
  - Used for local development

- **Release** (`MetalPetal.podspec.json`):
  - Uses absolute paths: `Frameworks/MetalPetal/**/*.{h,m,c,mm,metal}`
  - Version: From git tag (e.g., `1.24.0`)
  - Used for CocoaPods distribution

## Summary

**Quick Release Steps:**
1. Update version in `Frameworks/MetalPetal/MetalPetal.podspec`
2. Run `./utilities.sh` → "All"
3. Test: `./test.sh`
4. Tag: `git tag -a v1.24.0 && git push origin v1.24.0`
5. Create GitHub release
6. CocoaPods publish happens automatically

**For Development:**
- Use `swift build` for SPM
- Use `MetalPetalExamples.xcworkspace` for CocoaPods examples
- Use `.swiftpm/xcode/package.xcworkspace` for framework-only builds

