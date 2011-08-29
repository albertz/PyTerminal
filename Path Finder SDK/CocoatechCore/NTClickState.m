//
//  NTClickState.m
//  CocoatechCore
//
//  Created by Steve Gehrman on Tue Aug 13 2002.
//  Copyright (c) 2002 CocoaTech. All rights reserved.
//

#import "NTClickState.h"
#import "NSEvent-Utilities.h"

@implementation NTClickState

- (id)initWithEvent:(NSEvent*)event;
{
    self = [super init];

    _handled = NO;
    _renameOnMouseUpIndex = -1;
    _event = [event retain];

    return self;
}

- (void)dealloc;
{
    [_event release];
    [super dealloc];
}

+ (NTClickState*)clickState:(NSEvent*)event;
{
    id result = [[NTClickState alloc] initWithEvent:event];

    return [result autorelease];
}

- (NSEvent*)event;
{
    return _event;
}

- (BOOL)isHandled;
{
    return _handled;
}

- (void)setHandled:(BOOL)set;
{
    _handled = set;
}

- (BOOL)isDoubleClick;
{
    return ([_event isDoubleClick]);
}

- (BOOL)isSingleClick;
{
    return ([_event isSingleClick]);
}

- (BOOL)isRightClick;
{
    return ([_event type] == NSRightMouseDown);
}

- (BOOL)isLeftClick;
{
    return ([_event type] == NSLeftMouseDown);
}

- (BOOL)isContextualMenuClick;  // either rightMouseDown, or leftMouseDown and controlKeyDown (no other keys should be down either)
{
    BOOL result = ([self isRightClick] || ([self isLeftClick] && [self controlKeyDown]));

    // make sure other keys aren't down
    if (result)
    {
        if ([self shiftKeyDown] || [self commandKeyDown] || [self optionKeyDown])
            result = NO;
    }

    return result;
}

- (NSPoint)mousePointForView:(NSView*)view;
{
    return [view convertPoint:[_event locationInWindow] fromView:nil];
}

- (NSPoint)mousePointInWindow;
{
    return [_event locationInWindow];
}

- (BOOL)anyModifierDown;
{
	return ([self shiftKeyDown] || [self controlKeyDown] || [self optionKeyDown] || [self commandKeyDown]);
}

- (BOOL)shiftKeyDown;
{
	return [_event shiftKeyDown];
}

- (BOOL)controlKeyDown;
{
	return [_event controlKeyDown];
}

- (BOOL)commandKeyDown;
{
	return [_event commandKeyDown];
}

- (BOOL)optionKeyDown;
{
	return [_event optionKeyDown];
}

- (BOOL)tryRenameOnMouseUp;
{
    return (_renameOnMouseUpIndex != -1);
}

- (void)setTryRenameOnMouseUpIndex:(NSInteger)index;
{
    _renameOnMouseUpIndex = index;
}

- (NSInteger)renameOnMouseUpIndex;
{
    return _renameOnMouseUpIndex;
}

@end
