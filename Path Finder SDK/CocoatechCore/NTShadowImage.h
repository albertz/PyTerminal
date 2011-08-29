//
//  NTShadowImage.h
//  CocoaTechAppKit
//
//  Created by Steve Gehrman on 11/15/09.
//  Copyright 2009 Cocoatech. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NTShadowImage : NSObject 
{
	NSImage* topShadowImage;
	NSImage* leftShadowImage;
	NSImage* rightShadowImage;
		
	CGFloat shadowOffset;
	CGFloat shadowBlur;
	NSUInteger shadowSize;
	NSColor* topShadowColor; 
	NSColor* shadowColor;
}

+ (NTShadowImage*)shadowImage;
+ (NTShadowImage*)largeShadowImage;

- (void)drawTopShadowInRect:(NSRect)inRect;
- (void)drawLeftShadowInRect:(NSRect)inRect;
- (void)drawRightShadowInRect:(NSRect)inRect;

@end
