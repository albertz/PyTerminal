//
//  NSView-CoreExtensions.m
//  CocoatechCore
//
//  Created by Steve Gehrman on 1/22/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "NSView-CoreExtensions.h"
#import "NSGraphicsContext-NTExtensions.h"
#import "NSWindow-NTExtensions.h"
#import "NSImage-NTExtensions.h"
#import "NSDrawer-NTExtensions.h"
#import "NSBezierPath-NTExtensions.h"
#import "NTImageMaker.h"
#import "NSEvent-Utilities.h"
#import "NSButton-NTExtensions.h"
#import "NTMetalWindowTheme.h"
#include <tgmath.h>

@implementation NSView (CoreExtensions)

- (void)drawFocusRing;
{
    SGS;
    NSBezierPath* rectPath = [NSBezierPath bezierPathWithRect:[self bounds]];
	
    [rectPath setLineWidth:.5];
	
    // keeps the rect inside the rect
    [NSBezierPath clipRect:[self visibleRect]];
	
    NSSetFocusRingStyle(NSFocusRingOnly);
    [rectPath stroke];
	
    RGS;
}

- (BOOL)mouseInRectNow;
{
	NSPoint mouse = [NSEvent mouseLocation];
	mouse = [[self window] convertScreenToBase:mouse];
	mouse = [self convertPoint:mouse fromView:nil];
	
	return (NSMouseInRect(mouse, [self bounds], [self isFlipped]));
}

- (NSScrollView*)findScrollView;
{
	NSScrollView *result=nil;
	
	for (NSView* view in [self subviews])
	{
		if ([view isKindOfClass:[NSScrollView class]])
			result = (NSScrollView*) view;
		else
			result = [view findScrollView];
		
		if (result)
			return result;
	}
	
	return nil;
}

- (NSView*)findKindOfEnclosingView:(Class)class;
{
	NSView *view=self;
	
	while (view = [view superview])
	{
		if ([view isKindOfClass:class])
			return view;
	}
	
	return nil;
}

- (NSView*)findKindOfSubview:(Class)class;
{
	NSEnumerator* enumerator;
	NSView* view;
	NSView* result=nil;
	
	enumerator = [[self subviews] objectEnumerator];
	while (!result && (view = [enumerator nextObject]))
	{
		if ([view isKindOfClass:class])
			result = view;
	}
	
	// not found? recursively search subviews
	if (!result)
	{
		enumerator = [[self subviews] objectEnumerator];
		while (!result && (view = [enumerator nextObject]))
			result = [view findKindOfSubview:class];
	}
	
	return result;	
}

- (void)drawWindowBackgroundInRect:(NSRect)theRect;
{
	BOOL handled = NO;
	
	// has bugs with layers
	if ([self layer])
	{
		NSColor* theColor = [self.window backgroundColor];
		NSImage* patternImage = [theColor patternImage];
		
		if (patternImage)
		{
			// is this our pattern image or one set by OS X?
			if ([self.window isThemeInstalled])
			{
				NSRect imageRect = [self convertRect:theRect toView:nil];
				
				imageRect.origin.y = 0;
				imageRect.size.height = [patternImage size].height;
				
				[patternImage drawInRect:[self convertRect:imageRect fromView:nil] fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0 respectFlipped:[self isFlipped] hints:nil];
				
				handled = YES;
			}
		}
	}
	
	if (!handled)
	{
		[[self.window backgroundColor] set];
		[NSBezierPath fillRect:theRect];	
	}
}

- (NSPoint)scrollPositionAsPercentage;
{
    NSRect bounds = [self bounds];
    NSScrollView *enclosingScrollView = [self enclosingScrollView];
    NSRect documentVisibleRect = [enclosingScrollView documentVisibleRect];
	
    NSPoint scrollPosition;
    
    // Vertical position
    if (NSHeight(documentVisibleRect) >= NSHeight(bounds)) {
        scrollPosition.y = 0.0f; // We're completely visible
    } else {
        scrollPosition.y = (NSMinY(documentVisibleRect) - NSMinY(bounds)) / (NSHeight(bounds) - NSHeight(documentVisibleRect));
        if (![self isFlipped])
            scrollPosition.y = 1.0f - scrollPosition.y;
        scrollPosition.y = MIN(MAX(scrollPosition.y, 0.0f), 1.0f);
    }
	
    // Horizontal position
    if (NSWidth(documentVisibleRect) >= NSWidth(bounds)) {
        scrollPosition.x = 0.0f; // We're completely visible
    } else {
        scrollPosition.x = (NSMinX(documentVisibleRect) - NSMinX(bounds)) / (NSWidth(bounds) - NSWidth(documentVisibleRect));
        scrollPosition.x = MIN(MAX(scrollPosition.x, 0.0f), 1.0f);
    }
	
    return scrollPosition;
}

