//
//  NSGraphicsContext-NTExtensions.h
//  CocoatechCore
//
//  Created by Steve Gehrman on 3/15/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSGraphicsContext (NTExtensions)

+ (double)radians:(double)degrees;
+ (double)degrees:(double)radians;

// rotate the current context
+ (void)rotateContext:(CGFloat)degrees inRect:(NSRect)inRect;

@end

// useful defines surrounds everthing with exception handlers

#define SGS                                           \
{                                                     \
	[NSGraphicsContext saveGraphicsState];            \
	{                                                 \
        @try                                          \
        {

#define RGS                                           \
		}                                             \
		@catch (NSException * e) {                    \
			NSLog(@"%@", [e description]);                   \
		}                                             \
		@finally {                                    \
			[NSGraphicsContext restoreGraphicsState]; \
		}                                             \
	}                                                 \
}
