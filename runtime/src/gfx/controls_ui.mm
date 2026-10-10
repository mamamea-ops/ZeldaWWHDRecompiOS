// Input > Controls…: remap keyboard keys and controller inputs (input_map.h) on a drawing of the
// selected Wii U controller (GamePad or Pro Controller, as chosen in the Input menu).
//
// The drawing is an original, simplified schematic made in code (no artwork). Each button, d-pad
// direction and stick direction / click on it can be clicked: the window then waits for a key or a
// host-controller input and binds it (Esc cancels). Callouts on both sides show every binding (key,
// alternate key, controller); clicking one of those binds just that slot, right-click or its × clears
// it. Pressed inputs light up and sticks show their deflection, so the mapping can be tried out.
// Bindings used twice are drawn in orange. Changes apply at once and are saved to controls.json.
// While this window is the key window, input.mm's key monitor passes key events to it instead of the game.
//
// Debug: WWHD_SHOW_CONTROLS=1 opens the window at start (without the keyboard focus in test runs);
// WWHD_CONTROLS_SNAPSHOT=<prefix> then writes <prefix>_{gamepad,pro}_{light,dark}.png of the window
// after WWHD_CONTROLS_SNAPSHOT_AT seconds (default 3); WWHD_CONTROLS_HOVER=<input id, e.g. ZR> shows
// that input hovered. WWHD_CONTROLS_SELFTEST=1 drives the window with synthetic events.
#if TARGET_OS_OSX
#import <Cocoa/Cocoa.h>
#else
#import <UIKit/UIKit.h>
#endif
#import <GameController/GameController.h>
#include <Carbon/Carbon.h>  // kVK_* key codes

#include <algorithm>
#include <cmath>
#include <string>
#include <vector>
