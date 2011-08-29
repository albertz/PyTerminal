//
//  NSView-NSSplitViewExtensions.h
//  CocoatechCore
//
//  Created by Steve Gehrman on 1/14/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSView (NSSplitViewExtensions)
- (void)setCollapsed:(BOOL)collapsed animate:(BOOL)animate;
- (BOOL)isCollapsed;

- (NSMenuItem*)splitViewMenuItem;
- (NSSplitView*)enclosingSplitView;
@end