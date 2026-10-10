// Display: the TV and GamePad windows, full screen, and the final composition of the TV and GamePad
// images onto the screen (scale to fit with letterbox/pillarbox, scaling filter, GamePad screen as a
// separate window or as a picture-in-picture overlay inside the TV window).
//
// Everything here only decides how the finished scan-out images (R.tv.tex, R.drc.tex, any size and
// aspect) are put on the screen; what the game renders is decided elsewhere.
//
// Both renderers use these windows (renderer.h): Metal draws the composition below; Vulkan
// (gfx/vulkan, MoltenVK) gets each view's CAMetalLayer for a VK_EXT_metal_surface swapchain and asks
// display_plan() for the same layout (picture rectangles, GamePad overlay, scaling filter).
//
// Shortcuts: Cmd+F (or Ctrl+Cmd+F, or the green button) full screen; Cmd+G show/hide the GamePad screen.
// Closing the TV window (close button, Cmd+W) quits the app, asking first while a game is in progress
// (quit_prompt.mm); closing the GamePad window only hides it.
// The Display menu holds the rest. Choices are kept in ~/Library/Application Support/wwhd/display.plist
// (test runs with WWHD_NO_HOST_INPUT neither read nor write it unless WWHD_DISPLAY_SETTINGS names a file).
//
// The modes, the layout of the TV window, the automatic overlay and the overlay's touch mapping are
// shared with the SDL host (display_modes.cpp, which lists their test variables: WWHD_DRC_MODE,
// WWHD_DRC_PIP, WWHD_SCALE_FILTER, WWHD_SIM_SCREEN, WWHD_TEST_TOUCH, WWHD_DRC_AUTO, WWHD_DRC_AUTO_LOG).
//
// Debug / test environment:
//   WWHD_FULLSCREEN=0|1                  TV window starts windowed / in full screen instead of as it was left
//                                        (that session's full screen is not saved; 1 takes over the screen!)
//   WWHD_DUMP_PRESENT=1                  with WWHD_DUMP_FRAMES: also write frame_<n>_present.png (the composed
//                                        TV window) and frame_<n>_present_drc.png (GamePad window, window mode)
//   WWHD_TEST_DRC_KEY=3500,3700          frames at which Cmd+G (show/hide GamePad screen) is simulated
//   WWHD_HIDDEN_WINDOWS=1                test runs: the windows are never put on screen (nothing pops up;
//                                        frame / present dumps still work, the drawables are not presented)
#if TARGET_OS_OSX
#import <AppKit/AppKit.h>
#else
#import <UIKit/UIKit.h>
#endif
#import <QuartzCore/QuartzCore.h>
