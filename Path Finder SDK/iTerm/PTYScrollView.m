// -*- mode:objc -*-
// $Id: PTYScrollView.m,v 1.21 2006/12/21 02:52:41 yfabian Exp $
/*
 **  PTYScrollView.m
 **
 **  Copyright (c) 2002, 2003
 **
 **  Author: Fabian, Ujwal S. Setlur
 **	     Initial code by Kiichi Kusama
 **
 **  Project: iTerm
 **
 **  Description: NSScrollView subclass. Handles scroll detection and background images.
 **
 */

#import "PTYScrollView.h"
#import "PTYTextView.h"

@implementation PTYScroller

- (void)mouseDown: (NSEvent *)theEvent
{    
    [super mouseDown: theEvent];
    
    if ([self floatValue] != 1)
		userScroll=YES;
    else
		userScroll = NO;    
}

- (void)trackScrollButtons:(NSEvent *)theEvent
{
    [super trackScrollButtons:theEvent];
	
    if ([self floatValue] != 1)
		userScroll=YES;
    else
		userScroll = NO;
}

- (void)trackKnob:(NSEvent *)theEvent
{
    [super trackKnob:theEvent];
	
    if ([self floatValue] != 1)
		userScroll=YES;
    else
		userScroll = NO;
}

- (BOOL)userScroll
{
    return userScroll;
}

- (void)setUserScroll: (BOOL) scroll
{
    userScroll=scroll;
}

@end

@implementation PTYScrollView

- (id)initWithFrame:(NSRect)frame
{
	self = [super initWithFrame:frame];
		
    PTYScroller *aScroller = [[[PTYScroller alloc] init] autorelease];
	[self setVerticalScroller: aScroller];
	
    [[self verticalScroller] setControlSize:NSSmallControlSize];
    [[self horizontalScroller] setControlSize:NSSmallControlSize];
	
    return self;
}

- (void)scrollWheel:(NSEvent *)theEvent
{
    PTYScroller *verticalScroller = (PTYScroller *)[self verticalScroller];
	
    [super scrollWheel: theEvent];
	
    if ([verticalScroller floatValue] < 1.0)
		[verticalScroller setUserScroll: YES];
    else
		[verticalScroller setUserScroll: NO];
}

- (void)detectUserScroll
{
    PTYScroller *verticalScroller = (PTYScroller *)[self verticalScroller];
	    
    if ([verticalScroller floatValue] < 1.0)
		[verticalScroller setUserScroll: YES];
    else
		[verticalScroller setUserScroll: NO];
}

- (float)transparency
{
    return transparency;
}

- (void)setTransparency:(float)theTransparency
{
    if (theTransparency >= 0 && theTransparency <= 1)
    {
		transparency = theTransparency;
		[self setNeedsDisplay: YES];
    }
}

- (void)reflectScrolledClipView:(NSClipView *)aClipView
{
	[super reflectScrolledClipView: aClipView];
	[[self documentView] setForceUpdate: YES];
}

@end
