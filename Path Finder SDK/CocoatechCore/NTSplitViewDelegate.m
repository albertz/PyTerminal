//
//  NTSplitViewDelegate.m
//  CocoatechCore
//
//  Created by Steve Gehrman on 12/20/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "NTSplitViewDelegate.h"
#import "NSSplitView-NTExtensions.h"
#import "NSView-NSSplitViewExtensions.h"

@interface NTSplitViewDelegate (Private)
- (void)layoutSubviews:(NSSplitView *)splitView oldSize:(NSSize)oldSize;
- (void)layoutCollapsed:(NSSplitView *)splitView;

- (void)subviewRects:(NSSplitView*)splitView
		   firstRect:(NSRect*)outFirstRect 
		  secondRect:(NSRect*)outSecondRect;
- (void)subviewRects_reversed:(NSSplitView*)splitView
					firstRect:(NSRect*)outFirstRect 
				   secondRect:(NSRect*)outSecondRect;
- (void)subviewRects_proportional:(NSSplitView*)splitView
						firstRect:(NSRect*)outFirstRect 
					   secondRect:(NSRect*)outSecondRect
						  oldSize:(NSSize)oldSize;
@end

@implementation NTSplitViewDelegate

@synthesize delegate;
@synthesize resizeViewIndex;
@synthesize collapseViewIndex;
@synthesize preventViewCollapseAtIndex;
@synthesize minCoordinate;
@synthesize maxCoordinate, resizeProportionally;

+ (NTSplitViewDelegate*)splitViewDelegate;
{
	return [self splitViewDelegate:nil];
}

+ (NTSplitViewDelegate*)splitViewDelegate:(id)delegate;
{
	NTSplitViewDelegate* result = [[NTSplitViewDelegate alloc] init];
	
	[result setDelegate:delegate];
	[result setCollapseViewIndex:1];
	[result setPreventViewCollapseAtIndex:-1];
	[result setMaxCoordinate:20];
	[result setMinCoordinate:20];
	
	return [result autorelease];
}

//---------------------------------------------------------- 
// dealloc
//---------------------------------------------------------- 
- (void)dealloc
{
	if ([self delegate])
		[NSException raise:@"must call clearDelegate" format:@"%@", NSStringFromClass([self class])];
	
    [super dealloc];
}

- (void)clearDelegate;
{
	[self setDelegate:nil];
}

@end

@implementation NTSplitViewDelegate (NSSplitViewDelegate)

- (void)splitViewWillResizeSubviews:(NSNotification *)notification;
{	
	// forward to delegate
	if ([[self delegate] respondsToSelector:_cmd])
		[[self delegate] splitViewWillResizeSubviews:notification];
}

- (void)splitViewDidResizeSubviews:(NSNotification *)notification;
{
	// forward to delegate
	if ([[self delegate] respondsToSelector:_cmd])
		[[self delegate] splitViewDidResizeSubviews:notification];	
}

- (CGFloat)splitView:(NSSplitView *)splitView constrainMinCoordinate:(CGFloat)proposedMinimumPosition ofSubviewAt:(NSInteger)dividerIndex;
{
	// forward to delegate
	if ([[self delegate] respondsToSelector:_cmd])
		return [[self delegate] splitView:splitView constrainMinCoordinate:proposedMinimumPosition ofSubviewAt:dividerIndex];
	
	return proposedMinimumPosition + [self minCoordinate];
}

- (CGFloat)splitView:(NSSplitView *)splitView constrainMaxCoordinate:(CGFloat)proposedMaximumPosition ofSubviewAt:(NSInteger)dividerIndex;
{
	// forward to delegate
	if ([[self delegate] respondsToSelector:_cmd])
		return [[self delegate] splitView:splitView constrainMaxCoordinate:proposedMaximumPosition ofSubviewAt:dividerIndex];
	
	return proposedMaximumPosition - [self maxCoordinate];
}

- (CGFloat)splitView:(NSSplitView *)splitView constrainSplitPosition:(CGFloat)proposedPosition ofSubviewAt:(NSInteger)dividerIndex;
{
	// forward to delegate
	if ([[self delegate] respondsToSelector:_cmd])
		return [[self delegate] splitView:splitView constrainSplitPosition:proposedPosition ofSubviewAt:dividerIndex];
	
	return proposedPosition;
}

- (BOOL)splitView:(NSSplitView *)splitView canCollapseSubview:(NSView *)subview;
{
	// forward to delegate
	if ([[self delegate] respondsToSelector:_cmd])
		return [[self delegate] splitView:splitView canCollapseSubview:subview];
	
	if ([self preventViewCollapseAtIndex] != -1)
	{
		NSArray* views = [splitView subviews];
		if ([views count] == 2)
		{
			if (subview == [views objectAtIndex:[self preventViewCollapseAtIndex]])
				return NO;
		}
	}
	
	// if -1, never allow collapsing
	if ([self collapseViewIndex] == -1)
		return NO;
	
	return YES;
}

