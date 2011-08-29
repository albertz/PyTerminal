/* -*- mode:objc -*- */
/* $Id: PTYWindow.m,v 1.13 2007/01/23 04:46:12 yfabian Exp $ */
/* Incorporated into iTerm.app by Ujwal S. Setlur */
/*
 **  PTYWindow.m
 **
 **  Copyright (c) 2002, 2003
 **
 **  Author: Fabian, Ujwal S. Setlur
 **	     Initial code by Kiichi Kusama
 **
 **  Project: iTerm
 **
 **  Description: NSWindow subclass. Implements transparency.
 **
 */

#import "PTYWindow.h"
#import "PreferencePanel.h"

@implementation PTYWindow

- (id)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag;
{	
    if ((self = [super initWithContentRect:contentRect
				 styleMask:aStyle
				   backing:bufferingType 
				     defer:flag]) != nil) 
    {
		[self setAlphaValue:0.9999];
	}
	
    return self;
}

- (BOOL)canBecomeKeyWindow
{
	return YES;
}

- (void)sendEvent:(NSEvent *)event
{
	if ([event type] == NSMouseEntered)
	{		
		if ([[PreferencePanel sharedInstance] focusFollowsMouse])
			[self makeKeyWindow];
	}
	
	[super sendEvent:event];
}

@end
