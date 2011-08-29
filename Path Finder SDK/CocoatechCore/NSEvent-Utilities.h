//
//  NSEvent-Utilities.h
//  CocoatechCore
//
//  Created by Steve Gehrman on Sat Jun 22 2002.
//  Copyright (c) 2002 CocoaTech. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSEvent (Utilities)

+ (BOOL)isMouseButtonDown;

// look at the state of the hardware
+ (BOOL)controlKeyDownNow;
+ (BOOL)optionKeyDownNow;
+ (BOOL)commandKeyDownNow;
+ (BOOL)shiftKeyDownNow;
+ (BOOL)spaceKeyDownNow;
+ (BOOL)capsLockDownNow;
+ (NSUInteger)carbonModifierFlagsToCocoaModifierFlags:(NSUInteger)aModifierFlags;
+ (NSUInteger)cocoaModifierFlagsToCarbonModifierFlags:(NSUInteger)aModifierFlags;

// a simple way of looking at the event modifier flags
- (BOOL)modifierIsDown;
- (BOOL)controlKeyDown;
- (BOOL)optionKeyDown;
- (BOOL)commandKeyDown;
- (BOOL)shiftKeyDown;

+ (NSString*)modifiersAsString:(NSUInteger)theModifiers;
- (NSString*)modifiersAsString;  // modifiers state for debugging

// option key or control key but not both
- (BOOL)optionXOrCommandKeyDown;
- (BOOL)openInNewWindowEvent;  // command key down

    // does not dequeue the mouseUp event
// pass nil for timeout to loop forever making sure that mouse is down so it doesn't endless loop
+ (BOOL)isDragEvent:(NSEvent *)event forView:(NSView*)view dragSlop:(float)dragSlop timeOut:(NSDate*)date;

// these examine clickCount%2 so the 3rd click becomes a single click and the 4th becomes another double click
// you have to do this if the user clicks 4 times expecting events 1,2,1,2 rather than 1,2,3,4
- (BOOL)isSingleClick;
- (BOOL)isDoubleClick;

- (BOOL)isArrowEvent;
- (BOOL)isLeftArrowEvent;
- (BOOL)isRightArrowEvent;
- (BOOL)isUpArrowEvent;
- (BOOL)isDownArrowEvent;

- (BOOL)isPageEvent;
- (BOOL)isHomeKeyEvent;
- (BOOL)isEndKeyEvent;
- (BOOL)isPageUpKeyEvent;
- (BOOL)isPageDownKeyEvent;

- (BOOL)isDeleteKeyEvent;
- (BOOL)isReturnKeyEvent;
- (BOOL)isEnterKeyEvent;
- (BOOL)isEscKeyEvent;
- (BOOL)isTabKeyEvent;
- (BOOL)isShiftTabKeyEvent;
- (BOOL)isFunctionKeyEvent;

- (BOOL)characterIsDown:(unichar)theCharacter;
- (unichar)characterDown;
@end

// ---------------------------------------------------------------------------------------------
// keyMap utils

void logKeyMap(KeyMapByteArray keyMap);
void keyMapAddKeyCode(KeyMapByteArray keymap, int keyCode);
void keyMapInvert(KeyMapByteArray keymap);
void keyMapInit(KeyMapByteArray keymap);
BOOL keyMapAND(KeyMapByteArray keymap, KeyMapByteArray keymap2);

#define kNSCommandKeyCode 55
#define kNSShiftKeyCode 56
#define kNSAlphaShiftCode 57
#define kNSAlternateKeyCode 58
#define kNSControlKeyCode 59
#define kNSFunctionKeyCode 63

