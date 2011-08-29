//
//  ITTerminalWindowController.m
//  iTerm
//
//  Created by Steve Gehrman on 1/23/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "ITTerminalWindowController.h"
#import "PTToolbarController.h"
#import "ITTerminalView.h"
#import "PreferencePanel.h"
#import "iTermController.h"
#import "iTermOutlineView.h"
#import "PTYSession.h"
#import "Tree.h"
#import "iTermBookmarkController.h"
#import "ITConfigPanelController.h"
#import "FindPanelWindowController.h"
#import "PTYWindow.h"

@interface NSWindow (private)
- (void)setBottomCornerRounded:(BOOL)rounded;
@end

@interface ITTerminalWindowController (Private)
- (PTToolbarController *)toolbarController;
- (void)setToolbarController:(PTToolbarController *)theToolbarController;

- (NSOutlineView *)bookmarksView;
- (void)setBookmarksView:(NSOutlineView *)theBookmarksView;

- (BOOL)askUserToCloseWindow;
- (void)setupWindow;
@end

@interface ITTerminalWindowController (hidden)
- (void)setDrawer:(NSDrawer *)theDrawer;
- (void)setTerm:(ITTerminalView *)theTerm;
@end

@implementation ITTerminalWindowController

+ (ITTerminalWindowController*)controller:(NSDictionary*)dict;
{	
	ITTerminalWindowController* result=nil;
	
	PTYWindow *myWindow;
	unsigned int styleMask;
	
	// create the window programmatically with appropriate style mask
	styleMask = NSTitledWindowMask | 
		NSClosableWindowMask | 
		NSMiniaturizableWindowMask | 
		NSUnifiedTitleAndToolbarWindowMask |
		NSResizableWindowMask;
	
	styleMask |= NSTexturedBackgroundWindowMask;
	
	myWindow = [[[PTYWindow alloc] initWithContentRect: NSMakeRect(0,0,100,100)
											styleMask: styleMask 
											  backing: NSBackingStoreBuffered 
												defer: NO] autorelease];
		
	if (myWindow)
	{
		// init window controller with a window
		result = [[ITTerminalWindowController alloc] initWithWindow:myWindow];
		LEAKOK(result);

		[[result window] setDelegate:result];
		
		NSView *content = [[result window] contentView];
		[result setTerm:[ITTerminalView view:dict]];
		[[result term] setFrameSize:[content frame].size];
		[content addSubview:[result term]];

		[result setupWindow];
	}
	
	return result;  // releases self when done
}

//---------------------------------------------------------- 
// dealloc
//---------------------------------------------------------- 
- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];

	[self setDrawer:nil];
    [self setToolbarController:nil];
    [self setBookmarksView:nil];
    [self setTerm:nil];

    [super dealloc];
}

// this is a informal protocol so the app can get the terminal from the window
- (ITTerminalView*)currentTerminal
{
	return [self term];
}

- (BOOL)windowShouldClose:(NSNotification *)aNotification
{	
    if ([[PreferencePanel sharedInstance] promptOnClose] || ![[self term] terminalIsIdle:nil])
		return [self askUserToCloseWindow];
    else
		return (YES);
}

- (void)windowWillClose:(NSNotification *)aNotification
{    		
	[self autorelease];
}

- (void)windowDidBecomeKey:(NSNotification *)aNotification
{	
	// update the cursor
    [[[[self term] currentSession] textView] setNeedsDisplay: YES];
}

- (void)windowDidResignKey: (NSNotification *)aNotification
{		
    // update the cursor
    [[[[self term] currentSession] textView] setNeedsDisplay: YES];
}

- (NSRect)windowWillUseStandardFrame:(NSWindow *)sender defaultFrame:(NSRect)defaultFrame
{
	return [[self term] windowWillUseStandardFrame:defaultFrame];
}

// NSOutlineView doubleclick action
- (IBAction)doubleClickedOnBookmarksView:(id)sender
{
	int selectedRow = [[self bookmarksView] selectedRow];
	TreeNode *selectedItem;
	
	if (selectedRow < 0)
		return;
	
	selectedItem = [[self bookmarksView] itemAtRow: selectedRow];
	if (selectedItem != nil && [selectedItem isLeaf])
		[[iTermController sharedInstance] launchBookmark: [selectedItem nodeData] inTerminal: [self term]];
}

- (NSSize)drawerWillResizeContents:(NSDrawer *)sender toSize:(NSSize)contentSize
{
	// save the width to preferences
	[[NSUserDefaults standardUserDefaults] setFloat: contentSize.width forKey: @"BookmarksDrawerWidth"];
	
	return (contentSize);
}

- (void)_reloadAddressBook: (NSNotification *) aNotification
{
	[[self bookmarksView] reloadData];
}

//---------------------------------------------------------- 
//  term 
//---------------------------------------------------------- 
- (ITTerminalView *)term
{
    return mTerm; 
}

- (void)setTerm:(ITTerminalView *)theTerm
{
    if (mTerm != theTerm)
    {
        [mTerm release];
        mTerm = [theTerm retain];
    }
}

//---------------------------------------------------------- 
//  drawer 
//---------------------------------------------------------- 
- (NSDrawer *)drawer
{
    return mDrawer; 
}

- (void)setDrawer:(NSDrawer *)theDrawer
{
    if (mDrawer != theDrawer)
    {
        [mDrawer release];
        mDrawer = [theDrawer retain];
    }
}

