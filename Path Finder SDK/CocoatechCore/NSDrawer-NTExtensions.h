//
//  NSDrawer-NTExtensions.h
//  CocoatechCore
//
//  Created by Steve Gehrman on 10/9/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSDrawer (NTExtensions)

- (NSWindow*)drawerWindow;

@end

// =======================================================================================

@interface NSWindow (NSDrawerWindow)

+ (Class)drawerWindowClass;  // [NSDrawerWindow class]

- (BOOL)isDrawerWindow;

// I have a drawerWindow, we need the drawersParentWindow (-[NSWindow parentWindow] is only for child windows)
- (NSWindow*)drawersParentWindow;
@end