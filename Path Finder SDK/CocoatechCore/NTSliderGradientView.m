//
//  NTSliderGradientView.m
//  CocoatechCore
//
//  Created by Steve Gehrman on 5/14/08.
//  Copyright 2008 Cocoatech. All rights reserved.
//

#import "NTSliderGradientView.h"
#import "NTGradientDraw.h"

@implementation NTSliderGradientView

- (void)drawRect:(NSRect)rect;
{
	[[NTGradientDraw sharedHeaderGradient:NO] drawInRect:[self bounds] horizontal:YES flipped:NO];
	
	[[NSColor darkGrayColor] set];
	NSRect frameRect = NSInsetRect([self bounds], -2, 0);
	frameRect.size.height += .5;
	NSFrameRect(frameRect);
}

@end

