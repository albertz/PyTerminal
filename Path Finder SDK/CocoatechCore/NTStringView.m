//
//  NTStringView.m
//  CocoatechCore
//
//  Created by Steve Gehrman on 3/3/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "NTStringView.h"
#import "NSWindow-NTExtensions.h"
#import "NSView-CoreExtensions.h"

@implementation NTStringView

@synthesize cellBackgroundStyle, cachedMinSizeToFit;

+ (NTStringView*)stringView:(NSBackgroundStyle)theBackGroundStyle;
{
	NTStringView *result = [[NTStringView alloc] initWithFrame:NSMakeRect(0,0,10, 10)];
	
	result.cellBackgroundStyle = theBackGroundStyle;
	
	return [result autorelease];
}

- (id)initWithFrame:(NSRect)frame;
{
	self = [super initWithFrame:frame];
	
	[self setEditable:NO];
	[self setSelectable:NO];
	[self setDrawsBackground:NO];
	[self setBackgroundColor:nil];
	[self setBordered:NO];
	[self setBezeled:NO];
	[[self cell] setLineBreakMode:NSLineBreakByTruncatingMiddle];

	return self;
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

- (void)setAttributedStringValue:(NSAttributedString *)obj;
{
	[super setAttributedStringValue:obj];
	
	self.cachedMinSizeToFit = NSZeroSize;
}

- (void)setObjectValue:(id<NSCopying>)obj;
{
	[super setObjectValue:obj];
	
	self.cachedMinSizeToFit = NSZeroSize;
}

- (void)setStringValue:(NSString *)aString;
{
	if (!aString)
		aString = @"";  // avoids exceptions
	
	[super setStringValue:aString];
	
	self.cachedMinSizeToFit = NSZeroSize;
}

- (void)setFont:(NSFont *)theFont;
{
	[super setFont:theFont];
	
	self.cachedMinSizeToFit = NSZeroSize;
}

- (NSSize)minSizeToFit;
{
	if (NSEqualSizes(self.cachedMinSizeToFit, NSZeroSize))
	{
		NSSize minSize = [[self attributedStringValue] size];
		
		minSize.width += 6;  // not sure why needed
		
		self.cachedMinSizeToFit = minSize;
	}
	
	return self.cachedMinSizeToFit;
}

@end
