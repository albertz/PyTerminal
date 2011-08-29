//
//  NTAnimationsWindow.m
//  CocoatechCore
//
//  Created by Steve Gehrman on 12/28/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "NTAnimationsWindow.h"
#import "NTAnimationsZoomView.h"

static NSInteger kWindowSize = 400;

@implementation NTAnimationsWindow

@synthesize imageView;

+ (id)window;
{ 
	NTAnimationsWindow* result = [[NTAnimationsWindow alloc] initWithContentRect:NSMakeRect(0, 0, kWindowSize, kWindowSize) styleMask:NSBorderlessWindowMask
                              backing:NSBackingStoreBuffered defer:NO];
    
    [result setLevel:NSFloatingWindowLevel];
	[result setHidesOnDeactivate:NO];
    [result setOpaque:NO];
    [result setHasShadow:NO];
    [result setIgnoresMouseEvents:YES];
    [result setExcludedFromWindowsMenu:YES];
    [result setBackgroundColor:[NSColor clearColor]];
	
	[result setImageView:[NTAnimationsZoomView view:[[result contentView] bounds]]];
	[[result contentView] addSubview:[result imageView]];
	
    return [result autorelease];
}

- (void)zoomImage:(NSImage*)image atPoint:(NSPoint)point;
{   
	[self setFrameOrigin:NSMakePoint(point.x - (kWindowSize/2), point.y - (kWindowSize/2))];

	[self.imageView setImage:image];
	[self.imageView animate];
}

//---------------------------------------------------------- 
// dealloc
//---------------------------------------------------------- 
- (void)dealloc
{
    self.imageView = nil;
    [super dealloc];
}

@end

