//
//  NTGradientDraw.h
//  CocoatechCore
//
//  Created by Steve Gehrman on 4/12/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NTGradientDraw : NSObject 
{
	NSGradient *gradient;
}

@property (retain) NSGradient *gradient;

// Allocate and autorelease a gradient with the specified start
// and end colors.
+ (NTGradientDraw*)gradientWithStartColor:(NSColor*)startCol
								 endColor:(NSColor*)endCol;

+ (NTGradientDraw*)sharedBackgroundGradient;
+ (NTGradientDraw*)sharedHeaderGradient:(BOOL)dimmed;
+ (NTGradientDraw*)sharedDarkHeaderGradient:(BOOL)dimmed;
+ (NTGradientDraw*)sharedBottomWindowGradient:(BOOL)dimmed;

- (void)drawInRect:(NSRect)bounds 
		horizontal:(BOOL)horizontal
		   flipped:(BOOL)flipped;

- (void)drawInRect:(NSRect)bounds 
		horizontal:(BOOL)horizontal
		   flipped:(BOOL)flipped
		  clipPath:(NSBezierPath*)clipPath;

@end

@interface NTGradientDraw (ColumnControlGradient)
+ (void)drawColumnControlGradient:(NSRect)bounds flipped:(BOOL)flipped;
@end

