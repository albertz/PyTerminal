//
//  NSView-NSSplitViewExtensions.m
//  CocoatechCore
//
//  Created by Steve Gehrman on 1/14/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "NSView-NSSplitViewExtensions.h"
#import "NSView-CoreExtensions.h"
#import "NSSplitView-NTExtensions.h"

@implementation NSView (NSSplitViewExtensions)

- (void)setCollapsed:(BOOL)collapsed animate:(BOOL)animate;
{	
	// already collapsed?
	if (collapsed == [self isCollapsed])
		return;
	
	// call NSSplitViews delegate to signal a refresh
	NSSplitView* splitView = (NSSplitView*) [self findKindOfEnclosingView:[NSSplitView class]];
	if (splitView)
	{
		if ([[splitView subviews] count] == 2)
		{			
			BOOL firstSubView = (self == [[splitView subviews] objectAtIndex:0]);
			CGFloat position;
			
			if ([splitView isVertical])
			{				
				// which view are we collapsing?  first one or second one?
				if (firstSubView)
					position = (collapsed) ? 0.0 : [splitView positionFromPreference];
				else
					position = (collapsed) ? splitView.frame.size.width : [splitView positionFromPreference];
			}
			else
			{
				// which view are we collapsing?  first one or second one?
				if (firstSubView)
					position = (collapsed) ? 0.0 : [splitView positionFromPreference];
				else
					position = (collapsed) ? splitView.frame.size.height : [splitView positionFromPreference];
			}
			
			// save pref before we collapse
			if (collapsed)
				[splitView savePositionPreference];
			else
				[self setHidden:NO]; // make sure we were not hidden (Cocoa does hide the view when you drag collapse)
			
			[splitView setPosition:position ofDividerAtIndex:0 animate:animate];
		}
	}
}

- (BOOL)isCollapsed;
{
	NSSplitView* splitView = [self enclosingSplitView];
	
	if (splitView)
	{
		BOOL sizeZero = NO;
		
		if ([splitView isVertical])
			sizeZero = (NSWidth(self.frame) <= 0);
		else
			sizeZero = (NSHeight(self.frame) <= 0);
		
		return [splitView isSubviewCollapsed:self] || [self isHidden] || sizeZero;
	}
	
	return NO;
}

- (void)uncollapseSplitViewAction:(id)sender;
{
	NSSplitView* splitView = [self enclosingSplitView];
	
	if (splitView)
	{
		// any subviews collapsed?
		for (NSView *subview in [splitView subviews])
		{
			if ([subview isCollapsed])
				[subview setCollapsed:NO animate:YES];
		}
	}
}

- (NSSplitView*)enclosingSplitView;
{
	NSSplitView* splitView = (NSSplitView*)[self findKindOfEnclosingView:[NSSplitView class]];
	
	if (splitView)
	{		
		if ([self superview] == splitView)
			return splitView;
	}
	
	return nil;
}

// searches for parent splitview and if it has a collapsed 
- (NSMenuItem*)splitViewMenuItem;
{
	NSSplitView* splitView = [self enclosingSplitView];
	
	if (splitView)
	{
		// any subviews collapsed?
		for (NSView *subview in [splitView subviews])
		{
			if ([subview isCollapsed])
			{
				NSMenuItem* menuItem = [[[NSMenuItem alloc] initWithTitle:[NTLocalizedString localize:@"Reveal Collapsed View" table:@"menuBar"] action:@selector(uncollapseSplitViewAction:) keyEquivalent:@""] autorelease];
				[menuItem setTarget:self];
				
				return menuItem;
			}
		}
	}
	
	return nil;
}

@end
