// -*- mode:objc -*-
// $Id: iTermApplicationDelegate.m,v 1.51 2007/01/23 04:46:12 yfabian Exp $
/*
 **  iTermApplicationDelegate.m
 **
 **  Copyright (c) 2002, 2003
 **
 **  Author: Fabian, Ujwal S. Setlur
 **	     Initial code by Kiichi Kusama
 **
 **  Project: iTerm
 **
 **  Description: Implements the main application delegate and handles the addressbook functions.
 **
 */

#import "iTermApplicationDelegate.h"
#import "iTermController.h"
#import "ITAddressBookMgr.h"
#import "PreferencePanel.h"
#import "ITTerminalView.h"
#import "PTYSession.h"
#import "VT100Terminal.h"
#import "FindPanelWindowController.h"
#import "PTYWindow.h"
#import "iTermProfileWindowController.h"
#import "iTermBookmarkController.h"
#import "iTermDisplayProfileMgr.h"
#import "Tree.h"
#import "ITTerminalWindowController.h"

static NSString *SCRIPT_DIRECTORY = @"~/Library/Application Support/iTerm/Scripts";
static NSString* AUTO_LAUNCH_SCRIPT = @"~/Library/Application Support/iTerm/AutoLaunch.scpt";

static BOOL usingAutoLaunchScript = NO;

#define ABOUT_SCROLL_FPS	30.0
#define ABOUT_SCROLL_RATE	1.0

@implementation iTermApplicationDelegate

// NSApplication delegate methods
- (void)applicationWillFinishLaunching:(NSNotification *)aNotification
{
    // Check the system version for minimum requirements.
    SInt32 gSystemVersion;    
    Gestalt(gestaltSystemVersion, &gSystemVersion);
    if (gSystemVersion < 0x1020)
    {
		NSRunAlertPanel(NTLocalizedStringFromTableInBundle(@"Sorry",@"iTerm", [NSBundle bundleForClass: [iTermController class]], @"Sorry"),
			 NTLocalizedStringFromTableInBundle(@"Minimum_OS", @"iTerm", [NSBundle bundleForClass: [iTermController class]], @"OS Version"),
			NTLocalizedStringFromTableInBundle(@"Quit",@"iTerm", [NSBundle bundleForClass: [iTermController class]], @"Quit"),
			 nil, nil);
		[NSApp terminate: self];
    }

    // set the TERM_PROGRAM environment variable
    putenv("TERM_PROGRAM=iTerm.app");

	[self buildScriptMenu:nil];
	
#if MAC_OS_X_VERSION_MAX_ALLOWED >= MAC_OS_X_VERSION_10_4
	NSString *patherAppCast = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"SUFeedURL"];
	[[NSUserDefaults standardUserDefaults] setObject: patherAppCast forKey:@"SUFeedURL"];
#else
	NSString *patherAppCast = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"SUFeedURLForPanther"];
	[[NSUserDefaults standardUserDefaults] setObject: patherAppCast forKey:@"SUFeedURL"];
#endif
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	[self buildAddressBookMenu:nil];
	
	// register for services
	[NSApp registerServicesMenuSendTypes: [NSArray arrayWithObjects: NSStringPboardType, nil]
							 returnTypes: [NSArray arrayWithObjects: NSFilenamesPboardType, NSStringPboardType, nil]];
}

- (BOOL) applicationShouldTerminate: (NSNotification *) theNotification
{
	NSArray *terminals;
	
	// Display prompt if we need to
	terminals = nil; // SNG disabled [[iTermController sharedInstance] terminals];
    if (([terminals count] > 0) && 
	   [[PreferencePanel sharedInstance] promptOnClose] && 
	   NSRunAlertPanel(NTLocalizedStringFromTableInBundle(@"Quit iTerm?",@"iTerm", [NSBundle bundleForClass: [self class]], @"Close window"),
					   NTLocalizedStringFromTableInBundle(@"All sessions will be closed",@"iTerm", [NSBundle bundleForClass: [self class]], @"Close window"),
					   NTLocalizedStringFromTableInBundle(@"OK",@"iTerm", [NSBundle bundleForClass: [self class]], @"OK"),
					   NTLocalizedStringFromTableInBundle(@"Cancel",@"iTerm", [NSBundle bundleForClass: [self class]], @"Cancel")
					   ,nil)!=NSAlertDefaultReturn)
		return (NO);
    
	// save preferences
	[[PreferencePanel sharedInstance] savePreferences];
	
    return (YES);
}

- (BOOL)application:(NSApplication *)theApplication openFile:(NSString *)filename
{		
	if (filename) {
		NSString *aString = [NSString stringWithFormat:@"\"%@\"", filename];
		[[iTermController sharedInstance] launchBookmark:nil inTerminal:nil withCommand:aString];
	}
	return (YES);
}

