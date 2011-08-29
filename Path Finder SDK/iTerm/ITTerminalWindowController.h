//
//  ITTerminalWindowController.h
//  iTerm
//
//  Created by Steve Gehrman on 1/23/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class ITTerminalView, PTToolbarController;

@interface ITTerminalWindowController : NSWindowController <NSOutlineViewDelegate, NSDrawerDelegate, NSWindowDelegate>
{
	// view in the drawer
	NSOutlineView *mBookmarksView;
	ITTerminalView* mTerm;
	NSDrawer *mDrawer;

	PTToolbarController* mToolbarController;
}

+ (ITTerminalWindowController*)controller:(NSDictionary*)dict;

- (ITTerminalView *)term;
- (NSDrawer *)drawer;

@end
