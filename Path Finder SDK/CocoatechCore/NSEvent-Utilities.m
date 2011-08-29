//
//  NSEvent-Utilities.m
//  CocoatechCore
//
//  Created by Steve Gehrman on Sat Jun 22 2002.
//  Copyright (c) 2002 CocoaTech. All rights reserved.
//

#import "NSEvent-Utilities.h"
#import <Carbon/Carbon.h>

@implementation NSEvent (Utilities)

+ (BOOL)isMouseButtonDown;
{
	NSUInteger leftMouse = (1 << 0);
	return (([NSEvent pressedMouseButtons] & leftMouse) == leftMouse);  // left mouse button
}

+ (BOOL)controlKeyDownNow
{
	return (([NSEvent modifierFlags] & NSControlKeyMask) == NSControlKeyMask);
}

+ (BOOL)optionKeyDownNow
{
	return (([NSEvent modifierFlags] & NSAlternateKeyMask) == NSAlternateKeyMask);
}

+ (BOOL)commandKeyDownNow
{
	return (([NSEvent modifierFlags] & NSCommandKeyMask) == NSCommandKeyMask);
}

+ (BOOL)shiftKeyDownNow
{
	return (([NSEvent modifierFlags] & NSShiftKeyMask) == NSShiftKeyMask);
}

+ (BOOL)capsLockDownNow
{
	return (([NSEvent modifierFlags] & NSAlphaShiftKeyMask) == NSAlphaShiftKeyMask);
}

+ (NSUInteger)carbonModifierFlagsToCocoaModifierFlags:(NSUInteger)aModifierFlags;
{
	NSUInteger theCocoaModifierFlags = 0;
	
	if (aModifierFlags & shiftKey)
		theCocoaModifierFlags |= NSShiftKeyMask;
	if (aModifierFlags & controlKey)
		theCocoaModifierFlags |= NSControlKeyMask;
	if (aModifierFlags & optionKey)
		theCocoaModifierFlags |= NSAlternateKeyMask;
	if (aModifierFlags & cmdKey)
		theCocoaModifierFlags |= NSCommandKeyMask;
	if (aModifierFlags & kEventKeyModifierFnMask)
		theCocoaModifierFlags |= NSFunctionKeyMask;
	
	return theCocoaModifierFlags;
}

+ (NSUInteger)cocoaModifierFlagsToCarbonModifierFlags:(NSUInteger)aModifierFlags;
{
	NSUInteger theCarbonModifierFlags = 0;
	
	if (aModifierFlags & NSShiftKeyMask)
		theCarbonModifierFlags |= shiftKey;
	if (aModifierFlags & NSControlKeyMask)
		theCarbonModifierFlags |= controlKey;
	if (aModifierFlags & NSAlternateKeyMask)
		theCarbonModifierFlags |= optionKey;
	if (aModifierFlags & NSCommandKeyMask)
		theCarbonModifierFlags |= cmdKey;
	if (aModifierFlags & NSFunctionKeyMask)
		theCarbonModifierFlags |= kEventKeyModifierFnMask;
	
	return theCarbonModifierFlags;
}

+ (BOOL)spaceKeyDownNow;
{
	KeyMapByteArray map;						// this is the endian-safe way to use GetKeys
    GetKeys(*((KeyMap*) &map));
    
    return (map[6] & 0x2);		// virtual key code for space bar is 49
}

- (BOOL)modifierIsDown;
{
	if ([self controlKeyDown] || [self shiftKeyDown] || [self commandKeyDown] || [self optionKeyDown])
		return YES;
	
	return NO;
}

#define MODIFIER_SET(flags, mask) ((flags & mask) != 0)

+ (NSString*)modifiersAsString:(NSUInteger)theModifiers;
{
	return [NSString stringWithFormat:@"control:%@, shift:%@, command:%@, option:%@", 
			(MODIFIER_SET(theModifiers, NSControlKeyMask))?@"YES":@"NO",
			(MODIFIER_SET(theModifiers, NSShiftKeyMask))?@"YES":@"NO",
			(MODIFIER_SET(theModifiers, NSCommandKeyMask))?@"YES":@"NO",
			(MODIFIER_SET(theModifiers, NSAlternateKeyMask))?@"YES":@"NO"];
}