- (BOOL)applicationOpenUntitledFile:(NSApplication *)app
{
    // Check if we have an autolauch script to execute. Do it only once, i.e. at application launch.
    if (usingAutoLaunchScript == NO &&
       [[NSFileManager defaultManager] fileExistsAtPath: [AUTO_LAUNCH_SCRIPT stringByExpandingTildeInPath]])
    {
		usingAutoLaunchScript = YES;
		
		NSAppleScript *autoLaunchScript;
		NSDictionary *errorInfo = [NSDictionary dictionary];
		NSURL *aURL = [NSURL fileURLWithPath: [AUTO_LAUNCH_SCRIPT stringByExpandingTildeInPath]];
		
		// Make sure our script suite registry is loaded
		[NSScriptSuiteRegistry sharedScriptSuiteRegistry];
		
		autoLaunchScript = [[NSAppleScript alloc] initWithContentsOfURL: aURL error: &errorInfo];
		[autoLaunchScript executeAndReturnError: &errorInfo];
		[autoLaunchScript release];
    }
    else {
        if ([[PreferencePanel sharedInstance] openBookmark])
            [self showBookmarkWindow:nil];
        else
            [self newWindow:nil];
    }
    usingAutoLaunchScript = YES;

    return YES;
}

// sent when application is made visible after a hide operation. Should not really need to implement this,
// but some users reported that keyboard input is blocked after a hide/unhide operation.
- (void)applicationDidUnhide:(NSNotification *)aNotification
{
	// ITTerminalView *frontTerminal = [[iTermController sharedInstance] currentTerminal];
    // Make sure that the first responder stuff is set up OK.
    // [frontTerminal selectSessionAtIndex: [frontTerminal currentSessionIndex]];
}

// init
- (id)init
{
    self = [super init];

    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(buildAddressBookMenu:)
                                                 name: @"iTermReloadAddressBook"
                                               object: nil];

    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(buildSessionSubmenu:)
                                                 name: @"iTermNumberOfSessionsDidChange"
                                               object: nil];
        
	[[NSAppleEventManager sharedAppleEventManager] setEventHandler:self andSelector:@selector(getUrl:withReplyEvent:) forEventClass:kInternetEventClass andEventID:kAEGetURL];
	
    return self;
}

- (void)getUrl:(NSAppleEventDescriptor *)event withReplyEvent:(NSAppleEventDescriptor *)replyEvent
{
	NSString *urlStr = [[event paramDescriptorForKeyword:keyDirectObject] stringValue];
	NSURL *url = [NSURL URLWithString: urlStr];
	NSString *urlType = [url scheme];

	id bm = [[PreferencePanel sharedInstance] handlerBookmarkForURL: urlType];

	//NSLog(@"Got the URL:%@\n%@", urlType, bm);
	[[iTermController sharedInstance] launchBookmark:[bm nodeData] inTerminal:[[iTermController sharedInstance] currentTerminal] withURL:urlStr];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    [super dealloc];
}

// Action methods
- (IBAction)newWindow:(id)sender
{
    [[iTermController sharedInstance] newWindow:sender];
}

- (IBAction)showPrefWindow:(id)sender
{
    [[PreferencePanel sharedInstance] run];
}

- (IBAction)showBookmarkWindow:(id)sender
{	
    [[iTermBookmarkController sharedInstance] showWindow];
}

- (IBAction)showProfileWindow:(id)sender
{	
    [[iTermProfileWindowController sharedInstance] showProfilesWindow: nil];
}

- (NSMenu *)applicationDockMenu:(NSApplication *)sender
{
    NSMenu *aMenu, *bookmarksMenu;
    NSMenuItem *newMenuItem;
	ITTerminalView *frontTerminal;
    
    aMenu = [[NSMenu alloc] initWithTitle: @"Dock Menu"];
    //new session menu
	newMenuItem = [[NSMenuItem alloc] initWithTitle: NTLocalizedStringFromTableInBundle(@"New",@"iTerm", [NSBundle bundleForClass: [self class]], @"Context menu") action:nil keyEquivalent:@"" ]; 
    [aMenu addItem: newMenuItem];
    [newMenuItem release];
    
    // Create the bookmark submenus for new session
	frontTerminal = [[iTermController sharedInstance] currentTerminal];
    // Build the bookmark menu
	bookmarksMenu = [[[NSMenu alloc] init] autorelease];
    [[iTermController sharedInstance] alternativeMenu: bookmarksMenu 
                                              forNode: [[ITAddressBookMgr sharedInstance] rootNode] 
                                               target: frontTerminal];
	[newMenuItem setSubmenu: bookmarksMenu];

	[bookmarksMenu addItem: [NSMenuItem separatorItem]];
    
	NSMenuItem *tip = [[[NSMenuItem alloc] initWithTitle: NTLocalizedStringFromTableInBundle(@"Press Option for New Window",@"iTerm", [NSBundle bundleForClass: [self class]], @"Toolbar Item: New") action:@selector(xyz) keyEquivalent: @""] autorelease];
    [tip setKeyEquivalentModifierMask: 0];
    [bookmarksMenu addItem: tip];
    tip = [[tip copy] autorelease];
    [tip setTitle:NTLocalizedStringFromTableInBundle(@"Open In New Window",@"iTerm", [NSBundle bundleForClass: [self class]], @"Toolbar Item: New")];
    [tip setKeyEquivalentModifierMask: NSAlternateKeyMask];
    [tip setAlternate:YES];
    [bookmarksMenu addItem: tip];
    return ([aMenu autorelease]);
}

