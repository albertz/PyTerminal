//
//  NTMenuSlider.m
//  CocoatechCore
//
//  Created by Steve Gehrman on 5/14/08.
//  Copyright 2008 Cocoatech. All rights reserved.
//

#import "NTMenuSlider.h"

@implementation NTMenuSlider

- (void)mouseDown:(NSEvent*)event
{
	[super mouseDown:event];
	
	// on mouse up, we want to dismiss the menu being tracked
	NSMenu* menu = [[self enclosingMenuItem] menu];
	[menu cancelTracking];
}

@end
