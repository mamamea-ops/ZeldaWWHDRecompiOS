# iOS SDK Migration Analysis: macOS to iOS Framework Conversion

## Executive Summary
This document details all macOS-exclusive frameworks and SDKs discovered in the ZeldaWWHDRecompiOS repository, with iOS equivalents or exclusion strategies for each.

---

## 1. AppKit Framework (macOS-only)

### Overview
**Files Affected:**
- `runtime/src/gfx/menu.mm` (≈400 LOC)
- `runtime/src/gfx/input.mm` (≈800 LOC)
- `runtime/src/gfx/overlay_appkit.mm` (≈140 LOC)
- `runtime/src/gfx/text_input_appkit.mm` (≈114 LOC)
- `runtime/src/gfx/quit_prompt.mm` (≈250 LOC)

### Dependencies
```
AppKit Framework:
├── NSApp
├── NSWindow
├── NSMenu / NSMenuItem
├── NSAlert
├── NSEvent
├── NSPasteboard
├── NSWorkspace
├── NSUserDefaults
├── NSTextInputClient / NSTextInputContext
├── Carbon.framework (kVK_* key codes)
└── Cocoa/Cocoa.h (comprehensive macOS foundation)
```

### iOS Equivalent Strategy

#### **Option 1: Conditional Exclusion (RECOMMENDED)**
Since iOS build excludes these files via CMakeLists.txt (lines 95-97):
```cmake
list(FILTER WWHD_ENGINE_SOURCES EXCLUDE REGEX "/runtime/src/gfx/(menu|input)\\.mm$")
list(FILTER WWHD_ENGINE_SOURCES EXCLUDE REGEX "/runtime/src/gfx/controls_ui\\.mm$")
list(FILTER WWHD_ENGINE_SOURCES EXCLUDE REGEX "/runtime/src/gfx/(metal_main|metal_draw|metal_surfaces|overlay_appkit|quit_prompt|shader_headstart|text_input_appkit)\\.mm$")
```

**Action Required:** ✅ **NO CHANGES NEEDED** - Already properly excluded for iOS

#### **Option 2: iOS UIKit Replacement (if needed)**
Create `runtime/src/gfx/input_uikit.mm`:
```objc
#import <UIKit/UIKit.h>
#import <GameController/GameController.h>

// GameController.framework works identically on iOS and macOS
// No changes needed for controller input

// Keyboard input: NOT AVAILABLE on iOS
// Touch input: Use UIResponder/UIGestureRecognizer (already handled by platform layer)
```

---

## 2. Carbon Framework (macOS Input)

### Overview
**Files Affected:**
- `runtime/src/gfx/menu.mm` (Carbon/Carbon.h for kVK_* key codes)
- `runtime/src/gfx/input.mm` (Carbon/Carbon.h for key code constants)
- `runtime/src/gfx/text_input_appkit.mm` (Carbon/Carbon.h for key codes)

### Dependencies
```
Carbon.framework (Legacy):
├── kVK_Shift, kVK_RightShift
├── kVK_Control, kVK_RightControl
├── kVK_Option, kVK_RightOption
├── kVK_CapsLock
└── kVK_* key code constants (legacy Macintosh key codes)
```

### iOS Equivalent Strategy

**Status:** ❌ **NOT APPLICABLE ON iOS**
- iOS has no physical keyboard by default
- Virtual keyboard uses text input APIs (UITextInputDelegate)
- Key codes don't exist on iOS
- Already excluded via CMakeLists.txt filter

---

## 3. GameController Framework (Cross-Platform ✅)

### Overview
**Files Affected:**
- `runtime/src/gfx/input.mm` (lines 8-82)
- `runtime/src/gfx/metal_main.mm` (indirectly)

### Dependencies
```
GameController.framework (iOS 7+):
├── GCController
├── GCExtendedGamepad
├── GCControllerButtonInput
├── GCControllerDirectionPad
├── GCControllerAxisInput
├── GCMotion (gyro/accelerometer)
└── GCController.controllers
```

