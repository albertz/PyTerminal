//
//  NTStandardImages.h
//  CocoatechCore
//
//  Created by Steve Gehrman on 7/23/04.
//  Copyright 2004 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "NSBezierPath-NTExtensions.h"

@interface NTStandardImages : NSObject {
}

+ (NSImage*)resizeIndicator;

+ (NSImage*)horizontalSplitViewImage;
+ (NSImage*)verticalSplitViewImage;

+ (NSImage*)roundSplitViewImage;
+ (NSImage*)smallRoundSplitViewImage;
+ (NSImage*)makeRoundSplitViewImage:(NSInteger)width;

+ (NSImage*)popupArrowImage:(NSColor*)color;
+ (NSImage*)popupArrowImage:(NSColor*)color small:(BOOL)small;

+ (NSImage*)popupArrowImage:(NSColor*)color 
					  small:(BOOL)small 
				  direction:(NTTrianglePathDirection)direction;

+ (NSImage*)sharedRightPopupArrowImage;
+ (NSImage*)sharedSmallRightPopupArrowImage;

+ (NSImage*)sharedPopupArrowImage;
+ (NSImage*)sharedSmallPopupArrowImage;
+ (NSImage*)sharedLightPopupArrowImage;

+ (NSImage*)home:(NSColor*)color;
+ (NSImage*)computer:(NSColor*)color;

+ (NSImage*)chevron;
+ (NSImage*)favoritesTemplate;
+ (NSImage*)actionGear;
+ (NSImage*)dropTarget;

+ (NSImage*)ascendingSortIndicator;
+ (NSImage*)descendingSortIndicator;

@end
