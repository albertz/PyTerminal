// -*- mode:objc -*-
// $Id: iTermController.m,v 1.66 2007/01/23 04:46:12 yfabian Exp $
/*
 **  iTermController.m
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

#import "iTermController.h"
#import "PreferencePanel.h"
#import "ITTerminalView.h"
#import "PTYSession.h"
#import "VT100Screen.h"
#import "NSStringITerm.h"
#import "ITAddressBookMgr.h"
#import "Tree.h"
#import "ITConfigPanelController.h"
#import "iTermProfileWindowController.h"
#import "iTermBookmarkController.h"
#import "iTermKeyBindingMgr.h"
#import "iTermDisplayProfileMgr.h"
#import "iTermTerminalProfileMgr.h"
#import "ITTerminalWindowController.h"

static NSString* APPLICATION_SUPPORT_DIRECTORY = @"~/Library/Application Support";
static NSString *SUPPORT_DIRECTORY = @"~/Library/Application Support/iTerm";
static NSString *SCRIPT_DIRECTORY = @"~/Library/Application Support/iTerm/Scripts";

static NSInteger _compareEncodingByLocalizedName(id a, id b, void *unused);

@interface iTermController (Private)
- (ITTerminalView*)launchBookmark: (NSDictionary *) bookmarkData
			inTerminal: (ITTerminalView *) theTerm
		   withCommand: (NSString *)command
			   withURL: (NSString *)url;
@end

@implementation iTermController

// must call this at least once
+ (void)initITerm;
{
	static BOOL hasBeenInitialized = NO;
	
	if (!hasBeenInitialized)
	{
		hasBeenInitialized = YES;
		
		NSMutableDictionary *profilesDictionary, *keybindingProfiles, *displayProfiles, *terminalProfiles;
		NSString *plistFile;
		NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
		
		// load saved profiles or default if we don't have any
		keybindingProfiles = [prefs objectForKey: @"iTermKeyBindings"];
		displayProfiles =  [prefs objectForKey: @"iTermDisplays"];
		terminalProfiles = [prefs objectForKey: @"iTermTerminals"];
		
		// if we got no profiles, load from our embedded plist
		plistFile = [[NSBundle bundleForClass: [self class]] pathForResource:@"Profiles" ofType:@"plist"];
		profilesDictionary = [NSDictionary dictionaryWithContentsOfFile: plistFile];
		if ([keybindingProfiles count] == 0)
			keybindingProfiles = [profilesDictionary objectForKey: @"iTermKeyBindings"];
		if ([displayProfiles count] == 0)
			displayProfiles = [profilesDictionary objectForKey: @"iTermDisplays"];
		if ([terminalProfiles count] == 0)
			terminalProfiles = [profilesDictionary objectForKey: @"iTermTerminals"];
		
		[[iTermKeyBindingMgr singleInstance] setProfiles: keybindingProfiles];
		[[iTermDisplayProfileMgr singleInstance] setProfiles: displayProfiles];
		[[iTermTerminalProfileMgr singleInstance] setProfiles: terminalProfiles];
		
		// more random stuff
		[iTermBookmarkController sharedInstance];
		[PreferencePanel sharedInstance];		
	}
}

+ (iTermController*)sharedInstance;
{
    static iTermController* shared = nil;
    
    if (!shared)
        shared = [[iTermController alloc] init];
    
    return shared;
}

// init
- (id)init
{
    self = [super init];
	
	// read preferences
	[iTermController initITerm];
    
    // create the iTerm directory if it does not exist
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    // create the "~/Library/Application Support" directory if it does not exist
    if ([fileManager fileExistsAtPath: [APPLICATION_SUPPORT_DIRECTORY stringByExpandingTildeInPath]] == NO)
        [fileManager createDirectoryAtPath: [APPLICATION_SUPPORT_DIRECTORY stringByExpandingTildeInPath] withIntermediateDirectories:NO attributes: nil error:nil];
    
    if ([fileManager fileExistsAtPath: [SUPPORT_DIRECTORY stringByExpandingTildeInPath]] == NO)
        [fileManager createDirectoryAtPath: [SUPPORT_DIRECTORY stringByExpandingTildeInPath] withIntermediateDirectories:NO attributes: nil error:nil];
	
    return (self);
}

- (void)dealloc
{        
    [super dealloc];
}

- (void)newWindowWithDirectory:(NSString*)path;
{
	ITTerminalView* term = [self launchBookmark:nil inTerminal:nil withCommand:nil];
		
	path = [path stringWithShellCharactersEscaped:NO];
	[term runCommand:[NSString stringWithFormat:@"cd \"%@\"", path]];
}

- (ITTerminalView *)currentTerminal;
{
	NSEnumerator *enumerator = [[NSApp orderedWindows] objectEnumerator];
	NSWindow* window;
	
	while (window = [enumerator nextObject])
	{
		if ([window isVisible])
		{
			id delegate = [window delegate];
			
			if ([delegate respondsToSelector:@selector(currentTerminal)])
				return [delegate currentTerminal];
		}
	}
	
	return nil;
}

// Action methods
- (IBAction)newWindow:(id)sender
{
    [self launchBookmark:nil inTerminal: nil];
}

// Open all childs within a given window
- (ITTerminalView *) newSessionsInWindow:(ITTerminalView *) terminal forNode:(TreeNode*)theNode
{
	NSEnumerator *entryEnumerator;
	TreeNode *childNode;
	ITTerminalView *term =terminal;
	
	entryEnumerator = [[theNode children] objectEnumerator];
	
	while ((childNode = [entryEnumerator nextObject]))
	{
		if ([childNode isGroup])
			[self newSessionsInWindow:terminal forNode:childNode];
		else
		{
			if (!term) 
				term = [[ITTerminalWindowController controller:[childNode nodeData]] term];
			
			[self launchBookmark:[childNode nodeData] inTerminal:term];
		}
	}
	
	return term;
}

- (void)newSessionsInWindow:(id)sender
{
	[self newSessionsInWindow:[self currentTerminal] forNode:[sender representedObject]];
}

- (void)newSessionsInNewWindow:(id)sender
{
	[self newSessionsInWindow:nil forNode:[sender representedObject]];
}

- (IBAction)newSession:(id)sender
{
    [self launchBookmark:nil inTerminal: [self currentTerminal]];
}

// Build sorted list of encodings
- (NSArray *) sortedEncodingList
{
	NSStringEncoding const *p;
	NSMutableArray *tmp = [NSMutableArray array];
	
	for (p = [NSString availableStringEncodings]; *p; ++p)
		[tmp addObject:[NSNumber numberWithUnsignedInt:*p]];
	[tmp sortUsingFunction: _compareEncodingByLocalizedName context:NULL];
	
	return (tmp);
}

- (void)alternativeMenu: (NSMenu *)aMenu forNode: (TreeNode *) theNode target:(id)aTarget;
{
    NSMenu *subMenu;
	NSMenuItem *aMenuItem;
	NSEnumerator *entryEnumerator;
	NSDictionary *dataDict;
	TreeNode *childNode;
	unsigned int modifierMask = NSCommandKeyMask | NSControlKeyMask;
	int count = 0;
    
	entryEnumerator = [[theNode children] objectEnumerator];
	
	while ((childNode = [entryEnumerator nextObject]))
	{
		count ++;
		dataDict = [childNode nodeData];
		
		if ([childNode isGroup])
		{
			aMenuItem = [[[NSMenuItem alloc] initWithTitle: [dataDict objectForKey: KEY_NAME] action:@selector(newSessionInTabAtIndex:) keyEquivalent:@""] autorelease];
			subMenu = [[[NSMenu alloc] init] autorelease];
            [self alternativeMenu: subMenu forNode: childNode target: aTarget]; 
			[aMenuItem setSubmenu: subMenu];
			[aMenuItem setAction:0];
			[aMenuItem setTarget: aTarget];
			[aMenu addItem: aMenuItem];
		}
		else
		{			
			aMenuItem = [[[NSMenuItem alloc] initWithTitle: [dataDict objectForKey: KEY_NAME] action:@selector(newSessionInTabAtIndex:) keyEquivalent:@""] autorelease];
            [aMenuItem setRepresentedObject:dataDict];
			[aMenuItem setTarget: aTarget];
			[aMenuItem setKeyEquivalentModifierMask: NSCommandKeyMask];
			[aMenu addItem: aMenuItem];
			
			aMenuItem = [[[NSMenuItem alloc] initWithTitle: [dataDict objectForKey: KEY_NAME] action:@selector(newSessionInWindowAtIndex:) keyEquivalent:@""] autorelease];
			[aMenuItem setKeyEquivalentModifierMask: NSCommandKeyMask | NSAlternateKeyMask];
			[aMenuItem setRepresentedObject:dataDict];
			[aMenuItem setTarget: aTarget];
			[aMenuItem setAlternate:YES];
			[aMenu addItem: aMenuItem];
		}                
	}
	
	if (count>1) {
		[aMenu addItem:[NSMenuItem separatorItem]];
		aMenuItem = [[[NSMenuItem alloc] initWithTitle: @"Open All" action:@selector(newSessionsInWindow:) keyEquivalent:@""] autorelease];
		[aMenuItem setKeyEquivalentModifierMask: modifierMask];
		[aMenuItem setRepresentedObject: theNode];
		[aMenuItem setTarget: self];
		[aMenu addItem: aMenuItem];
		aMenuItem = [[aMenuItem copy] autorelease];
		[aMenuItem setKeyEquivalentModifierMask: modifierMask | NSAlternateKeyMask];
		[aMenuItem setAlternate:YES];
		[aMenuItem setAction: @selector(newSessionsInNewWindow:)];
		[aMenuItem setTarget: self];
		[aMenu addItem: aMenuItem];
	}
}

// Executes an addressbook command in new window or tab
- (ITTerminalView*)launchBookmark:(NSDictionary *)bookmarkData 
			inTerminal:(ITTerminalView *)theTerm;
{
	return [self launchBookmark:bookmarkData
			  inTerminal:theTerm
			 withCommand:nil
				 withURL:nil];
}

- (ITTerminalView*)launchBookmark:(NSDictionary *)bookmarkData
			inTerminal:(ITTerminalView *)theTerm 
			   withURL:(NSString *)url;
{
	return [self launchBookmark:bookmarkData
			  inTerminal:theTerm
			 withCommand:nil
				 withURL:url];
}

- (ITTerminalView*)launchBookmark:(NSDictionary *)bookmarkData
			inTerminal:(ITTerminalView *)theTerm 
		   withCommand:(NSString *)command;
{
	return [self launchBookmark:bookmarkData
			  inTerminal:theTerm
			 withCommand:command
				 withURL:nil];
}

- (void)launchScript:(id)sender
{
    NSString *fullPath = [NSString stringWithFormat: @"%@/%@", [SCRIPT_DIRECTORY stringByExpandingTildeInPath], [sender title]];
	
	if ([[[sender title] pathExtension] isEqualToString: @"scpt"]) {
		NSAppleScript *script;
		NSDictionary *errorInfo = [NSDictionary dictionary];
		NSURL *aURL = [NSURL fileURLWithPath: fullPath];
		
		// Make sure our script suite registry is loaded
		[NSScriptSuiteRegistry sharedScriptSuiteRegistry];
		
		script = [[NSAppleScript alloc] initWithContentsOfURL: aURL error: &errorInfo];
		[script executeAndReturnError: &errorInfo];
		[script release];
	}
	else {
		[[NSWorkspace sharedWorkspace] launchApplication:fullPath];
	}
}

- (PTYTextView *) frontTextView
{
    return ([[[self currentTerminal] currentSession] textView]);
}

@end

@implementation iTermController (Private)

- (ITTerminalView*)launchBookmark: (NSDictionary *) bookmarkData
			inTerminal: (ITTerminalView *) theTerm
		   withCommand: (NSString *)command
			   withURL: (NSString *)url;
{
    ITTerminalView *term;
    NSDictionary *aDict;
	
	aDict = bookmarkData;
	if (aDict == nil)
		aDict = [[ITAddressBookMgr sharedInstance] defaultBookmarkData];
	
    if (!theTerm)
        term = [[ITTerminalWindowController controller:aDict] term];		
    else
        term = theTerm;
	
	if (url)
		[term addNewSession: aDict withCommand:nil withURL: url];
	else
		[term addNewSession: aDict withCommand: command withURL:nil];
	
	return term;
}

@end

// Comparator for sorting encodings
static NSInteger _compareEncodingByLocalizedName(id a, id b, void *unused)
{
	NSString *sa = [NSString localizedNameOfStringEncoding: [a unsignedIntValue]];
	NSString *sb = [NSString localizedNameOfStringEncoding: [b unsignedIntValue]];
	return [sa caseInsensitiveCompare: sb];
}

