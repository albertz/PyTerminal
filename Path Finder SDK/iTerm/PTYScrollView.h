// -*- mode:objc -*-
// $Id: PTYScrollView.h,v 1.6 2004/03/14 06:05:38 ujwal Exp $
/*
 **  PTYScrollView.h
 **
 **  Copyright (c) 2002, 2003
 **
 **  Author: Fabian, Ujwal S. Setlur
 **	     Initial code by Kiichi Kusama
 **
 **  Project: iTerm
 **
 **  Description: NSScrollView subclass. Currently does not do anything special.
 **
 */

#import <Cocoa/Cocoa.h>

@interface PTYScroller : NSScroller
{
    BOOL userScroll;
}

- (void)mouseDown: (NSEvent *)theEvent;
- (void)trackScrollButtons:(NSEvent *)theEvent;
- (void)trackKnob:(NSEvent *)theEvent;
- (BOOL)userScroll;
- (void)setUserScroll: (BOOL) scroll;

@end

@interface PTYScrollView : NSScrollView
{
	float transparency;
}

- (void)scrollWheel:(NSEvent *)theEvent;
- (void)detectUserScroll;

// background image
- (float) transparency;
- (void)setTransparency: (float) theTransparency;

@end