@end

@implementation ITTerminalWindowController (Actions)

// Bookmarks
- (IBAction)toggleBookmarksView:(id)sender
{	
	[[self drawer] toggle: sender];	
}

- (void)printDocument:(id)sender;
{
	[(NSView*)[[self window] firstResponder] print:sender];
}

@end

@implementation ITTerminalWindowController (Private)

//---------------------------------------------------------- 
//  toolbarController 
//---------------------------------------------------------- 
- (PTToolbarController *)toolbarController
{
    return mToolbarController; 
}

- (void)setToolbarController:(PTToolbarController *)theToolbarController
{
    if (mToolbarController != theToolbarController)
    {
        [mToolbarController release];
        mToolbarController = [theToolbarController retain];
    }
}

//---------------------------------------------------------- 
//  bookmarksView 
//---------------------------------------------------------- 
- (NSOutlineView *)bookmarksView
{
    return mBookmarksView; 
}

- (void)setBookmarksView:(NSOutlineView *)theBookmarksView
{
    if (mBookmarksView != theBookmarksView)
    {
        [mBookmarksView release];
        mBookmarksView = [theBookmarksView retain];
    }
}

- (void)setupWindow;
{
	NSScrollView *aScrollView;
	NSTableColumn *aTableColumn;
	NSSize aSize;
	NSRect aRect;
					
	[self setToolbarController:[[[PTToolbarController alloc] initWithWindow:[self window] term:[self term]] autorelease]];
	
	if ([[self window] respondsToSelector:@selector(setBottomCornerRounded:)])
		[[self window] setBottomCornerRounded:NO];
				
	// create and set up drawer
	[self setDrawer: [[[NSDrawer alloc] initWithContentSize: NSMakeSize(20, 100) preferredEdge: NSMinXEdge] autorelease]];
	[[self drawer] setParentWindow:[self window]];
	[[self drawer] setDelegate:self];
	float aWidth = [[NSUserDefaults standardUserDefaults] floatForKey: @"BookmarksDrawerWidth"];
	if (aWidth<=0)
		aWidth = 150.0;
	[[self drawer] setContentSize: NSMakeSize(aWidth, 0)];
	
	aScrollView = [[NSScrollView alloc] initWithFrame:NSMakeRect(0, 0, 20, 100)];
	[aScrollView setBorderType:NSBezelBorder];
	[aScrollView setHasHorizontalScroller: NO];
	[aScrollView setHasVerticalScroller: YES];
	[[aScrollView verticalScroller] setControlSize:NSSmallControlSize];
	[aScrollView setAutohidesScrollers: YES];
	aSize = [aScrollView contentSize];
	aRect = NSZeroRect;
	aRect.size = aSize;
	
	[self setBookmarksView:[[[iTermOutlineView alloc] initWithFrame:aRect] autorelease]];
	aTableColumn = [[NSTableColumn alloc] initWithIdentifier: @"Name"];
	[[aTableColumn headerCell] setStringValue: NTLocalizedStringFromTableInBundle(@"Bookmarks",@"iTerm", [NSBundle bundleForClass: [self class]], @"Bookmarks")];
	[[self bookmarksView] addTableColumn: aTableColumn];
	[aTableColumn release];
	[[self bookmarksView] setOutlineTableColumn: aTableColumn];
	[[self bookmarksView] setDelegate: self];
	[[self bookmarksView] setTarget: self];
	[[self bookmarksView] setDoubleAction: @selector(doubleClickedOnBookmarksView:)];	
	[[self bookmarksView] setDataSource: [iTermBookmarkController sharedInstance]];
	
	[aScrollView setDocumentView:[self bookmarksView]];
	[[self drawer] setContentView: aScrollView];
	[aScrollView release];
	
	[[NSNotificationCenter defaultCenter] addObserver: self
											 selector: @selector(_reloadAddressBook:)
												 name: @"iTermReloadAddressBook"
											   object: nil];	
	
	[[self window] setFrame:NSMakeRect(0,0,612, 792) display:NO];
	[[self window] center];
	[self setWindowFrameAutosaveName:NSStringFromClass([self class])];
	
	NSWindow *topWindow = [[[iTermController sharedInstance] currentTerminal] window];
	if (topWindow)
	{
		NSPoint topLeft = [topWindow frame].origin;
		topLeft.y += [topWindow frame].size.height;
		topLeft = [[self window] cascadeTopLeftFromPoint:topLeft];
		[[self window] cascadeTopLeftFromPoint:topLeft];
	}
	
	[[self window] setAlphaValue:0.9999];

	[self showWindow:nil];
}

// Close Window
- (BOOL)askUserToCloseWindow
{		
	return (NSRunAlertPanel(NTLocalizedStringFromTableInBundle(@"Close Window?",@"iTerm", [NSBundle bundleForClass: [self class]], @"Close window"),
                            NTLocalizedStringFromTableInBundle(@"All sessions will be closed",@"iTerm", [NSBundle bundleForClass: [self class]], @"Close window"),
							NTLocalizedStringFromTableInBundle(@"OK",@"iTerm", [NSBundle bundleForClass: [self class]], @"OK"),
                            NTLocalizedStringFromTableInBundle(@"Cancel",@"iTerm", [NSBundle bundleForClass: [self class]], @"Cancel")
							,nil)==NSAlertDefaultReturn);
}

@end

