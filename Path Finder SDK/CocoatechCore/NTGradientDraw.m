//
//  NTGradientDraw.m
//  CocoatechCore
//
//  Created by Steve Gehrman on 4/12/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "NTGradientDraw.h"
#import "NSGraphicsContext-NTExtensions.h"
#import "NTImageMaker.h"
#import "NSImage-NTExtensions.h"
#import "NTUtilities.h"

@implementation NTGradientDraw

@synthesize gradient;

+ (NTGradientDraw*)gradientWithStartColor:(NSColor*)startingColor
								 endColor:(NSColor*)endingColor
{
	NTGradientDraw *result = [[NTGradientDraw alloc] init];
	
	[result setGradient:[[[NSGradient alloc] initWithStartingColor:startingColor endingColor:endingColor] autorelease]];
						 
	return [result autorelease];
}

//---------------------------------------------------------- 
// dealloc
//---------------------------------------------------------- 
- (void)dealloc
{
    self.gradient = nil;
	
    [super dealloc];
}

+ (NTGradientDraw*)sharedBackgroundGradient;
{
	static NTGradientDraw* shared = nil;
	if (!shared)
		shared = [[NTGradientDraw gradientWithStartColor:[NSColor colorWithDeviceWhite:0.94 alpha:1.0] 
												endColor:[NSColor colorWithDeviceWhite:0.86 alpha:1.0]] retain];
	return shared;
}	

#define kSnowLeopardAdjustment .05;

+ (NTGradientDraw*)sharedHeaderGradient:(BOOL)dimmed;
{
	static NTGradientDraw* normal = nil;
	static NTGradientDraw* dim = nil;
	CGFloat adjustment = 0;
	
	if ([NTUtilities runningOnSnowLeopard])
		adjustment = kSnowLeopardAdjustment;

	if (dimmed)
	{
		if (!dim)
			dim = [[NTGradientDraw gradientWithStartColor:[NSColor colorWithDeviceWhite:0.88+adjustment alpha:1.0] 
												 endColor:[NSColor colorWithDeviceWhite:0.76+adjustment alpha:1.0]] retain];
		return dim;		
	}
	
	if (!normal)
		normal = [[NTGradientDraw gradientWithStartColor:[NSColor colorWithDeviceWhite:0.86+adjustment alpha:1.0] 
												endColor:[NSColor colorWithDeviceWhite:0.62+adjustment alpha:1.0]] retain];
	return normal;
}	

+ (NTGradientDraw*)sharedDarkHeaderGradient:(BOOL)dimmed;
{
	static NTGradientDraw* normal = nil;
	static NTGradientDraw* dim = nil;
	CGFloat adjustment = 0;
	
	if ([NTUtilities runningOnSnowLeopard])
		adjustment = kSnowLeopardAdjustment;
	
	if (dimmed)
	{
		if (!dim)
			dim = [[NTGradientDraw gradientWithStartColor:[NSColor colorWithDeviceWhite:0.72+adjustment alpha:1.0] 
												 endColor:[NSColor colorWithDeviceWhite:0.66+adjustment alpha:1.0]] retain];
		return dim;		
	}
	
	if (!normal)
		normal = [[NTGradientDraw gradientWithStartColor:[NSColor colorWithDeviceWhite:0.68+adjustment alpha:1.0] 
												endColor:[NSColor colorWithDeviceWhite:0.52+adjustment alpha:1.0]] retain];
	return normal;
}

+ (NTGradientDraw*)sharedBottomWindowGradient:(BOOL)dimmed;
{
	static NTGradientDraw* normal = nil;
	static NTGradientDraw* dim = nil;
	CGFloat adjustment = 0;
	
	if ([NTUtilities runningOnSnowLeopard])
		adjustment = kSnowLeopardAdjustment;
	
	if (dimmed)
	{
		if (!dim)
			dim = [[NTGradientDraw gradientWithStartColor:[NSColor colorWithDeviceWhite:0.68+adjustment alpha:1.0] 
												 endColor:[NSColor colorWithDeviceWhite:0.64+adjustment alpha:1.0]] retain];
		return dim;		
	}
	
	if (!normal)
		normal = [[NTGradientDraw gradientWithStartColor:[NSColor colorWithDeviceWhite:0.65+adjustment alpha:1.0] 
												endColor:[NSColor colorWithDeviceWhite:0.50+adjustment alpha:1.0]] retain];
	return normal;	
}

- (void)drawInRect:(NSRect)bounds 
		horizontal:(BOOL)horizontal
		   flipped:(BOOL)flipped;
{
	[self drawInRect:bounds 
		  horizontal:horizontal
			 flipped:flipped
			clipPath:nil];
}

- (void)drawInRect:(NSRect)bounds 
		horizontal:(BOOL)horizontal
		   flipped:(BOOL)flipped
		  clipPath:(NSBezierPath*)clipPath;
{
	SGS;
	{	
		if (clipPath)
			[clipPath addClip];
		else
			[NSBezierPath clipRect:bounds];
				
		CGContextRef cgContext;
		cgContext = (CGContextRef) [[NSGraphicsContext currentContext] graphicsPort];
		
		if (!flipped) 
		{
			CGContextSaveGState(cgContext);
			CGContextTranslateCTM(cgContext, 0.0f, NSMaxY(bounds));
			CGContextScaleCTM(cgContext, 1.0f, -1.0f);
			
			// this fixed a case, not sure the logic behind it
			bounds.origin.y -= NSMinY(bounds);
		}
		
		[[self gradient] drawInRect:bounds angle:horizontal ? 90.0 : 0.0];
				
		if (!flipped)
			CGContextRestoreGState(cgContext);
	}
	RGS;
}

@end

@implementation NTGradientDraw (ColumnControlGradient)

+ (NTGradientDraw*)sharedColumnControlGradient;
{
	static NTGradientDraw* shared = nil;
	if (!shared)
		shared = [[NTGradientDraw gradientWithStartColor:[NSColor colorWithCalibratedWhite:1 alpha:1] endColor:[NSColor colorWithCalibratedWhite:.95 alpha:1]] retain];
	return shared;
}	

+ (void)drawColumnControlGradient:(NSRect)bounds flipped:(BOOL)flipped;
{
	[[NSColor colorWithCalibratedWhite:.902 alpha:1] set];
	[NSBezierPath fillRect:bounds];
	
	NSRect gradientRect = bounds;
	NSInteger bottomHeight = (NSHeight(gradientRect)/2) + 1;
	gradientRect.origin.y += bottomHeight;
	gradientRect.size.height -= bottomHeight;
	
	[[self sharedColumnControlGradient] drawInRect:gradientRect
										horizontal:YES flipped:flipped];
}

@end