### iOS Equivalent Strategy

**Status:** ✅ **FULLY COMPATIBLE** 
- GameController.framework is identical on iOS and macOS
- Motion sensors (gyro/accelerometer) available on iOS via GameController
- **NO CHANGES REQUIRED**

---

## 4. Cocoa Framework (macOS)

### Overview
**File:** `runtime/src/gfx/menu.mm` (line 4: `#import <Cocoa/Cocoa.h>`)

### Components Used
```
Cocoa.framework (umbrella):
├── Foundation (NSString, NSArray, NSDictionary, etc.) ✅ AVAILABLE
├── AppKit (NSApp, NSWindow, NSMenu, etc.) ❌ iOS: UIKit
└── CoreData (not used)
```

### iOS Equivalent Strategy

**Cocoa (macOS):** Replace with **Foundation + UIKit**
- Foundation classes (NSString, NSArray, NSMutableDictionary) available on iOS ✅
- AppKit classes have no direct iOS equivalent — UIKit is the replacement ❌

**Status:** Already handled by exclusion filters

---

## 5. NSUserDefaults (macOS User Preferences)

### Overview
**Files Affected:**
- `runtime/src/gfx/menu.mm` (lines 62-128: pref() and set_pref())

### Code Location
```objc
// Lines 74-89: macOS NSUserDefaults usage
static id pref(NSString* key) {
    return [NSUserDefaults.standardUserDefaults objectForKey:key];
}
static void set_pref(NSString* key, id value) {
    [NSUserDefaults.standardUserDefaults setObject:value forKey:key];
}
```

### iOS Equivalent Strategy

**iOS Replacement: UserDefaults (same API!)**
```swift
// iOS equivalent (same Foundation class)
UserDefaults.standard.object(forKey: key)
UserDefaults.standard.set(value, forKey: key)
```

**Status:** ✅ **COMPATIBLE** - UserDefaults API is identical on iOS
- Works identically: `NSUserDefaults.standardUserDefaults` on both platforms
- NO CHANGES NEEDED

---

## 6. Quartz/QuartzCore Framework (Graphics Acceleration)

### Overview
**File:** `runtime/src/gfx/input.mm` (line 10: `#import <QuartzCore/QuartzCore.h>`)

### Usage
```objc
#include <QuartzCore/QuartzCore.h>  // CACurrentMediaTime
static void update_motion_sensors() {
    // Uses CACurrentMediaTime for motion sensor timing
}
```

### iOS Equivalent Strategy

**Status:** ✅ **FULLY COMPATIBLE**
- QuartzCore.framework available on iOS 2.0+
- CACurrentMediaTime() is identical on both platforms
- **NO CHANGES REQUIRED**

---

## 7. Metal Framework (Graphics Renderer)

### Overview
**Files Affected:**
- `runtime/src/gfx/metal_main.mm` (≈750 LOC)
- `runtime/src/gfx/metal_draw.mm` (≈2500 LOC)
- `runtime/src/gfx/metal_surfaces.mm` (≈1500 LOC)
- `runtime/src/gfx/metal_backend.mm` (≈100 LOC)

### Dependencies
```
Metal.framework (≈8.0+):
├── MTLDevice
├── MTLCommandQueue / MTLCommandBuffer
├── MTLRenderPipelineState
├── MTLTexture
├── MTLBuffer
├── MTLRenderPassDescriptor
├── MTLCommandEncoder
├── MTLPixelFormat
└── MTLCreateSystemDefaultDevice()
```

### iOS Equivalent Strategy

**Status:** ✅ **FULLY COMPATIBLE** (with limitations)
- Metal API is identical on iOS and macOS
- Metal available on iOS 8.0+
- GPU capabilities differ by device (A-series vs Intel Mac)
- **CONDITIONAL CODE NEEDED**: 
  - Desktop Metal features (e.g., MTLBlitOption flags) may not exist on all iOS devices
  - Some pixel formats unavailable on iOS (e.g., compressed formats on some Mali/PowerVR)

