//
//  PSMOverflowPopUpButton.m
//  NetScrape
//
//  Created by John Pannell on 8/4/04.
//  Copyright 2004 Positive Spin Media. All rights reserved.
//

#import "PSMRolloverButton.h"

@interface PSMRolloverButton (Private)
- (BOOL)mouseOver;
- (void)setMouseOver:(BOOL)flag;
@end

@implementation PSMRolloverButton

- (void)dealloc 
{
    [_rolloverImage release];
	_rolloverImage = nil;
	
    [_usualImage release];
	_usualImage = nil;
	
	[self removeTrackingRect];
	
	[super dealloc];
}

- (void)drawRect:(NSRect)rect;
{
	if ([self mouseOver])
		[self setImage:_rolloverImage];
	else
		[self setImage:_usualImage];
	
	[super drawRect:rect];
}

// the regular image
- (void)setUsualImage:(NSImage *)newImage
{
    [newImage retain];
    [_usualImage release];
    _usualImage = newImage;
    [self setImage:_usualImage];
}

- (NSImage *)usualImage
{
    return _usualImage;
}

- (void)setRolloverImage:(NSImage *)newImage
{
    [newImage retain];
    [_rolloverImage release];
    _rolloverImage = newImage;
}

- (NSImage *)rolloverImage
{
    return _rolloverImage;
}

- (void)addTrackingRect
{
	[self setImage:_usualImage];

	NSPoint mouse = [NSEvent mouseLocation];
	mouse = [[self window] convertScreenToBase:mouse];
	mouse = [self convertPoint:mouse fromView:nil];
	
	BOOL mouseInsideNow = NSMouseInRect(mouse, [self bounds], [self isFlipped]);
	
	[self setMouseOver:mouseInsideNow];

    _myTrackingRectTag = [self addTrackingRect:[self bounds] owner:self userData:nil assumeInside:mouseInsideNow];
}

// SNG - tracking rects must be removed while still in the window, not after removed from subview
- (void)viewWillMoveToWindow:(NSWindow *)newWindow;
{
	if ([self window])
		[self removeTrackingRect];
}

- (void)removeTrackingRect
{
	if (_myTrackingRectTag) {
		[self removeTrackingRect:_myTrackingRectTag];
	}
	_myTrackingRectTag = 0;
}

// override for rollover effect
- (void)mouseEntered:(NSEvent *)theEvent;
{
    // set rollover image
	[self setMouseOver:YES];
    [self setNeedsDisplay:YES];
}

- (void)mouseExited:(NSEvent *)theEvent;
{
	[self setMouseOver:NO];
    [self setNeedsDisplay:YES];
}

- (void)resetCursorRects
{
    // called when the button rect has been changed
    [self removeTrackingRect];
    [self addTrackingRect];
}

@end

@implementation PSMRolloverButton (Private)

//---------------------------------------------------------- 
//  mouseOver 
//---------------------------------------------------------- 
- (BOOL)mouseOver
{
    return mMouseOver;
}

- (void)setMouseOver:(BOOL)flag
{
    mMouseOver = flag;
}

@end

