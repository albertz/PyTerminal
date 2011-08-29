//
//  NSSplitView-NTExtensions.m
//  CocoatechCore
//
//  Created by Steve Gehrman on 1/9/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "NSSplitView-NTExtensions.h"
#import "NTSplitViewDelegate.h"
#import "NSView-NSSplitViewExtensions.h"

@interface NSSplitView (NTExtensionsPrivate)
- (NSString*)positionAutosaveName;
- (NSNumber*)positionPreference;
- (CGFloat)positionForFraction:(CGFloat)fraction;
- (void)savePositionPreference:(CGFloat)position;
@end

@implementation NSSplitView (NTExtensions)

- (CGFloat)splitFraction;
{	
    if ([[self subviews] count] != 2)
		return 0.0;
	
	if ([self isVertical])
		return [self position] / [self frame].size.width;

	return [self position] / [self frame].size.height;
}

- (void)setSplitFraction:(CGFloat)fraction animate:(BOOL)animate;
{
	[self setPosition:[self positionForFraction:fraction] ofDividerAtIndex:0 animate:animate];
}

- (void)setPosition:(CGFloat)newSplitterPosition ofDividerAtIndex:(NSInteger)dividerIndex animate:(BOOL)animate;
{
	if (!animate || ([[self subviews] count] != 2))
		[self setPosition:newSplitterPosition ofDividerAtIndex:dividerIndex];
	else
	{		
		NSView *subview0 = [[self subviews] objectAtIndex:0];
		NSView *subview1 = [[self subviews] objectAtIndex:1];
		
		NSRect subview0EndFrame = [subview0 frame];
		NSRect subview1EndFrame = [subview1 frame];
		
		if ([self isVertical])
		{
			subview0EndFrame.size.width = newSplitterPosition;
			
			subview1EndFrame.origin.x = newSplitterPosition + [self dividerThickness];
			subview1EndFrame.size.width = [self frame].size.width - subview0EndFrame.size.width - [self dividerThickness];
			
			if (subview1EndFrame.size.width < 0)
				subview1EndFrame.size.width = 0;
		}
		else 
		{
			subview0EndFrame.size.height = newSplitterPosition;
			
			subview1EndFrame.origin.y = newSplitterPosition + [self dividerThickness];
			subview1EndFrame.size.height = [self frame].size.height - subview0EndFrame.size.height - [self dividerThickness];

			if (subview1EndFrame.size.height < 0)
				subview1EndFrame.size.height = 0;
		}
		
		[[subview0 animator] setFrame:subview0EndFrame];
		[[subview1 animator] setFrame:subview1EndFrame];
	}
}

- (CGFloat)position;
{
	if ([[self subviews] count] == 2)
	{
		NSRect frame = [[[self subviews] objectAtIndex:0] frame];
		
		if ([self isVertical])
			return frame.size.width;
		else
			return frame.size.height;
	}
	
	return 0.0;
}

- (void)setupSplitView:(NSString*)autosaveName 
	   defaultFraction:(CGFloat)defaultFraction;
{
	[self setAutosaveName:autosaveName];
	
	// if pref doesn't exist then it's the first time to run, so set teh defaultFraction and then save the pref
	NSNumber* savedPosition = [self positionPreference];
	if (!savedPosition)
	{
		[self setSplitFraction:defaultFraction animate:NO];
		[self savePositionPreference];
	}
}

- (void)savePositionPreference;
{
	[self savePositionPreference:[self splitFraction]];
}

- (CGFloat)positionFromPreference;
{	
	CGFloat fraction = .5;
	NSNumber* prefFraction = [self positionPreference];
	if (prefFraction)
		fraction = [prefFraction doubleValue];
	
	return [self positionForFraction:fraction];
}

@end

@implementation NSSplitView (NTExtensionsPrivate)

- (void)savePositionPreference:(CGFloat)position;
{
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithDouble:position] forKey:[self positionAutosaveName]];
}

- (NSString*)positionAutosaveName;
{
	return [NSString stringWithFormat:@"expanded-%@", [self autosaveName]];
}

- (NSNumber*)positionPreference;
{
	return [[NSUserDefaults standardUserDefaults] objectForKey:[self positionAutosaveName]];
}

- (CGFloat)positionForFraction:(CGFloat)fraction;
{
	if ([self isVertical])
		return ([self frame].size.width - [self dividerThickness]) * fraction;
	
	return ([self frame].size.height - [self dividerThickness]) * fraction;
} 

@end