- (void)setScrollPositionAsPercentage:(NSPoint)scrollPosition;
{
    NSRect bounds = [self bounds];
    NSScrollView *enclosingScrollView = [self enclosingScrollView];
    NSRect desiredRect = [enclosingScrollView documentVisibleRect];
	
    // Vertical position
    if (NSHeight(desiredRect) < NSHeight(bounds)) {
        scrollPosition.y = MIN(MAX(scrollPosition.y, 0.0f), 1.0f);
        if (![self isFlipped])
            scrollPosition.y = 1.0f - scrollPosition.y;
        desiredRect.origin.y = rint(NSMinY(bounds) + scrollPosition.y * (NSHeight(bounds) - NSHeight(desiredRect)));
        if (NSMinY(desiredRect) < NSMinY(bounds))
            desiredRect.origin.y = NSMinY(bounds);
        else if (NSMaxY(desiredRect) > NSMaxY(bounds))
            desiredRect.origin.y = NSMaxY(bounds) - NSHeight(desiredRect);
    }
	
    // Horizontal position
    if (NSWidth(desiredRect) < NSWidth(bounds)) {
        scrollPosition.x = MIN(MAX(scrollPosition.x, 0.0f), 1.0f);
        desiredRect.origin.x = rint(NSMinX(bounds) + scrollPosition.x * (NSWidth(bounds) - NSWidth(desiredRect)));
        if (NSMinX(desiredRect) < NSMinX(bounds))
            desiredRect.origin.x = NSMinX(bounds);
        else if (NSMaxX(desiredRect) > NSMaxX(bounds))
            desiredRect.origin.x = NSMaxX(bounds) - NSHeight(desiredRect);
    }
	
    [self scrollPoint:desiredRect.origin];
}

- (void)debugViews:(BOOL)showSubviews;
{
	NSLog(@"class: %@", NSStringFromClass([self class]));
	NSLog(@"frame: %@", NSStringFromRect([self frame]));
	NSLog(@"isOpaque: %@", [self isOpaque] ? @"YES" : @"NO");
	NSLog(@"hasLayer: %@", [self layer] ? @"YES" : @"NO");
	
	if (showSubviews)
	{
		NSLog(@"super: %@", NSStringFromClass([[self superview] class]));
		
		NSLog(@"subviews:");
		for (NSView *theView in [self subviews])
			[theView debugViews:showSubviews];
	}
	else
		[[self superview] debugViews:showSubviews];
}

- (NSArray*)subviewsWithClass:(Class)class;
{
	NSMutableArray* result = [NSMutableArray array];
	
	for (NSView* view in self.subviews)
	{
		if ([view isKindOfClass:class])
			[result addObject:view];
		
		NSArray* subResult = [view subviewsWithClass:class];
		
		[result addObjectsFromArray:subResult];
	}
	
	return result;
}

// used to fix antialiasing problems with layers and text
- (void)setBackgroundColorOnSubviews:(NSColor*)backColor;
{
	// convert textFields
	NSArray* theViews = [self subviewsWithClass:[NSTextField class]];
	for (NSTextField* textField in theViews)
	{
		if (![textField drawsBackground])
		{
			[textField setDrawsBackground:YES];
			[textField setBackgroundColor:backColor];
		}
	}
	
	// convert matrixes
	theViews = [self subviewsWithClass:[NSMatrix class]];
	for (NSMatrix* matrix in theViews)
	{
		if (![matrix drawsCellBackground])
		{
			[matrix setDrawsCellBackground:YES];
			[matrix setCellBackgroundColor:backColor];
		}
	}	
	
	// convert checkboxes
	theViews = [self subviewsWithClass:[NSButton class]];
	for (NSButton* button in theViews)
	{		
		if ([button isSwitchButton])
		{
			NSMutableAttributedString* attrString = [[[button attributedTitle] mutableCopy] autorelease];
			
			[attrString addAttribute:NSBackgroundColorAttributeName value:backColor range:NSMakeRange(0, [attrString length])];
			
			[button setAttributedTitle:attrString];
		}
	}	
}

// a variation on isVisible needed for module plugins
// isVisible checks the visibleRect, but what if the view is just scrolled out of view?
// we still want views scrolled offscreen to get updated
// this checks to see if it hidden, or has a superview that is 0 height or width (for splitViews)
- (BOOL)isHiddenOrCollapsed;
{	
	if ([self isHiddenOrHasHiddenAncestor])
		return YES;
	
	NSView* theView = self;
	NSRect theFrame;
	while (theView)
	{
		theFrame = [theView frame];
		if (NSHeight(theFrame) == 0 || NSWidth(theFrame) == 0)
			return YES;
		
		theView = [theView superview];
	}
	
	return NO;
}