// font control
- (IBAction)biggerFont:(id)sender
{
    [[[iTermController sharedInstance] currentTerminal] changeFontSize: YES];
}

- (IBAction)smallerFont:(id)sender
{
    [[[iTermController sharedInstance] currentTerminal] changeFontSize: NO];
}

- (void)newTabAction:(id)sender;
{
    [[iTermController sharedInstance] launchBookmark:nil inTerminal:nil];
}

// Notifications
- (void)reloadMenus: (NSNotification *) aNotification
{	
    ITTerminalView *frontTerminal = [[iTermController sharedInstance] currentTerminal];
    if (frontTerminal != [aNotification object]) return;
	
	unsigned int drawerState;

	[previousTerminal setAction: (frontTerminal?@selector(previousTerminal:):nil)];
	[nextTerminal setAction: (frontTerminal?@selector(nextTerminal:):nil)];

	[self buildSessionSubmenu: aNotification];
	[self buildAddressBookMenu: aNotification];
	// reset the close tab/window shortcuts
	[closeTab setAction: @selector(closeTabAction:)];
	[closeTab setTarget: frontTerminal];
	[closeTab setKeyEquivalent: @"w"];
	[closeWindow setKeyEquivalent: @"W"];
	[closeWindow setKeyEquivalentModifierMask: NSCommandKeyMask];


	// set some menu item states
	if (frontTerminal && [[frontTerminal tabView] numberOfTabViewItems]) {
		[toggleBookmarksView setEnabled:YES];
		[toggleTransparency setEnabled:YES];
		[fontSizeFollowWindowResize setEnabled:YES];
		[sendInputToAllSessions setEnabled:YES];

		if ([frontTerminal sendInputToAllSessions] == YES)
		[sendInputToAllSessions setState: NSOnState];
		else
		[sendInputToAllSessions setState: NSOffState];
		
		// reword some menu items
		drawerState = [[(ITTerminalWindowController*)[[frontTerminal window] delegate] drawer] state];
		if (drawerState == NSDrawerClosedState || drawerState == NSDrawerClosingState)
		{
			[toggleBookmarksView setTitle: 
				NTLocalizedStringFromTableInBundle(@"Show Bookmark Drawer", @"iTerm", [NSBundle bundleForClass: [self class]], @"Bookmarks")];
		}
		else
		{
			[toggleBookmarksView setTitle: 
				NTLocalizedStringFromTableInBundle(@"Hide Bookmarks Drawer", @"iTerm", [NSBundle bundleForClass: [self class]], @"Bookmarks")];
		}
	}
	else {
		[toggleBookmarksView setEnabled:NO];
		[toggleTransparency setEnabled:NO];
		[fontSizeFollowWindowResize setEnabled:NO];
		[sendInputToAllSessions setEnabled:NO];
	}
}

- (void)buildSessionSubmenu: (NSNotification *) aNotification
{
	// build a submenu to select tabs
	ITTerminalView *currentTerminal = [[iTermController sharedInstance] currentTerminal];
	
	if (currentTerminal != [aNotification object] || ![[currentTerminal window] isKeyWindow]) return;
	
    NSMenu *aMenu = [[NSMenu alloc] initWithTitle: @"SessionMenu"];
    PTYTabView *aTabView = [currentTerminal tabView];
    PTYSession *aSession;
    NSArray *tabViewItemArray = [aTabView tabViewItems];
	NSEnumerator *enumerator = [tabViewItemArray objectEnumerator];
	NSTabViewItem *aTabViewItem;
	int i=1;
	
    // clear whatever menu we already have
    [selectTab setSubmenu: nil];

	while ((aTabViewItem = [enumerator nextObject])) {
		aSession = [aTabViewItem identifier];
        NSMenuItem *aMenuItem;
		
        if (i < 10)
        {
            aMenuItem  = [[NSMenuItem alloc] initWithTitle: [aSession name] action: @selector(selectSessionAtIndexAction:) keyEquivalent: [NSString stringWithFormat: @"%d", i]];
            [aMenuItem setTag: i-1];
			
            [aMenu addItem: aMenuItem];
            [aMenuItem release];
        }
		i++;
	}

    [selectTab setSubmenu: aMenu];

    [aMenu release];
}

