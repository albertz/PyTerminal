//
//  NSDrawer-NTExtensions.m
//  CocoatechCore
//
//  Created by Steve Gehrman on 10/9/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "NSDrawer-NTExtensions.h"


@implementation NSDrawer (NTExtensions)

- (NSWindow*)drawerWindow;
{
	return [[self contentView] window];
}

@end

// ===================================================================================================

@interface NSWindow (NSDrawerWindowUndocumented)
- (NSWindow*)_parentWindow;
@end

@implementation NSWindow (NSDrawerWindow)

+ (Class)drawerWindowClass;
{
    static Class class = nil;
    
    if (!class)
        class = NSClassFromString(@"NSDrawerWindow");
    
    return class;
}

- (BOOL)isDrawerWindow;
{
	return [self isKindOfClass:[[self class] drawerWindowClass]];
}

	// I have a drawerWindow, we need the drawersParentWindow (-[NSWindow parentWindow] is only for child windows)
- (NSWindow*)drawersParentWindow;
{
	if ([self isDrawerWindow])
	{
		if ([self respondsToSelector:(@selector(_parentWindow))])
			return [self _parentWindow];
	}
	
	return nil;
}

@end