//
//  NSGraphicsContext-NTExtensions.m
//  CocoatechCore
//
//  Created by Steve Gehrman on 3/15/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "NSGraphicsContext-NTExtensions.h"

@implementation NSGraphicsContext (NTExtensions)

+ (double)radians:(double)degrees;
{
	return degrees * M_PI/180;
}

+ (double)degrees:(double)radians;
{
	return radians * 180/M_PI;
}

// rotate graphics context state before drawing
+ (void)rotateContext:(CGFloat)degrees inRect:(NSRect)inRect;
{
	CGFloat angle = [self radians:degrees];
	NSGraphicsContext *currentContext;
	CGContextRef graphicsContext;
	
	currentContext = [NSGraphicsContext currentContext];
	graphicsContext = (CGContextRef)[currentContext graphicsPort];
	if (angle != 0) 
	{				
		CGContextTranslateCTM(graphicsContext, NSWidth(inRect) / 2.0, NSHeight(inRect) / 2.0);
		CGContextRotateCTM(graphicsContext, -angle);
		CGContextTranslateCTM(graphicsContext, -NSWidth(inRect) / 2.0, -NSHeight(inRect) / 2.0);
	}
}

@end