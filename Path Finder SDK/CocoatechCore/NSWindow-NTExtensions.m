//
//  NSWindow-NTExtensions.m
//  CocoatechCore
//
//  Created by Steve Gehrman on Fri Jan 16 2004.
//  Copyright (c) 2004 __MyCompanyName__. All rights reserved.
//

#import "NSWindow-NTExtensions.h"

@interface NSWindow (NSDrawerWindowUndocumented)
- (NSWindow*)_parentWindow;
@end

@interface NSApplication (Undocumented)
- (NSArray*)_orderedWindowsWithPanels:(BOOL)panels;
@end

@implementation NSWindow (Utilities)

+ (void)cascadeWindow:(NSWindow*)inWindow;
{
    // find the topmost window with the same class
    NSEnumerator *enumerator = [[self visibleWindows:YES] objectEnumerator];
    NSWindow* window;
    
    while (window = [enumerator nextObject])
    {
        // class must match exactly, but don't cascade it off itself
        if (window != inWindow)
        {
            if ([window isMemberOfClass:[inWindow class]] && [[window delegate] isMemberOfClass:[[inWindow delegate] class]])
            {
                // cascade new window off this window we found
                NSRect windowFrame = [window frame];
                NSPoint topLeftPoint = NSMakePoint(windowFrame.origin.x, NSMaxY(windowFrame));
                NSPoint cascadedPoint;
                
                cascadedPoint = [inWindow cascadeTopLeftFromPoint:topLeftPoint];
                windowFrame.origin = NSMakePoint(cascadedPoint.x, cascadedPoint.y - NSHeight(windowFrame));
                
                [inWindow setFrame:windowFrame display:NO];
                break;
            }
        }
    }
}

+ (BOOL)isAnyWindowVisibleWithDelegateClass:(Class)class;
{
    NSArray* windows = [self visibleWindows:NO];
    NSWindow* window;
    
    for (window in windows)
    {
        
        id delegate = [window delegate];
        
        if ([delegate isKindOfClass:class])
            return YES;
    }
    
    return NO;    
}

+ (BOOL)isAnyWindowVisible;
{
    NSArray* windows = [self visibleWindows:NO];
    NSWindow* window;
    
    for (window in windows)
    {
        
        // this should elliminate drawers and floating windows
        if ([window styleMask] & (NSTitledWindowMask | NSClosableWindowMask))
            return YES;
    }
    
    return NO;
}

- (NSWindow*)topWindowWithDelegateClass:(Class)class;
{
	NSArray* arr = [NSWindow visibleWindows:YES delegateClass:class];
	
	if ([arr count])
		return [arr objectAtIndex:0];
	
	return nil;
}

+ (NSArray*)visibleWindows:(BOOL)ordered;
{
	return [self visibleWindows:ordered delegateClass:nil];
}

+ (NSArray*)visibleWindows:(BOOL)ordered delegateClass:(Class)delegateClass;
{
	NSArray* windows;
    NSMutableArray* visibles = [NSMutableArray array];
    
	if (ordered)
		windows = [NSApp _orderedWindowsWithPanels:YES];
	else
		windows = [NSApp windows];
    
    if (windows && [windows count])
    {
        NSWindow* window;
		BOOL visible;
		BOOL appHidden = [NSApp isHidden];
        
        for (window in windows)
        {
            
			// hack: if app is hidden, all windows are not visible
			visible = [window isVisible];
			if (!visible && appHidden)
				visible = YES;
			
            if ([window canBecomeKeyWindow] && visible)  
			{
				// filter by delegates class if not nil
				if (delegateClass)
				{
					if (![[window delegate] isKindOfClass:delegateClass])
						window = nil;
				}
				
				if (window)
					[visibles addObject:window];
			}
        }
    }
    
    return visibles;	
}

+ (NSArray*)miniaturizedWindows;
{
    NSArray* windows;
    NSMutableArray* minaturized = [NSMutableArray array];
    
    windows = [NSApp windows];
    
    if (windows && [windows count])
    {
        NSWindow* window;
        
        for (window in windows)
        {
            
            if ([window canBecomeKeyWindow] && [window isMiniaturized])
            {
                // this should elliminate drawers and floating windows
                if ([window styleMask] & (NSTitledWindowMask | NSClosableWindowMask))
                    [minaturized addObject:window];
            }
        }
    }
    
    return minaturized;
}