- (BOOL)splitView:(NSSplitView *)splitView shouldCollapseSubview:(NSView *)subview forDoubleClickOnDividerAtIndex:(NSInteger)dividerIndex;
{
	// forward to delegate
	if ([[self delegate] respondsToSelector:_cmd])
		return [[self delegate] splitView:splitView shouldCollapseSubview:subview forDoubleClickOnDividerAtIndex:dividerIndex];
	
	NSInteger collapseIndex = [self collapseViewIndex];
	if (collapseIndex != -1)
	{
		NSArray* views = [splitView subviews];
		if ([views count] == 2)
		{
			if (subview == [views objectAtIndex:collapseIndex])
				[subview setCollapsed:YES animate:YES];  // instead of returning YES, we do our own collapse
		}
	}
	
	return NO;
}

- (void)splitView:(NSSplitView *)splitView resizeSubviewsWithOldSize:(NSSize)oldSize;
{	
	BOOL handled = NO;
	
	// forward to delegate
	if ([[self delegate] respondsToSelector:_cmd])
	{
		[[self delegate] splitView:splitView resizeSubviewsWithOldSize:oldSize];
		
		handled = YES;
	}
	
	if (!handled)
		[self layoutSubviews:splitView oldSize:oldSize];
}

- (BOOL)splitView:(NSSplitView *)splitView shouldHideDividerAtIndex:(NSInteger)dividerIndex;
{
	// forward to delegate
	if ([[self delegate] respondsToSelector:_cmd])
		return [[self delegate] splitView:splitView shouldHideDividerAtIndex:dividerIndex];
	
	return YES;
}

- (NSRect)splitView:(NSSplitView *)splitView effectiveRect:(NSRect)proposedEffectiveRect forDrawnRect:(NSRect)drawnRect ofDividerAtIndex:(NSInteger)dividerIndex;
{
	// forward to delegate
	if ([[self delegate] respondsToSelector:_cmd])
	{
		return [[self delegate] splitView:splitView 
							effectiveRect:proposedEffectiveRect 
							 forDrawnRect:drawnRect
						 ofDividerAtIndex:dividerIndex];
	}
	
	return proposedEffectiveRect;
}

- (NSRect)splitView:(NSSplitView *)splitView additionalEffectiveRectOfDividerAtIndex:(NSInteger)dividerIndex;
{
	// forward to delegate
	if ([[self delegate] respondsToSelector:_cmd])
		return [[self delegate] splitView:splitView additionalEffectiveRectOfDividerAtIndex:dividerIndex];
	
	return NSZeroRect;
}

@end

@implementation NTSplitViewDelegate (Private)

- (void)subviewRects_proportional:(NSSplitView*)splitView
						firstRect:(NSRect*)outFirstRect 
					   secondRect:(NSRect*)outSecondRect
						  oldSize:(NSSize)oldSize;
{
	NSRect secondRect = [splitView bounds];
	NSRect firstRect = [splitView bounds];
	NSView* secondView = [[splitView subviews] objectAtIndex:1];
	
	if (![splitView isVertical])
	{
		double ratio = [secondView frame].size.height / oldSize.height;
		secondRect.size.height = (NSInteger) ceil(ratio * [splitView bounds].size.height);
		
		if (secondRect.size.height > ([splitView bounds].size.height - [splitView dividerThickness]))
			secondRect.size.height = ([splitView bounds].size.height - [splitView dividerThickness]);
		
		firstRect.size.height = [splitView bounds].size.height - ([splitView dividerThickness] + secondRect.size.height);
		
		if (firstRect.size.height < [self minCoordinate])
			firstRect.size.height = [self minCoordinate];  
		
		secondRect.origin.y = NSMaxY(firstRect) + [splitView dividerThickness];
	}
	else
	{
		double ratio = [secondView frame].size.width / oldSize.width;
		secondRect.size.width = (NSInteger) ceil(ratio * [splitView bounds].size.width);
		
		if (secondRect.size.width > ([splitView bounds].size.width - [splitView dividerThickness]))
			secondRect.size.width = ([splitView bounds].size.width - [splitView dividerThickness]);
		
		firstRect.size.width = [splitView bounds].size.width - ([splitView dividerThickness] + secondRect.size.width);
		
		if (firstRect.size.width < [self minCoordinate])
			firstRect.size.width = [self minCoordinate];
		
		secondRect.origin.x = NSMaxX(firstRect) + [splitView dividerThickness];
	}		
	
	if (outFirstRect)
		*outFirstRect = firstRect;
	
	if (outSecondRect)
		*outSecondRect = secondRect;
}

