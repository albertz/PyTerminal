/*
 **  PTYTabView.m
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

#import "PTYTabView.h"
#import "PSMTabBarControl.h"

@implementation PTYTabView

// Class methods that Apple should have provided
+ (NSSize) contentSizeForFrameSize: (NSSize) frameSize tabViewType: (NSTabViewType) type controlSize: (NSControlSize) controlSize
{
    NSRect aRect, contentRect;
    NSTabView *aTabView;
    float widthOffset, heightOffset;

    // make a temporary tabview 
    aRect = NSMakeRect(0, 0, 200, 200);
    aTabView = [[NSTabView alloc] initWithFrame: aRect];
    [aTabView setTabViewType: type];
    [aTabView setControlSize: controlSize];

    // grab its content size
    contentRect = [aTabView contentRect];

    // calculate the offsets between total frame and content frame
    widthOffset = aRect.size.width - contentRect.size.width;
    heightOffset = aRect.size.height - contentRect.size.height;
    //NSLog(@"widthOffset = %f; heightOffset = %f", widthOffset, heightOffset);

    // release the temporary tabview
    [aTabView release];

    // Apply the offset to the given frame size
    return (NSMakeSize(frameSize.width - widthOffset, frameSize.height - heightOffset));
}

+ (NSSize) frameSizeForContentSize: (NSSize) contentSize tabViewType: (NSTabViewType) type controlSize: (NSControlSize) controlSize
{
    NSRect aRect, contentRect;
    NSTabView *aTabView;
    float widthOffset, heightOffset;

    // make a temporary tabview
    aRect = NSMakeRect(0, 0, 200, 200);
    aTabView = [[NSTabView alloc] initWithFrame: aRect];
    [aTabView setTabViewType: type];
    [aTabView setControlSize: controlSize];

    // grab its content size
    contentRect = [aTabView contentRect];

    // calculate the offsets between total frame and content frame
    widthOffset = aRect.size.width - contentRect.size.width;
    heightOffset = aRect.size.height - contentRect.size.height;
    //NSLog(@"widthOffset = %f; heightOffset = %f", widthOffset, heightOffset);

    // release the temporary tabview
    [aTabView release];

    // Apply the offset to the given content size
    return (NSMakeSize(contentSize.width + widthOffset, contentSize.height + heightOffset));
}

// we don't want this to be the first responder in the chain
- (BOOL)acceptsFirstResponder
{
    return (NO);
}

- (void)drawRect: (NSRect) rect
{
	//NSLog(@"%s", __PRETTY_FUNCTION__);
	
	[[NSNotificationCenter defaultCenter] postNotificationName: @"iTermTabViewWillRedraw" object: self];
	[super drawRect: rect];
	
}


// NSTabView methods overridden
- (void)addTabViewItem: (NSTabViewItem *) aTabViewItem
{
    // Let our delegate know
    id delegate = [self delegate];

	[delegate tabView: self willAddTabViewItem: aTabViewItem];
    
    [super addTabViewItem: aTabViewItem];
}

- (void)removeTabViewItem: (NSTabViewItem *) aTabViewItem
{
    // Let our delegate know
    id delegate = [self delegate];
    
	[delegate tabView: self willRemoveTabViewItem: aTabViewItem];
    
    // remove the item
    [super removeTabViewItem: aTabViewItem];
}

- (void)insertTabViewItem: (NSTabViewItem *) tabViewItem atIndex: (int) index
{
    // Let our delegate know
    id delegate = [self delegate];

    // Check the boundary
    if (index>[super numberOfTabViewItems]) {
        NSLog(@"Warning: index(%d) > numberOfTabViewItems(%d)", index, [super numberOfTabViewItems]);
        index = [super numberOfTabViewItems];
    }
    
	[delegate tabView: self willInsertTabViewItem: tabViewItem atIndex: index];    

    [super insertTabViewItem: tabViewItem atIndex: index];
}

// selects a tab from the contextual menu
- (void)selectTab:(id)sender
{
    [self selectTabViewItemWithIdentifier: [sender representedObject]];
}

@end
