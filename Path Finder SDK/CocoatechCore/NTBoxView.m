//
//  NTBoxView.m
//  CocoatechCore
//
//  Created by Steve Gehrman on Sat May 17 2003.
//  Copyright (c) 2003 CocoaTech. All rights reserved.
//

#import "NTBoxView.h"
#import "NTStandardColors.h"
#import "NSWindow-NTExtensions.h"
#import "NSView-CoreExtensions.h"

@interface NTBoxView (Private)
@end

@implementation NTBoxView

- (id)initWithFrame:(NSRect)frame;
{
    self = [super initWithFrame:frame];
        		
	[self setAutomaticallyResizeSubviewToFit:YES];

	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(windowStateChangedNotification:)
												 name:NSWindowDidResignMainNotification
											   object:nil];        
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(windowStateChangedNotification:)
												 name:NSWindowDidBecomeMainNotification
											   object:nil];        
	
    return self;
}

- (void)dealloc;
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[super dealloc];
}

//---------------------------------------------------------- 
//  frameType 
//---------------------------------------------------------- 
- (NTFrameType)frameType
{
    return mv_frameType;
}

- (void)setFrameType:(NTFrameType)theFrameType
{
    mv_frameType = theFrameType;
}

- (NSRect)contentBounds;
{
	NSRect result = [self bounds];
	NTFrameType frameType = [self frameType];

	if (frameType)
	{
		if (frameType == NTFrame_all)
			result = NSInsetRect(result, 1, 1);
		else
		{
			if ((frameType & NTFrame_left) != 0)
			{
				result.origin.x += 1;
				result.size.width -= 1;
			}
			if ((frameType & NTFrame_right) != 0)
				result.size.width -= 1;
			if ((frameType & NTFrame_top) != 0)
			{
				result.size.height -= 1;
				
				if ([self isFlipped])
					result.origin.y += 1;					
			}
			if ((frameType & NTFrame_bottom) != 0)
			{
				result.size.height -= 1;
				
				if (![self isFlipped])
					result.origin.y += 1;				
			}
		}
	}
	
	return result;
}

- (void)drawRect:(NSRect)rect;
{
	[super drawRect:rect];

	[NTBoxView drawWithFrameType:[self frameType] inRect:[self bounds] inView:self];
}

+ (void)drawWithFrameType:(NTFrameType)frameType inRect:(NSRect)rect inView:(NSView*)inView;
{
	if (frameType)
	{
		NSRect result = rect;
		
		if (frameType == NTFrame_all)
			;
		else
		{
			if ((frameType & NTFrame_left) == 0)
			{
				result.origin.x -= 1;
				result.size.width += 1;
			}
			if ((frameType & NTFrame_right) == 0)
				result.size.width += 1;
			if ((frameType & NTFrame_top) == 0)
			{
				result.size.height += 1;
				
				if ([inView isFlipped])
					result.origin.y -= 1;					
			}
			if ((frameType & NTFrame_bottom) == 0)
			{
				result.size.height += 1;
				
				if (![inView isFlipped])
					result.origin.y -= 1;				
			}
		}
				
		[[NTStandardColors frameColor:[[inView window] dimControls]] set];
		
		NSFrameRectWithWidth(result, 1);
	}
}

@end

@implementation NTBoxView (Private)

- (void)windowStateChangedNotification:(NSNotification*)notification;
{
	// make sure the window is our window
	if ([notification object] == [self contentWindow]) 
		[self setNeedsDisplay:YES];
}

@end

