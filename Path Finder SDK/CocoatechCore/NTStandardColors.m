//
//  NTStandardColors.m
//  CocoatechCore
//
//  Created by Steve Gehrman on 8/17/04.
//  Copyright 2004 __MyCompanyName__. All rights reserved.
//

#import "NTStandardColors.h"
#import "NSWindow-NTExtensions.h"

@interface NSColor (sourceListUndocumented)
+ (NSColor*)sourceListBackgroundColor;
@end

@implementation NTStandardColors

+ (NSColor*)frameColor:(BOOL)dimControls;
{
	if (dimControls)
	{
		static NSColor* shared = nil;
		if (!shared)
			shared = [[NSColor colorWithCalibratedWhite:.55 alpha:1.0] retain];
		
		return shared;
	}
	
    static NSColor* shared = nil;
    if (!shared)
		shared = [[NSColor colorWithCalibratedWhite:.3 alpha:1.0] retain];
    
    return shared;
}

+ (NSColor*)lightFrameColor:(BOOL)dimControls;
{
	if (dimControls)
	{
		static NSColor* shared = nil;
		if (!shared)
			shared = [[NSColor colorWithCalibratedWhite:.7 alpha:1.0] retain];
		
		return shared;
	}
	
    static NSColor* shared = nil;
    if (!shared)
		shared = [[NSColor colorWithCalibratedWhite:.42 alpha:1.0] retain];
    
    return shared;
}

+ (NSColor*)frameAccentLineColor:(BOOL)dimControls;
{
	if (dimControls)
	{
		static NSColor* shared = nil;
		if (!shared)
			shared = [[NSColor colorWithCalibratedWhite:1 alpha:.05] retain];
		
		return shared;		
	}
	
	static NSColor* shared = nil;
    if (!shared)
        shared = [[NSColor colorWithCalibratedWhite:1 alpha:.26] retain];
    
    return shared;    	
}

+ (NSColor*)verticalFrameAccentLineColor:(BOOL)dimControls;
{
	if (dimControls)
	{
		static NSColor* shared = nil;
		if (!shared)
			shared = [[NSColor colorWithCalibratedWhite:1 alpha:.05] retain];
		
		return shared;		
	}
	
	static NSColor* shared = nil;
    if (!shared)
        shared = [[NSColor colorWithCalibratedWhite:1 alpha:.1] retain];
    
    return shared;    	
}	

+ (NSColor*)highlightColorForControl:(NSView*)controlView requireFirstResponder:(BOOL)requireFirstResponder;
{
	NSColor *result = nil;
	NSWindow *window = [controlView window];
	
	if (![window dimControlsKey] && (!requireFirstResponder || ([window firstResponder] == controlView)))
		result = [NSColor alternateSelectedControlColor];
	else
		result = [NSColor secondarySelectedControlColor];
	
	return result;
}

+ (NSColor*)textColorForControl:(NSView*)controlView requireFirstResponder:(BOOL)requireFirstResponder ignoreDimmed:(BOOL)ignoreDimmed;
{
	NSColor *result = nil;
	NSWindow *window = [controlView window];
	
	if ((ignoreDimmed || ![window dimControlsKey]) && (!requireFirstResponder || ([window firstResponder] == controlView)))
		result = [NSColor alternateSelectedControlTextColor];
	else
		result = [NSColor disabledControlTextColor];
	
	return result;
}

+ (NSColor*)shadowColor;
{
    static NSColor* shared = nil;
    
    if (!shared)
        shared = [[NSColor colorWithCalibratedWhite:.600 alpha:1.0] retain];
    
    return shared;
}

+ (NSColor*)tabBarBackgroundColor:(BOOL)dimControls;
{
	if (dimControls)
	{
		static NSColor* shared = nil;
		if (!shared)
			shared = [[NSColor colorWithCalibratedWhite:.75 alpha:1.0] retain];
		
		return shared;
	}
	
    static NSColor* shared = nil;
    if (!shared)
		shared = [[NSColor colorWithCalibratedWhite:.47 alpha:1.0] retain];
    
    return shared;
}

// used for spotlight parameters and find window
+ (NSColor*)blueBackgroundColor;
{
	static NSColor* shared = nil;
    
    if (!shared)
        shared = [[NSColor colorWithCalibratedRed:.898 green:.925 blue:.973 alpha:1.0] retain];
    
    return shared;    
}

+ (NSColor*)blueBackgroundRowColor;
{
	static NSColor* shared = nil;
    
    if (!shared)
        shared = [[NSColor colorWithCalibratedRed:.808 green:.867 blue:.976 alpha:1.0] retain];
    
    return shared;    
}

+ (NSColor*)sourceListBackgroundColor:(BOOL)dimmed;
{
	if (dimmed)
	{
		static NSColor* shared = nil;
		
		if (!shared)
			shared = [[NSColor sourceListBackgroundColor] retain]; // [[NSColor colorWithCalibratedRed:.91 green:.91 blue:.91 alpha:1] retain];
		
		return shared;    
	}
	
	static NSColor* shared = nil;
    
    if (!shared)
        shared = [[NSColor sourceListBackgroundColor] retain]; // [[NSColor colorWithCalibratedRed:.820 green:.843 blue:.886 alpha:1] retain];
    
    return shared;    
}

+ (NSColor*)whiteAccentLineColor;
{
	static NSColor* shared = nil;
    
    if (!shared)
        shared = [[NSColor colorWithCalibratedWhite:1 alpha:.5] retain];
    
    return shared;    
}

+ (NSColor*)windowBackground;
{
	static NSColor* shared = nil;
    
    if (!shared)
        shared = [[NSColor colorWithCalibratedWhite:.90 alpha:1] retain];
    
    return shared;    
}

@end