- (BOOL)isVisible;
{
	if ([self isHiddenOrHasHiddenAncestor])
		return NO;
	
	if (NSIsEmptyRect([self visibleRect]))
		return NO;

	// no window, it's not visible to the user, not sure if this is needed.  safe to remove afaik
	if (![self window])
		return NO;
	
	return YES;
}

// calls [self window], if it gets a drawerWindow, it returns the parentWindow
- (NSWindow*)contentWindow;
{
	NSWindow* window = [self window];
	
	// is this a drawer window?
	NSWindow* drawersParentWindow = [window drawersParentWindow];
	
	if (drawersParentWindow)
		return drawersParentWindow;
	
	return window;
}

// returns the mouseUp event if we encounter one
- (NSEvent*)trackMouseDown:(NSEvent *)event dragSlop:(CGFloat)dragSlop;
{
    NSPoint eventLocation;
    NSRect slopRect;
    
    if ([event type] == NSLeftMouseDown)
	{
		eventLocation = [event locationInWindow];
		slopRect = NSInsetRect(NSMakeRect(eventLocation.x, eventLocation.y, 0.0, 0.0), -dragSlop, -dragSlop);
		
		for (;;)
		{
			NSEvent *nextEvent;
			
			nextEvent = [NSApp nextEventMatchingMask:NSLeftMouseDraggedMask | NSLeftMouseUpMask untilDate:[NSDate distantFuture] inMode:NSEventTrackingRunLoopMode dequeue:YES];
			
			if (nextEvent == nil)// Timeout date reached
				return nil;
			else if ([nextEvent type] == NSLeftMouseUp)
				return nextEvent;
			// if mouseDrag and we moved the mouse far enough for a drag, break out of loop
			else if ([nextEvent type] == NSLeftMouseDragged && !NSMouseInRect([nextEvent locationInWindow], slopRect, NO))
				return nil;
		}
	}
	
	return nil;
}

- (void)removeOneView:(NSView**)view;
{
	[*view removeFromSuperviewWithoutNeedingDisplay];
	[*view release];
	*view = nil;
}

- (void)resizeSubviewsToParentBounds;
{
	NSEnumerator* enumerator = [[self subviews] objectEnumerator];
	NSView* view;
	
	while (view = [enumerator nextObject])
	{
		[view setFrame:[self bounds]];
		[view resizeSubviewsToParentBounds];
	}
}

- (void)resizeSubviewsToParentSize;
{
	NSEnumerator* enumerator = [[self subviews] objectEnumerator];
	NSView* view;
	
	while (view = [enumerator nextObject])
	{
		[view setFrameSize:[self bounds].size];
		[view resizeSubviewsToParentBounds];
	}
}

// does not dequeue the mouseUp event
- (BOOL)isDragEvent:(NSEvent *)event dragSlop:(CGFloat)dragSlop;
{
    return [NSEvent isDragEvent:event forView:self dragSlop:dragSlop timeOut:nil]; // nil for timeout is what we need
}

- (void)removeAllSubviews;
{
    NSEnumerator* enumerator = [[self subviews] reverseObjectEnumerator];
    NSView* view;
    
    while (view = [enumerator nextObject])
        [view removeFromSuperviewWithoutNeedingDisplay];
}

- (BOOL)containsFirstResponder;
{
	NSView* view = (NSView*)[[self window] firstResponder];
	
	if ([view isKindOfClass:[NSView class]])
	{
		while (view)
		{
			if (view == self)
				return YES;
			
			view = [view superview];
		}
	}
	
	return NO;
}

- (BOOL)isFirstResponder;
{
    NSResponder* responder = [[self window] firstResponder];
    
    return (responder == self);
}

- (BOOL)isInitialFirstResponder;
{
    NSResponder* responder = [[self window] initialFirstResponder];
    
    return (responder == self);
}

- (void)eraseRect:(NSRect)rect;
{
	// this works, but I'm assuming CGContextClearRect is faster and optimized
	// [[NSColor clearColor] set];
	// NSRectFillUsingOperation(rect, NSCompositeCopy);
	
	CGContextClearRect([[NSGraphicsContext currentContext] graphicsPort], *(CGRect*)&rect);
}


// searches up through the super views looking for a view which responds to a selector, returns that view.
// usefull if you don't want to pass delegates all the way down a complex view heirarchy.
// a controlling parent view can handle the selectors and communication with a delegate
// also returns the windows delegate if that responds to the selector
- (id)parentWhichRespondsToSelector:(SEL)sel;
{
	NSView *view=self;
	
	while (view = [view superview])
	{
		if ([view respondsToSelector:sel])
			return view;
	}
	
	// got this far, check the windows delegate
	if ([[[view window] delegate] respondsToSelector:sel])
		return [[view window] delegate];
	
	return nil;
}

- (BOOL)isParentView:(NSView*)parent;
{
	NSView *view=self;
	
	while (view = [view superview])
	{
		if (view == parent)
			return YES;
	}	
	
	return NO;
}

