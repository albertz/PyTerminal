//
//  NSShadow-NTExtensions.h
//  CocoatechCore
//
//  Created by Steve Gehrman on Sat Oct 25 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

// a simple way to get a shadow set to a default

@interface NSShadow (NTExtensions)

+ (NSShadow*)defaultWhiteShadow;
+ (NSShadow*)defaultLightWhiteShadow;
+ (NSShadow*)defaultDisabledWhiteShadow;

+ (NSShadow*)defaultBlackShadow;
+ (NSShadow*)defaultGrayShadow;
+ (NSShadow*)defaultLightGrayShadow;
+ (NSShadow*)defaultDarkGrayShadow;

+ (NSShadow*)defaultShadowWithColor:(NSColor*)color;

+ (NSShadow*)shadowWithColor:(NSColor*)color offset:(NSSize)offset blurRadius:(CGFloat)blurRadius;

@end
