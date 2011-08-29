// -*- mode:objc -*-
// $Id: iTermApplicationDelegate.h,v 1.21 2006/11/21 19:24:29 yfabian Exp $
/*
 **  iTermApplicationDelegate.h
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

#import <Cocoa/Cocoa.h>

@class ITTerminalView;

@interface iTermApplicationDelegate : NSObject
{
	//Scrolling
    NSTimer	*scrollTimer;
	NSTimer	*eventLoopScrollTimer;
    float	scrollLocation;
    int		maxScroll;
    float   scrollRate;
    
    // Menu items
    IBOutlet NSMenu     *bookmarkMenu;
    IBOutlet NSMenuItem *selectTab;
    IBOutlet NSMenuItem *previousTerminal;
    IBOutlet NSMenuItem *nextTerminal;
    IBOutlet NSMenuItem *logStart;
    IBOutlet NSMenuItem *logStop;
    IBOutlet NSMenuItem *closeTab;
    IBOutlet NSMenuItem *closeWindow;
    IBOutlet NSMenuItem *sendInputToAllSessions;
	IBOutlet NSMenuItem *fontSizeFollowWindowResize;
	IBOutlet NSMenuItem *toggleBookmarksView;
    IBOutlet NSMenuItem *toggleTransparency;
}

// NSApplication Delegate methods
- (void)applicationWillFinishLaunching:(NSNotification *)aNotification;
- (BOOL) applicationShouldTerminate: (NSNotification *) theNotification;
- (BOOL)application:(NSApplication *)theApplication openFile:(NSString *)filename;
- (BOOL)applicationOpenUntitledFile:(NSApplication *)app;
- (NSMenu *)applicationDockMenu:(NSApplication *)sender;
- (void)applicationDidUnhide:(NSNotification *)aNotification;

- (IBAction)newWindow:(id)sender;
- (IBAction)buildScriptMenu:(id)sender;

- (IBAction)showPrefWindow:(id)sender;
- (IBAction)showBookmarkWindow:(id)sender;

// Notifications
- (void)reloadMenus: (NSNotification *) aNotification;
- (void)buildSessionSubmenu: (NSNotification *) aNotification;
- (void)buildAddressBookMenu: (NSNotification *) aNotification;
- (void)reloadSessionMenus: (NSNotification *) aNotification;

// font control
- (IBAction)biggerFont:(id)sender;
- (IBAction)smallerFont:(id)sender;

@end
