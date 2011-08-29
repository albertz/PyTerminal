/*
 **  PTYTabView.h
 **
 **  Copyright (c) 2002, 2003
 **
 **  Author: Ujwal S. Setlur
 **
 **  Project: iTerm
 **
 **  Description: NSTabView subclass. Implements drag and drop.
 **
 */

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

@interface PTYTabView : NSTabView {
}

// Class methods that Apple should have provided
+ (NSSize) contentSizeForFrameSize: (NSSize) frameSize tabViewType: (NSTabViewType) type controlSize: (NSControlSize) controlSize;
+ (NSSize) frameSizeForContentSize: (NSSize) contentSize tabViewType: (NSTabViewType) type controlSize: (NSControlSize) controlSize;

- (BOOL)acceptsFirstResponder;
- (void)drawRect: (NSRect) rect;

// NSTabView methods overridden
- (void)addTabViewItem: (NSTabViewItem *) aTabViewItem;
- (void)removeTabViewItem: (NSTabViewItem *) aTabViewItem;
- (void)insertTabViewItem: (NSTabViewItem *) tabViewItem atIndex: (int) index;

// selects a tab from the contextual menu
- (void)selectTab:(id)sender;

@end
