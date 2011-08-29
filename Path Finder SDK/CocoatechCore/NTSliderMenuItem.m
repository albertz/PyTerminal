//
//  NTSliderMenuItem.m
//  CocoatechCore
//
//  Created by Steve Gehrman on 5/14/08.
//  Copyright 2008 Cocoatech. All rights reserved.
//

#import "NTSliderMenuItem.h"
#import "NTMenuSlider.h"
#import "NTSliderGradientView.h"
#import "NTImageMaker.h"

#define kSliderViewHeight 25

@interface NTSliderMenuItem (Private)
+ (NSImage*)magnificationImage:(BOOL)small;

- (void)registerKeyPath;
- (void)unregisterKeyPath;	
@end

@implementation NTSliderMenuItem

@synthesize model, slider, sliderView;

- (void)dealloc;
{
	[self unregisterKeyPath];
	self.model = nil;
	self.slider = nil;
	self.sliderView = nil;
	
	[super dealloc];
}

+ (NTSliderMenuItem*)menuItem:(id)theModel;
{
	NTSliderMenuItem *result = [[NTSliderMenuItem alloc] initWithTitle:@"" action:0 keyEquivalent:@""];
	
	result.model = theModel;
	
	result.slider = [[[NTMenuSlider alloc] initWithFrame:NSMakeRect(0, 0, 20, 20)] autorelease];
	[[result.slider cell] setControlSize:NSSmallControlSize];
	[result.slider setMinValue:-1];
	[result.slider setMaxValue:1];
		
	result.sliderView = [[[NTSliderGradientView alloc] initWithFrame:NSMakeRect(0, 0, 320, kSliderViewHeight)] autorelease];
	
	// two image views to show small to large
	NSImageView* small, *large;
	
	small = [[[NSImageView alloc] initWithFrame:NSZeroRect] autorelease];
	large = [[[NSImageView alloc] initWithFrame:NSZeroRect] autorelease];
	[[small cell] setBackgroundStyle:NSBackgroundStyleRaised];
	[[large cell] setBackgroundStyle:NSBackgroundStyleRaised];
	
	[small setImageScaling:NSImageScaleProportionallyDown];
	[large setImageScaling:NSImageScaleProportionallyDown];
	
	[small setImage:[NTSliderMenuItem magnificationImage:YES]];
	[large setImage:[NTSliderMenuItem magnificationImage:NO]];
	
	[small setFrame:NSMakeRect(0, 0, kSliderViewHeight, kSliderViewHeight)];
	[large setFrame:NSMakeRect(290, 0, kSliderViewHeight, kSliderViewHeight)];
	
	[[result slider] setFrame:NSMakeRect(kSliderViewHeight, 0, 260, kSliderViewHeight)];
	
	[result.sliderView addSubview:[result slider]];
	[result.sliderView addSubview:small];
	[result.sliderView addSubview:large];
	
	[result setView:result.sliderView];
	
	[result registerKeyPath];

	return [result autorelease];
}

@end

@implementation NTSliderMenuItem (Private)

- (void)registerKeyPath;
{
	if ([self model])
		[[self slider] bind:@"value" toObject:[self model] withKeyPath:@"sliderValue" options:nil];
}

- (void)unregisterKeyPath;
{
	[[self slider] unbind:@"value"];
}

+ (NSImage*)magnificationImage:(BOOL)small;
{
	NSRect imageRect = NSMakeRect(0, 0, 20, 20);
	NTImageMaker* imageMaker = [NTImageMaker maker:NSMakeSize(20, 20)];
	NSImage* image = [NSImage imageNamed:NSImageNameUser];
	NSRect drawRect = NSInsetRect(imageRect, 1, 1);
	
	if (small)
		drawRect = NSInsetRect(imageRect, 4, 4);
	
	[imageMaker lockFocus];
	{
		[image drawInRect:drawRect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1];
		
		[[NSColor darkGrayColor] set];
		NSFrameRect(drawRect);
	}
	
	return [imageMaker unlockFocus:YES];
}


@end



