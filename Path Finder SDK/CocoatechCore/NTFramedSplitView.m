//
//  NTFramedSplitView.m
//  CocoatechCore
//
//  Created by Steve Gehrman on 4/28/08.
//  Copyright 2008 Cocoatech. All rights reserved.
//

#import "NTFramedSplitView.h"
#import "NTStandardColors.h"
#import "NSWindow-NTExtensions.h"

@implementation NTFramedSplitView

- (void)drawDividerInRect:(NSRect)rect;
{
	[super drawDividerInRect:rect];
	
	[[NTStandardColors frameColor:[[self window] dimControls]] set];
	
	NSRect line;
	
	line = rect;
	line.size.width = 1;
	[NSBezierPath fillRect:line];
	
	line = rect;
	line.origin.x = NSMaxX(line) - 1;
	line.size.width = 1;
	[NSBezierPath fillRect:line];
}

@end
