//
//  NTColorSet.m
//  CocoatechCore
//
//  Created by Steve Gehrman on 9/1/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "NTColorSet.h"
#import "NTStandardColors.h"
#import "NSShadow-NTExtensions.h"

@interface NTColorSet (Private)
- (NSMutableDictionary *)colors;
- (void)setColors:(NSMutableDictionary *)theColors;
@end

@implementation NTColorSet

//---------------------------------------------------------- 
// dealloc
//---------------------------------------------------------- 
- (void)dealloc
{
    [self setColors:nil];

    [super dealloc];
}

- (void)setColor:(NSColor*)theColor forKey:(NSString*)theKey
{
    [[self colors] setObject:theColor forKey:theKey];
}

- (NSColor*)colorForKey:(NSString*)theKey
{
	NSColor* result = [[self colors] objectForKey:theKey];

	if (!result)
		NSLog(@"-[%@ %@] nil:%@", [self className], NSStringFromSelector(_cmd), theKey);
	
	return result;
}

- (NSColor*)frameColor:(BOOL)dimControls;
{
	if (dimControls)
		return [self colorForKey:kNTCS_frame_dimmed];

	return [self colorForKey:kNTCS_frame];
}

- (NSColor*)blackAccentColor:(BOOL)dimControls;
{
	if (dimControls)
		return [self colorForKey:kNTCS_blackAccent_dimmed];
	
	return [self colorForKey:kNTCS_blackAccent];	
}

@end

@implementation NTColorSet (Private)

//---------------------------------------------------------- 
//  colors 
//---------------------------------------------------------- 
- (NSMutableDictionary *)colors
{
	if (!mColors)
		[self setColors:[NSMutableDictionary dictionary]];
	
    return mColors; 
}

- (void)setColors:(NSMutableDictionary *)theColors
{
    if (mColors != theColors)
    {
        [mColors release];
        mColors = [theColors retain];
    }
}

@end

@implementation NTColorSet (NTStandardColorSets)

+ (NTColorSet*)standardSet;
{
	NTColorSet* result = [[NTColorSet alloc] init];
	
	CGFloat textAlpha = 0.80;
	
	// colors
	[result setColor:[NSColor colorWithCalibratedWhite:0.0 alpha:textAlpha] forKey:kNTCS_text];
	[result setColor:[NSColor colorWithCalibratedWhite:0.0 alpha:textAlpha-.05] forKey:kNTCS_unselectedText];
	[result setColor:[NSColor colorWithCalibratedWhite:.30 alpha:1] forKey:kNTCS_disabledText];
	
	// images
	[result setColor:[NSColor colorWithCalibratedWhite:0.0 alpha:textAlpha+.1] forKey:kNTCS_blackImage];
	
	[result setColor:[NSColor colorWithCalibratedWhite:.1 alpha:1] forKey:kNTCS_mouseOverText];
	[result setColor:[[NSColor blackColor] colorWithAlphaComponent:.1] forKey:kNTCS_mouseOverBackground];
	[result setColor:[NSColor colorWithCalibratedRed:.3 green:.6 blue:.8 alpha:1] forKey:kNTCS_mouseOverControl];

	[result setColor:[NTStandardColors frameColor:NO] forKey:kNTCS_frame];
	[result setColor:[NTStandardColors frameColor:YES] forKey:kNTCS_frame_dimmed];
	
	[result setColor:[NTStandardColors frameAccentLineColor:NO] forKey:kNTCS_whiteAccent];
	[result setColor:[NSColor colorWithCalibratedWhite:1 alpha:.1] forKey:kNTCS_lightWhiteAccent];
	
	[result setColor:[NSColor colorWithCalibratedWhite:.35 alpha:1] forKey:kNTCS_blackAccent];
	[result setColor:[NSColor colorWithCalibratedWhite:.55 alpha:1] forKey:kNTCS_blackAccent_dimmed];

	[result setColor:[NSColor colorWithCalibratedWhite:0 alpha:1] forKey:kNTCS_black];
	[result setColor:[NSColor colorWithCalibratedWhite:1 alpha:1] forKey:kNTCS_white];
	
	return [result autorelease];
}

@end

