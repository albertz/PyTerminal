//
//  NSWindow-NTExtensions.h
//  CocoatechCore
//
//  Created by Steve Gehrman on Fri Jan 16 2004.
//  Copyright (c) 2004 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kNTSetDefaultFirstResponderNotification @"NTSetDefaultFirstResponderNotification"  // object is the window, must check

@interface NSWindow (Utilities)

+ (void)cascadeWindow:(NSWindow*)inWindow;

+ (NSArray*)visibleWindows:(BOOL)ordered;
+ (NSArray*)visibleWindows:(BOOL)ordered delegateClass:(Class)delegateClass;

- (NSWindow*)topWindowWithDelegateClass:(Class)class;

+ (BOOL)isAnyWindowVisible;
+ (BOOL)isAnyWindowVisibleWithDelegateClass:(Class)class;
+ (NSArray*)miniaturizedWindows;

- (void)setFloating:(BOOL)set;
- (BOOL)isFloating;

- (BOOL)isMetallic;
- (BOOL)isBorderless;

// returns parentWindow if an NSDrawerWindow, returns self if not a drawerWindow
- (NSWindow*)parentWindowIfDrawerWindow;

- (BOOL)dimControls;
- (BOOL)dimControlsKey;
- (BOOL)keyWindowIsMenu;

- (void)flushActiveTextFields;

- (NSRect)setContentViewAndResizeWindow:(NSView*)view display:(BOOL)display;
- (NSRect)resizeWindowToContentSize:(NSSize)contentSize display:(BOOL)display;
- (NSRect)windowFrameForContentSize:(NSSize)contentSize;

+ (BOOL)windowRectIsOnScreen:(NSRect)windowRect;

- (void)setDefaultFirstResponder;

// windowNumber returns -1 when app is hidden, use this instead.  returns pointer value
- (NSNumber*)windowIdentifier;

// replaces [NSApp windowWithWindowNumber:]
+ (NSWindow*)windowWithIdentifier:(NSNumber*)theWindowID;
@end

@interface NSWindow (UndocumentedRoutines)
- (void)setBottomCornerRounded:(BOOL)set;
- (BOOL)bottomCornerRounded;
@end

#define NSBorderlessWindowMaskSet(bitMask) (bitMask == 0)  // NSBorderlessWindowMask == 0
#define NSTexturedBackgroundWindowMaskSet(bitMask) ((bitMask & NSTexturedBackgroundWindowMask) != 0)