- (NSImage *)viewImage:(NSRect)rect;
{
	if (NSEqualRects(NSZeroRect, rect))
		rect = [self bounds];
	
	NTImageMaker* result = [NTImageMaker maker:rect.size];
	
	[result lockFocus];
		
	[self displayRectIgnoringOpacity:rect inContext:[NSGraphicsContext currentContext]];
	return [result unlockFocus];
}

- (void)add:(BOOL)add subview:(NSView*)view
{
	if (add)
	{
		if (![view superview])
			[self addSubview:view];
	}
	else
	{
		if ([view superview])
			[view removeFromSuperviewWithoutNeedingDisplay];
	}
}

- (void)setNeedsDisplayForSubviews;
{
	[self setNeedsDisplay:YES];
	
	for (NSView* subview in self.subviews)
		[subview setNeedsDisplayForSubviews];
}

- (void)displayIfNeededForSubviews;
{
	[self displayIfNeeded];
	
	for (NSView* subview in self.subviews)
		[subview displayIfNeededForSubviews];	
}

+ (void)drawHighlightRing:(NSRect)theRect selected:(BOOL)theSelected;
{
	NSColor* frameColor = [NSColor colorWithCalibratedRed:.122 green:.361 blue:.812 alpha:1.0];
	if (theSelected)
		frameColor = [NSColor whiteColor];
	
	[[NSColor colorWithCalibratedRed:.1 green:.2 blue:1 alpha:.1] set];
	[NSBezierPath fillRoundRect:theRect radius:6 frameColor:frameColor frameWidth:4];
}

// superview must implement : - (void)drawBackgroundInSubview:(NSView*)theSubview inRect:(NSRect)theRect;
- (void)askParentToDrawBackground;
{
	NSView* parent = [self parentWhichRespondsToSelector:@selector(drawBackgroundInSubview:inRect:)];	
	if (parent)
	{
		SGS;
		[parent drawBackgroundInSubview:self inRect:[parent convertRect:[parent bounds] toView:self]];
		RGS;
	}
}

- (void)scrollToTop;
{
    [self setFraction:0.0];
}

- (void)scrollToEnd;
{
    [self setFraction:1.0];
}

- (void)scrollDownByPages:(CGFloat)pagesToScroll;
{
    CGFloat pageScrollAmount;
    
    pageScrollAmount = NSHeight([self visibleRect]) - [[self enclosingScrollView] verticalPageScroll];
    if (pageScrollAmount < 1.0)
        pageScrollAmount = 1.0;
    [self scrollDownByAdjustedPixels:pagesToScroll * pageScrollAmount];
}

- (void)scrollDownByLines:(CGFloat)linesToScroll;
{
    CGFloat lineScrollAmount;
    
    lineScrollAmount = [[self enclosingScrollView] verticalLineScroll];
    [self scrollDownByAdjustedPixels:linesToScroll * lineScrollAmount];
}

- (void)scrollDownByAdjustedPixels:(CGFloat)pixels;
{
    NSRect visibleRect;
	
    visibleRect = [self visibleRect];
    if ([self isFlipped])
        visibleRect.origin.y += pixels;
    else
        visibleRect.origin.y -= pixels;

    [self scrollPoint:[self adjustScroll:visibleRect].origin];
}

- (CGFloat)fraction;
{
    NSRect bounds, visibleRect;
    CGFloat fraction;
	
    bounds = [self bounds];
    visibleRect = [self visibleRect];
    if (NSHeight(visibleRect) >= NSHeight(bounds))
        return 0.0; // We're completely visible
    fraction = (NSMinY(visibleRect) - NSMinY(bounds)) / (NSHeight(bounds) - NSHeight(visibleRect));
    if (![self isFlipped])
        fraction = 1.0 - fraction;
    return MIN(MAX(fraction, 0.0), 1.0);
}

- (void)setFraction:(CGFloat)fraction;
{
    NSRect bounds, desiredRect;
	
    bounds = [self bounds];
    desiredRect = [self visibleRect];
    if (NSHeight(desiredRect) >= NSHeight(bounds))
        return; // We're entirely visible
	
    fraction = MIN(MAX(fraction, 0.0), 1.0);
    if (![self isFlipped])
        fraction = 1.0 - fraction;
    desiredRect.origin.y = NSMinY(bounds) + fraction * (NSHeight(bounds) - NSHeight(desiredRect));
    if (NSMinY(desiredRect) < NSMinY(bounds))
        desiredRect.origin.y = NSMinY(bounds);
    else if (NSMaxY(desiredRect) > NSMaxY(bounds))
        desiredRect.origin.y = NSMaxY(bounds) - NSHeight(desiredRect);
    [self scrollPoint:desiredRect.origin];
}


@end