- (void)setFloating:(BOOL)set;
{
    if (set)
        [self setLevel:NSFloatingWindowLevel];
    else
        [self setLevel:NSNormalWindowLevel];
}

- (BOOL)isFloating;
{
    return ([self level] == NSFloatingWindowLevel);
}

- (BOOL)isMetallic;
{
	// under 10.5 drawers don't adopt the styleMask, must check parent
	NSWindow* win = [self parentWindowIfDrawerWindow];
    return NSTexturedBackgroundWindowMaskSet([win styleMask]);
}

- (BOOL)isBorderless;
{
	return NSBorderlessWindowMaskSet([self styleMask]);
}

// returns parentWindow if an NSDrawerWindow, otherwise returns self
- (NSWindow*)parentWindowIfDrawerWindow;
{
	if ([self respondsToSelector:(@selector(_parentWindow))])
		return [self _parentWindow];
	
	return self;
}

- (void)setDefaultFirstResponder;
{
	// send this out to ask our window to set the defaul first responder
	[[NSNotificationCenter defaultCenter] postNotificationName:kNTSetDefaultFirstResponderNotification object:self];
}

- (BOOL)dimControls;
{
	if ([self isFloating])
		return NO;
	
	return ![[self parentWindowIfDrawerWindow] isMainWindow];
}

- (BOOL)dimControlsKey;
{
	// if key window is a menu, just call plain dimControls
	if ([self keyWindowIsMenu])
		return [self dimControls];

	if ([self isFloating])
		return NO;
	
	return ![[self parentWindowIfDrawerWindow] isKeyWindow];
}

- (BOOL)keyWindowIsMenu;
{
	static Class sCarbonMenuWindowClass=nil;
	if (!sCarbonMenuWindowClass)
		sCarbonMenuWindowClass = NSClassFromString(@"NSCarbonMenuWindow");
	
	return [[NSApp keyWindow] isKindOfClass:sCarbonMenuWindowClass];
}

- (void)flushActiveTextFields;
{
	// flush the current editor
	id fr = [self firstResponder];
	if (fr)
	{
		[self makeFirstResponder:nil];
		[self makeFirstResponder:fr];
	}
}		

- (NSRect)setContentViewAndResizeWindow:(NSView*)view display:(BOOL)display;
{
	NSRect frame = [self frame];
	frame.size = [self frameRectForContentRect:[view bounds]].size;
	[self setContentView:view];
	
	frame.origin.y += (NSHeight([self frame]) - NSHeight(frame));
	
	[self.animator setFrame:frame display:display];
	
	return frame;
}

- (NSRect)windowFrameForContentSize:(NSSize)contentSize;
{
	NSRect frame = [self frame];
	frame.size = [self frameRectForContentRect:NSMakeRect(0,0,contentSize.width, contentSize.height)].size;
	
	frame.origin.y += (NSHeight([self frame]) - NSHeight(frame));

	return frame;
}

- (NSRect)resizeWindowToContentSize:(NSSize)contentSize display:(BOOL)display;
{
	NSRect result = [self windowFrameForContentSize:contentSize];		
	[self.animator setFrame:result display:display];
	
	return result;
}

+ (BOOL)windowRectIsOnScreen:(NSRect)windowRect;
{	
    // make sure window is visible
    NSEnumerator* enumerator = [[NSScreen screens] objectEnumerator];
	NSScreen *screen;
	
    while (screen = [enumerator nextObject])
    {
        if (NSIntersectsRect(windowRect, [screen frame]))
		{
			// someone reported that a detacted monitor was keeping windows off screen?  Didn't verify
			// not sure if this hack works since I can't test it, but seems reasonable
			if (!NSIsEmptyRect([screen visibleFrame]))
				return YES;
		}
    }
	
    return NO;
}

// NSCopying protocol
// added to be compatible with the beginSheet hack in NTApplication.m taken from OmniAppKit
- (id)copyWithZone:(NSZone *)zone;
{
    return [self retain];
}

// windowNumber returns -1 when app is hidden, use this instead.  returns pointer value
- (NSNumber*)windowIdentifier;
{
	return [NSNumber numberWithUnsignedInteger:(NSUInteger)self];
}

// replaces [NSApp windowWithWindowNumber:]
+ (NSWindow*)windowWithIdentifier:(NSNumber*)theWindowID;
{
	NSArray* windows = [NSApp windows];
	
	for (NSWindow* window in windows)
	{
		if ([[window windowIdentifier] isEqual:theWindowID])
			return window;
	}

	return nil;
}

@end