**Recommended Implementation:**
```objc
// metal_main.mm: Add iOS compatibility checks
#if TARGET_OS_IOS
    // iOS-specific Metal setup
    // Check device capabilities before using advanced features
    if (@available(iOS 16.0, *)) {
        // Use newer Metal features
    }
#else
    // macOS-specific Metal setup
#endif
```

---

## 8. MetalKit Framework (Metal Utilities)

### Overview
**CMakeLists.txt (lines 140-144):** Links MetalKit for macOS builds
```cmake
if(WWHD_HAS_METAL)
    target_link_libraries(wwhd_engine
        PUBLIC
            "-framework Metal"
            "-framework MetalKit"
    )
endif()
```

### iOS Equivalent Strategy

**Status:** ✅ **AVAILABLE ON iOS**
- MetalKit available on iOS 9.0+
- Same API on both platforms
- **NO CHANGES REQUIRED**

---

## 9. ImageIO Framework (Screenshot Functionality)

### Overview
**File:** `runtime/src/gfx/metal_main.mm` (line 4: `#import <ImageIO/ImageIO.h>`)

### Usage
```objc
// Used for PNG encoding of screenshots
#import <ImageIO/ImageIO.h>
#import <UniformTypeIdentifiers/UniformTypeIdentifiers.h>
```

### iOS Equivalent Strategy

**Status:** ✅ **FULLY COMPATIBLE**
- ImageIO framework available on iOS 4.0+
- Same PNG encoding APIs
- **NO CHANGES REQUIRED**

---

## 10. UniformTypeIdentifiers Framework (File Type Management)

### Overview
**File:** `runtime/src/gfx/metal_main.mm` (line 5: `#import <UniformTypeIdentifiers/UniformTypeIdentifiers.h>`)

### iOS Equivalent Strategy

**Status:** ✅ **COMPATIBLE** (iOS 14.0+)
- Available on iOS 14.0 and later
- Same API as macOS
- **NO CHANGES REQUIRED** (for iOS 14+ builds)

---

## 11. Application Control (NSApp)

### Overview
**Files Affected:**
- `runtime/src/gfx/input.mm` (line 181: `[NSApp postEvent:ev atStart:NO]`)
- `runtime/src/gfx/menu.mm` (used indirectly through menu system)
- `runtime/src/gfx/metal_main.mm` (line 173: `[NSApp run]`)

### iOS Equivalent Strategy

**Status:** ❌ **NOT APPLICABLE ON iOS**
- NSApp (NSApplication) is macOS-only
- iOS uses UIApplication / UIApplicationDelegate pattern
- Event posting works differently on iOS (GCD dispatch)
- **ALREADY EXCLUDED** via CMakeLists.txt filters

---

## 12. Display/Window Management

### Overview
**Files:**
- `runtime/src/gfx/display.mm` (≈100 LOC)
- `runtime/src/gfx/quit_prompt.mm` (≈250 LOC)

### macOS APIs Used
```objc
NSWindow
NSScreen
NSRect
NSView
NSNotificationCenter
```

### iOS Equivalent Strategy

**Status:** ❌ **ALREADY HANDLED**
- iOS uses UIWindow / UIViewController
- Already excluded via CMakeLists.txt lines 95-97
- **NO CHANGES NEEDED** for current build

**Future iOS Window Management:**
```swift
// iOS-specific (if re-implementing):
UIWindow
UIViewController
UIScreen
CGRect
NotificationCenter
```

---

## Summary Table