- (NSString*)modifiersAsString;  // modifiers state for debugging
{
	return [NSEvent modifiersAsString:[self modifierFlags]];
}

// a simple way of looking at the event modifier flags
- (BOOL)controlKeyDown;
{
    return MODIFIER_SET([self modifierFlags], NSControlKeyMask);
}

- (BOOL)optionKeyDown;
{
    return MODIFIER_SET([self modifierFlags], NSAlternateKeyMask);
}

- (BOOL)commandKeyDown;
{
	return MODIFIER_SET([self modifierFlags], NSCommandKeyMask);
}

- (BOOL)shiftKeyDown;
{
	return MODIFIER_SET([self modifierFlags], NSShiftKeyMask);
}

- (BOOL)optionXOrCommandKeyDown;
{
    if ([self optionKeyDown])
        return ![self commandKeyDown];
    else if ([self commandKeyDown])
        return ![self optionKeyDown];
    
    return NO;
}

// this identifies and event that would signal opening a new window
- (BOOL)openInNewWindowEvent;
{
    BOOL result = [self commandKeyDown];

    // is this a menuCmd?  what about function keys?
    if (result && [self type] == NSKeyDown)
		result = NO;
    
    return result;
}

// does not dequeue the mouseUp event
+ (BOOL)isDragEvent:(NSEvent *)event forView:(NSView*)view dragSlop:(float)dragSlop timeOut:(NSDate*)timeOut;
{    
	// check on mouseDown only
    if ([event type] == NSLeftMouseDown)
	{
		NSPoint eventLocation;
		NSRect slopRect;
		
		eventLocation = [event locationInWindow];
		slopRect = NSInsetRect(NSMakeRect(eventLocation.x, eventLocation.y, 0.0, 0.0), -dragSlop, -dragSlop);
		
		while (YES)
		{
			NSEvent *nextEvent;
			
			NSDate *date = timeOut;
			if (!date)
				date = [NSDate dateWithTimeIntervalSinceNow:2]; // 2 second timeout so we can verify the mouse is still phsyically down - the mouseUp could have been eaten by a wacom tablet or other hack or bug
			
			nextEvent = [NSApp nextEventMatchingMask:NSLeftMouseDraggedMask | NSLeftMouseUpMask untilDate:date inMode:NSEventTrackingRunLoopMode dequeue:NO];
			
			if (nextEvent == nil)// Timeout date reached
			{
				// only return if a time out was set by the caller
				if (timeOut)
					return NO;
				else
				{
					// to avoid endless loop, check if the mouse is still down
					if (![NSEvent isMouseButtonDown])
						return NO;
				}
			}
			else if ([nextEvent type] == NSLeftMouseUp)
				return NO;
			else if ([nextEvent type] == NSLeftMouseDragged) // if mouseDrag and we moved the mouse far enough for a drag, break out of loop
			{
				// take the dragged event off the queue
				[NSApp nextEventMatchingMask:NSLeftMouseDraggedMask untilDate:[NSDate distantPast] inMode:NSEventTrackingRunLoopMode dequeue:YES];
				
				if (!NSMouseInRect([nextEvent locationInWindow], slopRect, [view isFlipped]))
					return YES;
			}
		}
    }
	
    return NO;
}

// these examine clickCount%2 so the 3rd click becomes a single click and the 4th becomes another double click
// you have to do this if the user clicks 4 times expecting events 1,2,1,2 rather than 1,2,3,4
- (BOOL)isSingleClick;
{
	int cnt = [self clickCount];

	return ((cnt % 2) == 1);
}

- (BOOL)isDoubleClick;
{
	int cnt = [self clickCount];
	
	return (cnt && ((cnt % 2) == 0));
}

- (BOOL)isRightArrowEvent;
{
	return [self characterIsDown:NSRightArrowFunctionKey];
}

- (BOOL)isArrowEvent;
{
	return ([self isLeftArrowEvent] ||
			[self isRightArrowEvent] ||
			[self isUpArrowEvent] ||
			[self isDownArrowEvent]
			);
}

- (BOOL)isLeftArrowEvent;
{
	return [self characterIsDown:NSLeftArrowFunctionKey];
}

