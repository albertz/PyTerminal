//
//  CALayer-NTExtensions.m
//  CocoatechCore
//
//  Created by Steve Gehrman on 6/6/08.
//  Copyright 2008 Cocoatech. All rights reserved.
//

#import "CALayer-NTExtensions.h"
#include <tgmath.h>


@implementation CALayer (NTExtensions)

- (NSString*)longDescription;
{
	CGRect cgRect = [self frame];
	NSRect frame = *(NSRect*)&cgRect;
	
	cgRect = [self bounds];
	NSRect bounds = *(NSRect*)&cgRect;
	return [NSString stringWithFormat:@"%@, frame:%@, bounds:%@", 
			[self description],
			NSStringFromRect(frame), NSStringFromRect(bounds)];
}

- (void)debugLayers:(BOOL)showSubviews;
{
	NSLog(@"%@", [self description]);
	CGRect frame = [self frame];
	NSLog(@"name: %@", self.name);
	NSLog(@"frame: %@", NSStringFromRect(*(NSRect*)&frame));
	
	if (showSubviews)
	{
		NSLog(@"super: %@", [[self superlayer] description]);
		
		NSLog(@"sublayers:");
		for (CALayer *sublayer in [self sublayers])
			[sublayer debugLayers:showSubviews];
	}
	else
		[[self superlayer] debugLayers:showSubviews];
}

- (void)scale:(CGFloat)theScale;
{
	CATransform3D transform = CATransform3DMakeScale(theScale, theScale, theScale);
	[self setTransform:transform];
}

- (CGPoint)scrollPositionAsPercentage;
{
    CGRect bounds = [self bounds];
    CGRect documentVisibleRect = [self visibleRect];
	
    CGPoint scrollPosition;
    
    // Vertical position
    if (CGRectGetHeight(documentVisibleRect) >= CGRectGetHeight(bounds))
        scrollPosition.y = 0.0f; // We're completely visible
	else 
	{
        scrollPosition.y = (CGRectGetMinY(documentVisibleRect) - CGRectGetMinY(bounds)) / (CGRectGetHeight(bounds) - CGRectGetHeight(documentVisibleRect));
		scrollPosition.y = 1.0f - scrollPosition.y;
        scrollPosition.y = MIN(MAX(scrollPosition.y, 0.0f), 1.0f);
    }
	
    // Horizontal position
    if (CGRectGetWidth(documentVisibleRect) >= CGRectGetWidth(bounds)) 
        scrollPosition.x = 0.0f; // We're completely visible
	else 
	{
        scrollPosition.x = (CGRectGetMinX(documentVisibleRect) - CGRectGetMinX(bounds)) / (CGRectGetWidth(bounds) - CGRectGetWidth(documentVisibleRect));
        scrollPosition.x = MIN(MAX(scrollPosition.x, 0.0f), 1.0f);
    }
	
    return scrollPosition;
}

- (void)setScrollPositionAsPercentage:(CGPoint)scrollPosition;
{
    CGRect bounds = [self bounds];
    CGRect desiredRect = [self visibleRect];
	
    // Vertical position
    if (CGRectGetHeight(desiredRect) < CGRectGetHeight(bounds)) 
	{
        scrollPosition.y = MIN(MAX(scrollPosition.y, 0.0f), 1.0f);
		scrollPosition.y = 1.0f - scrollPosition.y;
        desiredRect.origin.y = rint(CGRectGetMinY(bounds) + scrollPosition.y * (CGRectGetHeight(bounds) - CGRectGetHeight(desiredRect)));
        if (CGRectGetMinY(desiredRect) < CGRectGetMinY(bounds))
            desiredRect.origin.y = CGRectGetMinY(bounds);
        else if (CGRectGetMaxY(desiredRect) > CGRectGetMaxY(bounds))
            desiredRect.origin.y = CGRectGetMaxY(bounds) - CGRectGetHeight(desiredRect);
    }
	
    // Horizontal position
    if (CGRectGetWidth(desiredRect) < CGRectGetWidth(bounds))
	{
        scrollPosition.x = MIN(MAX(scrollPosition.x, 0.0f), 1.0f);
        desiredRect.origin.x = rint(CGRectGetMinX(bounds) + scrollPosition.x * (CGRectGetWidth(bounds) - CGRectGetWidth(desiredRect)));
        if (CGRectGetMinX(desiredRect) < CGRectGetMinX(bounds))
            desiredRect.origin.x = CGRectGetMinX(bounds);
        else if (CGRectGetMaxX(desiredRect) > CGRectGetMaxX(bounds))
            desiredRect.origin.x = CGRectGetMaxX(bounds) - CGRectGetHeight(desiredRect);
    }
	
    [self scrollPoint:desiredRect.origin];
}

@end