- (void)subviewRects_reversed:(NSSplitView*)splitView
					firstRect:(NSRect*)outFirstRect 
				   secondRect:(NSRect*)outSecondRect;
{
	NSRect secondRect = [splitView bounds];
	NSRect firstRect = [splitView bounds];
	NSView* secondView = [[splitView subviews] objectAtIndex:1];
	
	if (![splitView isVertical])
	{
		secondRect.size.height = [secondView frame].size.height;
		
		if (secondRect.size.height > ([splitView bounds].size.height - [splitView dividerThickness]))
			secondRect.size.height = ([splitView bounds].size.height - [splitView dividerThickness]);
		
		firstRect.size.height = [splitView bounds].size.height - ([splitView dividerThickness] + secondRect.size.height);
		
		if (firstRect.size.height < [self minCoordinate])
			firstRect.size.height = [self minCoordinate];  
		
		secondRect.origin.y = NSMaxY(firstRect) + [splitView dividerThickness];
	}
	else
	{
		secondRect.size.width = [secondView frame].size.width;
		
		if (secondRect.size.width > ([splitView bounds].size.width - [splitView dividerThickness]))
			secondRect.size.width = ([splitView bounds].size.width - [splitView dividerThickness]);
		
		firstRect.size.width = [splitView bounds].size.width - ([splitView dividerThickness] + secondRect.size.width);
		
		if (firstRect.size.width < [self minCoordinate])
			firstRect.size.width = [self minCoordinate];
		
		secondRect.origin.x = NSMaxX(firstRect) + [splitView dividerThickness];
	}		
	
	if (outFirstRect)
		*outFirstRect = firstRect;
	
	if (outSecondRect)
		*outSecondRect = secondRect;
}

- (void)subviewRects:(NSSplitView*)splitView
		   firstRect:(NSRect*)outFirstRect 
		  secondRect:(NSRect*)outSecondRect;
{
	NSRect secondRect = [splitView bounds];
	NSRect firstRect = [splitView bounds];
	NSView* firstView = [[splitView subviews] objectAtIndex:0];
	
	if (![splitView isVertical])
	{
		firstRect.size.height = [firstView frame].size.height;
		
		if (firstRect.size.height > ([splitView bounds].size.height - [splitView dividerThickness]))
			firstRect.size.height = ([splitView bounds].size.height - [splitView dividerThickness]);
		
		secondRect.size.height = [splitView bounds].size.height - ([splitView dividerThickness] + firstRect.size.height);
		secondRect.origin.y = NSMaxY(firstRect) + [splitView dividerThickness];
		
		if (secondRect.size.height < [self minCoordinate])
			secondRect.size.height = [self minCoordinate];        
	}
	else
	{
		firstRect.size.width = [firstView frame].size.width;
		
		if (firstRect.size.width > ([splitView bounds].size.width - [splitView dividerThickness]))
			firstRect.size.width = ([splitView bounds].size.width - [splitView dividerThickness]);
		
		secondRect.size.width = [splitView bounds].size.width - ([splitView dividerThickness] + firstRect.size.width);
		secondRect.origin.x = NSMaxX(firstRect) + [splitView dividerThickness];
		
		if (secondRect.size.width < [self minCoordinate])
			secondRect.size.width = [self minCoordinate];
	}
	
	if (outFirstRect)
		*outFirstRect = firstRect;
	
	if (outSecondRect)
		*outSecondRect = secondRect;	
}

- (void)layoutSubviews:(NSSplitView *)splitView oldSize:(NSSize)oldSize;
{
	NSRect secondRect;
	NSRect firstRect;
	
	NSView* firstView = [[splitView subviews] objectAtIndex:0];
	NSView* secondView = [[splitView subviews] objectAtIndex:1];
	
	if ([firstView isCollapsed] || [secondView isCollapsed])
		[self layoutCollapsed:splitView];
	else
	{
		if ([self resizeProportionally])
			[self subviewRects_proportional:splitView firstRect:&firstRect secondRect:&secondRect oldSize:oldSize];
		else
		{
			if ([self resizeViewIndex] == 1)
				[self subviewRects_reversed:splitView firstRect:&firstRect secondRect:&secondRect];
			else
				[self subviewRects:splitView firstRect:&firstRect secondRect:&secondRect];
		}
		
		[firstView setFrame:firstRect];
		[secondView setFrame:secondRect];
	}
}

- (void)layoutCollapsed:(NSSplitView *)splitView;
{	
	NSView* firstView = [[splitView subviews] objectAtIndex:0];
	NSView* secondView = [[splitView subviews] objectAtIndex:1];
	
	NSRect theRect = [splitView bounds];
	if ([firstView isCollapsed])
	{
		[secondView setFrame:theRect];
		
		// must make sure first view has some collapsed resonable values otherwise the OS complains
		if ([splitView isVertical])
			theRect.size.width = 0;
		else
			theRect.size.height = 0;
		
		[firstView setFrame:theRect];
	}
	else  // else second view is the one collapsed
	{
		[firstView setFrame:theRect];
		
		// must make sure first view has some collapsed resonable values otherwise the OS complains
		if ([splitView isVertical])
		{
			theRect.origin.x = NSMaxX(theRect);
			theRect.size.width = 0;
		}
		else
		{
			theRect.origin.y = NSMaxY(theRect);
			theRect.size.height = 0;
		}
		
		[secondView setFrame:theRect];			
	}
}

@end