- (BOOL)isUpArrowEvent;
{
	return [self characterIsDown:NSUpArrowFunctionKey];
}

- (BOOL)isDownArrowEvent;
{
	return [self characterIsDown:NSDownArrowFunctionKey];
}

- (BOOL)characterIsDown:(unichar)theCharacter;
{
	// characters causes exception on non key events
	unichar character = [self characterDown];
	if (character == theCharacter)
		return YES;
	
	return NO;	
}

- (unichar)characterDown;
{
	// characters causes exception on non key events
	if ([self type] == NSKeyDown || [self type] == NSKeyUp)
	{
		NSString* characters = [self characters];
		if ([characters length])
			return [characters characterAtIndex:0];
	}
	
	return 0;	
}

- (BOOL)isPageEvent;
{
	return ([self isHomeKeyEvent] ||
			[self isEndKeyEvent] ||
			[self isPageUpKeyEvent] ||
			[self isPageDownKeyEvent]
			);
}

- (BOOL)isHomeKeyEvent;
{
	return [self characterIsDown:NSHomeFunctionKey];
}

- (BOOL)isEndKeyEvent;
{
	return [self characterIsDown:NSEndFunctionKey];
}

- (BOOL)isPageUpKeyEvent;
{
	return [self characterIsDown:NSPageUpFunctionKey];
}

- (BOOL)isPageDownKeyEvent;
{
	return [self characterIsDown:NSPageDownFunctionKey];
}

- (BOOL)isDeleteKeyEvent;
{
	return [self characterIsDown:NSDeleteCharacter];
}

- (BOOL)isReturnKeyEvent;
{
	return [self characterIsDown:NSCarriageReturnCharacter];
}

- (BOOL)isEnterKeyEvent;
{
	return [self characterIsDown:NSEnterCharacter];
}

- (BOOL)isEscKeyEvent;
{
	return [self characterIsDown:0x001B];
}

- (BOOL)isTabKeyEvent;
{
	return [self characterIsDown:NSTabCharacter];
}

- (BOOL)isShiftTabKeyEvent;
{
	return [self characterIsDown:NSBackTabCharacter];
}

- (BOOL)isFunctionKeyEvent;
{
	unichar character = [self characterDown];
	if (character == NSF1FunctionKey ||
		character == NSF2FunctionKey ||
		character == NSF3FunctionKey ||
		character == NSF4FunctionKey ||
		character == NSF5FunctionKey ||
		character == NSF6FunctionKey ||
		character == NSF7FunctionKey ||
		character == NSF8FunctionKey ||
		character == NSF9FunctionKey ||
		character == NSF10FunctionKey ||
		character == NSF11FunctionKey ||
		character == NSF12FunctionKey ||
		character == NSF13FunctionKey ||
		character == NSF14FunctionKey ||
		character == NSF15FunctionKey
		)
	{
		return YES;
	}
    
    return NO;
}

@end

// ---------------------------------------------------------------------------------------------
// ---------------------------------------------------------------------------------------------
// keyMap utils

void logKeyMap(KeyMapByteArray keymap) 
{
	NSMutableString *string = [NSMutableString string];
	int i;
	for (i = 0; i<sizeof(KeyMapByteArray); i++)
		[string appendFormat:@" %02hhX", keymap[i]];
	
	NSLog(@"KeyMap %@", string);
}

void keyMapAddKeyCode(KeyMapByteArray keymap, int keyCode) 
{
	int half = sizeof(KeyMapByteArray) / 2;
	
	int i = keyCode / half;
	int j = keyCode % half;
	
	keymap[i] = keymap[i] | 1 << j;
}

void keyMapInvert(KeyMapByteArray keymap) 
{
	int i;
	for (i = 0; i<sizeof(KeyMapByteArray); i++)
		keymap[i] = ~keymap[i];
}

void keyMapInit(KeyMapByteArray keymap)
{
    int i;
	for (i = 0; i<sizeof(KeyMapByteArray); i++) 
		keymap[i] = 0;
}

BOOL keyMapAND(KeyMapByteArray keymap, KeyMapByteArray keymap2)
{
	int i;
	for (i = 0; i<sizeof(KeyMapByteArray); i++)
	{
		if (keymap[i] & keymap2[i])
			return YES;
	}
	
	return NO;
}
