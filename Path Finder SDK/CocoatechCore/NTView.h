//
//  NTView.h
//  CocoatechCore
//
//  Created by Steve Gehrman on 8/3/04.
//  Copyright 2004 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#define NTViewFrameDidChangeNotification @"NTViewFrameDidChangeNotification"

// needed a simple way to knowing when a views frame changes, registering for NSViewFrameDidChangeNotification is too slow
// posting all those notifications is very sluggish, so I had to subclass NSView and now I call a method rather than post notifications

@interface NTView : NSView
{
    BOOL _frameDidChangeEnabled; // set a bool for speed, faster to check a bool than call an empty method if not needed
	BOOL _inFrameChanged;
	
	BOOL _postsFrameDidChangeNotifications;
	BOOL _automaticallyResizeSubviewToFit;
	NSSize _autoresizeInset;
	NSSize mv_automaticResizeSizeAdjustment;
	NSPoint mv_automaticResizeOriginAdjustment;
	
    NSInteger _callDepth; // only calls frameDidChange when zero, avoids problem of setFrame calling setFrameSize etc.
}

- (void)setFrameDidChangeEnabled:(BOOL)set;
- (BOOL)frameDidChangeEnabled;

- (void)setPostsFrameDidChangeNotification:(BOOL)set;
- (BOOL)postsFrameDidChangeNotification;

// override if you want to add a frame or something (see NTBoxView)
- (NSRect)contentBounds;

- (void)setAutomaticallyResizeSubviewToFit:(BOOL)set;
- (BOOL)automaticallyResizeSubviewToFit;

// default is 0,0 - the amount to inset any view that we are autoresizing (-1, -1 to hide a frame for example)
- (void)setAutomaticResizeInset:(NSSize)inset;
- (NSSize)automaticResizeInset;

- (NSSize)automaticResizeSizeAdjustment;
- (void)setAutomaticResizeSizeAdjustment:(NSSize)theAutomaticResizeSizeAdjustment;

- (NSPoint)automaticResizeOriginAdjustment;
- (void)setAutomaticResizeOriginAdjustment:(NSPoint)theAutomaticResizeOriginAdjustment;

// subclasses can override frameDidChange to respond to frame changes rather than registering for NSViewFrameDidChangeNotification
- (void)frameDidChange;

@end
