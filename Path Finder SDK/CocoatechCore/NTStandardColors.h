//
//  NTStandardColors.h
//  CocoatechCore
//
//  Created by Steve Gehrman on 8/17/04.
//  Copyright 2004 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NTStandardColors : NSObject 
{
}

+ (NSColor*)frameColor:(BOOL)dimControls;
+ (NSColor*)frameAccentLineColor:(BOOL)dimControls;
+ (NSColor*)verticalFrameAccentLineColor:(BOOL)dimControls;

+ (NSColor*)lightFrameColor:(BOOL)dimControls;

+ (NSColor*)highlightColorForControl:(NSView*)controlView requireFirstResponder:(BOOL)requireFirstResponder;
+ (NSColor*)textColorForControl:(NSView*)controlView requireFirstResponder:(BOOL)requireFirstResponder ignoreDimmed:(BOOL)ignoreDimmed;

+ (NSColor*)shadowColor;
+ (NSColor*)tabBarBackgroundColor:(BOOL)dimControls;

	// used for spotlight parameters and find window
+ (NSColor*)blueBackgroundColor;
+ (NSColor*)blueBackgroundRowColor;

+ (NSColor*)sourceListBackgroundColor:(BOOL)dimmed;

+ (NSColor*)whiteAccentLineColor;

+ (NSColor*)windowBackground;
@end