- (void)buildAddressBookMenu : (NSNotification *) aNotification
{
    // clear Bookmark menu
    for (; [bookmarkMenu numberOfItems]>7;) [bookmarkMenu removeItemAtIndex: 7];
    
    // add bookmarks into Bookmark menu
    [[iTermController sharedInstance] alternativeMenu: bookmarkMenu 
                                              forNode: [[ITAddressBookMgr sharedInstance] rootNode] 
                                               target: [[iTermController sharedInstance] currentTerminal]];    
}

- (void)reloadSessionMenus: (NSNotification *) aNotification
{
	ITTerminalView *currentTerminal = [[iTermController sharedInstance] currentTerminal];
    PTYSession *aSession = [aNotification object];

	if (currentTerminal != [aSession parent] || ![[currentTerminal window] isKeyWindow]) return;

    if (aSession == nil || [aSession exited]) {
		[logStart setEnabled: NO];
		[logStop setEnabled: NO];
		[toggleTransparency setEnabled: NO];
	}
	else {
		[logStart setEnabled: ![aSession logging]];
		[logStop setEnabled: [aSession logging]];
		[toggleTransparency setState: [currentTerminal useTransparency] ? NSOnState : NSOffState];
		[toggleTransparency setEnabled: YES];
	}
}

- (IBAction)buildScriptMenu:(id)sender
{
	if ([[[[NSApp mainMenu] itemAtIndex: 5] title] isEqualToString:@"Script"])
		[[NSApp mainMenu] removeItemAtIndex:5];

	// add our script menu to the menu bar
    // get image
    NSImage *scriptIcon = [NSImage imageNamed: @"script"];
    [scriptIcon setScalesWhenResized: YES];
    [scriptIcon setSize: NSMakeSize(16, 16)];
	
    // create menu item with no title and set image
    NSMenuItem *scriptMenuItem = [[NSMenuItem alloc] initWithTitle: @"" action: nil keyEquivalent: @""];
    [scriptMenuItem setImage: scriptIcon];
	
    // create submenu
    int count = 0;
    NSMenu *scriptMenu = [[NSMenu alloc] initWithTitle: NTLocalizedStringFromTableInBundle(@"Script",@"iTerm", [NSBundle bundleForClass: [iTermController class]], @"Script")];
    [scriptMenuItem setSubmenu: scriptMenu];
    // populate the submenu with ascripts found in the script directory
    NSDirectoryEnumerator *directoryEnumerator = [[NSFileManager defaultManager] enumeratorAtPath: [SCRIPT_DIRECTORY stringByExpandingTildeInPath]];
    NSString *file;
	
    while ((file = [directoryEnumerator nextObject]))
    {
		if ([[NSWorkspace sharedWorkspace] isFilePackageAtPath: [NSString stringWithFormat: @"%@/%@", [SCRIPT_DIRECTORY stringByExpandingTildeInPath], file]])
			[directoryEnumerator skipDescendents];
		
		if ([[file pathExtension] isEqualToString: @"scpt"] || [[file pathExtension] isEqualToString: @"app"] ) {
			NSMenuItem *scriptItem = [[NSMenuItem alloc] initWithTitle: file action: @selector(launchScript:) keyEquivalent: @""];
			[scriptItem setTarget: [iTermController sharedInstance]];
			[scriptMenu addItem: scriptItem];
			count ++;
			[scriptItem release];
		}
    }
	if (count>0) {
		[scriptMenu addItem:[NSMenuItem separatorItem]];
		NSMenuItem *scriptItem = [[NSMenuItem alloc] initWithTitle: NTLocalizedStringFromTableInBundle(@"Refresh",@"iTerm", [NSBundle bundleForClass: [iTermController class]], @"Script")
															action: @selector(buildScriptMenu:) 
													 keyEquivalent: @""];
		[scriptItem setTarget: self];
		[scriptMenu addItem: scriptItem];
		count ++;
		[scriptItem release];
	}
	[scriptMenu release];
	
    // add new menu item
    if (count) {
        [[NSApp mainMenu] insertItem: scriptMenuItem atIndex: 5];
        [scriptMenuItem release];
        [scriptMenuItem setTitle: NTLocalizedStringFromTableInBundle(@"Script",@"iTerm", [NSBundle bundleForClass: [iTermController class]], @"Script")];
    }
}

@end

