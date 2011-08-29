//
//  NSShadow-NTExtensions.m
//  CocoatechCore
//
//  Created by Steve Gehrman on Sat Oct 25 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import "NSShadow-NTExtensions.h"

@implementation NSShadow (NTExtensions)

+ (NSShadow*)defaultShadowWithColor:(NSColor*)color;
{
    return [self shadowWithColor:color offset:NSMakeSize(0, -1) blurRadius:0];
}

+ (NSShadow*)defaultWhiteShadow;
{
	return [self defaultShadowWithColor:[NSColor colorWithCalibratedWhite:1 alpha:1]];
}

+ (NSShadow*)defaultLightWhiteShadow;
{
	return [self defaultShadowWithColor:[NSColor colorWithCalibratedWhite:1 alpha:.55]];
}

+ (NSShadow*)defaultDisabledWhiteShadow;
{
	return [self defaultShadowWithColor:[NSColor colorWithCalibratedWhite:1 alpha:.6]];
}

+ (NSShadow*)defaultBlackShadow;
{
	return [self defaultShadowWithColor:[[NSColor blackColor] colorWithAlphaComponent:.8]];
}

+ (NSShadow*)defaultDarkGrayShadow;
{
	return [self defaultShadowWithColor:[[NSColor blackColor] colorWithAlphaComponent:.6]];
}

+ (NSShadow*)defaultGrayShadow;
{
	return [self defaultShadowWithColor:[[NSColor blackColor] colorWithAlphaComponent:.3]];
}

+ (NSShadow*)defaultLightGrayShadow;
{
	return [self defaultShadowWithColor:[[NSColor blackColor] colorWithAlphaComponent:.2]];
}

+ (NSShadow*)shadowWithColor:(NSColor*)color offset:(NSSize)offset blurRadius:(CGFloat)blurRadius;
{
    NSShadow* result = [[self alloc] init];
		
    [result setShadowOffset:offset];
    
    [result setShadowBlurRadius:blurRadius];
    
    if (color)
		[result setShadowColor:color];
    
    return [result autorelease];    
}

@end