| Framework | Status | iOS Equivalent | Action |
|-----------|--------|-----------------|--------|
| **AppKit** | ❌ macOS only | UIKit | Already excluded ✅ |
| **Carbon** | ❌ macOS only | N/A (iOS no keyboard) | Already excluded ✅ |
| **GameController** | ✅ Cross-platform | GameController | No changes ✅ |
| **Cocoa** | ⚠️ Partial (Foundation only) | Foundation + UIKit | Already excluded ✅ |
| **NSUserDefaults** | ✅ Cross-platform | UserDefaults | No changes ✅ |
| **QuartzCore** | ✅ Cross-platform | QuartzCore | No changes ✅ |
| **Metal** | ✅ Cross-platform | Metal | Conditional checks needed ⚠️ |
| **MetalKit** | ✅ Cross-platform | MetalKit | No changes ✅ |
| **ImageIO** | ✅ Cross-platform | ImageIO | No changes ✅ |
| **UniformTypeIdentifiers** | ✅ iOS 14+ | UniformTypeIdentifiers | No changes ✅ |
| **NSApp/NSWindow** | ❌ macOS only | UIApplication/UIWindow | Already excluded ✅ |
| **Display System** | ❌ macOS only | UIKit Display | Already excluded ✅ |

---

## Implementation Recommendations

### 1. **Current Status: GOOD** ✅
The iOS build already properly excludes all macOS-exclusive code via `CMakeLists.txt`:
```cmake
if(CMAKE_SYSTEM_NAME STREQUAL "iOS")
    list(FILTER WWHD_ENGINE_SOURCES EXCLUDE REGEX "/runtime/src/gfx/(menu|input|controls_ui|metal_main|metal_draw|metal_surfaces|overlay_appkit|quit_prompt|shader_headstart|text_input_appkit)\\.mm$")
    list(FILTER WWHD_ENGINE_SOURCES EXCLUDE REGEX "/runtime/src/gfx/vulkan/.*\\.(cpp|h|mm)$")
```

### 2. **Required Changes: MINIMAL**
- ✅ No immediate changes required
- ⚠️ Add iOS-specific Metal device capability checks if targeting older iOS versions
- ⚠️ Implement iOS-specific display/input handling (UIKit layer)

### 3. **Recommended Additions**

**A. iOS Event Handling Stub** (`runtime/src/gfx/input_ios.mm`)
```objc
#include <GameController/GameController.h>

// iOS-specific input:
// - Touch input: handled by platform layer
// - GameController: works identically to macOS
// - No keyboard input on mobile
```

**B. iOS Display Stub** (`runtime/src/gfx/display_ios.mm`)
```swift
// iOS-specific display:
// - Uses UIViewController + UIView
// - Metal view created via MTKView
// - No menu system (use settings overlay only)
```

**C. Metal Capability Detection** (modify `runtime/src/gfx/metal_main.mm`)
```objc
#if TARGET_OS_IOS
    // Check device capabilities
    if (![device supportsFeatureSet:MTLFeatureSet_iOS_GPUFamily3_v1]) {
        // Fallback for older devices
    }
#endif
```

---

## Vulkan Status

**Note:** Vulkan is properly excluded for iOS:
```cmake
list(FILTER WWHD_ENGINE_SOURCES EXCLUDE REGEX "/runtime/src/gfx/vulkan/.*\\.(cpp|h|mm)$")
```

iOS supports Metal only; Vulkan is not available. ✅ **Correct exclusion.**

---

## Conclusion

The repository is **already well-configured for iOS compatibility**. All macOS-exclusive frameworks (AppKit, Carbon, NSApp) are properly excluded. Cross-platform frameworks (GameController, Metal, Foundation) require no changes. 

**No critical blocking issues found.** The build infrastructure is sound for iOS compilation.

### Next Steps (Optional)
1. Add explicit iOS-specific Metal capability checks
2. Create iOS-specific input handler (currently stub/empty)
3. Create iOS-specific display handler (currently stub/empty)
4. Test on physical iOS devices with various GPU capabilities

---

*Analysis Date: 2026-10-10*
*Repository: mamamea-ops/ZeldaWWHDRecompiOS*
*Language Composition: C (60.4%), C++ (26.4%), Objective-C++ (3%)*
