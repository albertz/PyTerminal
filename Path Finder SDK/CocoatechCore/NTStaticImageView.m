//
//  NTStaticImageView.m
//  CocoatechCore
//
//  Created by Steve Gehrman on 3/7/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "NTStaticImageView.h"
#import "NSWindow-NTExtensions.h"
#import "NSView-CoreExtensions.h"

@implementation NTStaticImageView

@synthesize cellBackgroundStyle;

+ (NTStaticImageView*)imageView:(NSBackgroundStyle)theBackGroundStyle;
{
	NTStaticImageView *result = [[NTStaticImageView alloc] initWithFrame:NSMakeRect(0,0,10, 10)];
	
	result.cellBackgroundStyle = theBackGroundStyle;
	[result unregisterDraggedTypes]; // avoids interference with drag and drop for superview

	[result setEditable:NO];
	[result setImageScaling:NSImageScaleNone];
	
	return [result autorelease];
}

- (NSView *)hitTest:(NSPoint)aPoint
{
	return nil;  // don't want mouseEvents, had to subclass to do this
}

- (void)drawRect:(NSRect)theRect;
{
	[self askParentToDrawBackground];
	
	if ([[self window] dimControls])
		[[self cell] setEnabled:NO];
	else
	{
		[[self cell] setEnabled:YES];
		
		[[self cell] setBackgroundStyle:self.cellBackgroundStyle];
	}
	
	[super drawRect:theRect];
}

@end
