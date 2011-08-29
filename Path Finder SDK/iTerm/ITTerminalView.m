// -*- mode:objc -*-
// $Id: ITTerminalView.m,v 1.391 2007/01/23 04:46:12 yfabian Exp $
//
/*
 **  ITTerminalView.m
 **
 **  Copyright (c) 2002, 2003
 **
 **  Author: Fabian, Ujwal S. Setlur
 **	     Initial code by Kiichi Kusama
 **
 **  Project: iTerm
 **
 **  Description: Session and window controller for iTerm.
 **
 */

#import "iTerm.h"
#import "ITTerminalView.h"
#import "PTYScrollView.h"
#import "NSStringITerm.h"
#import "PTYSession.h"
#import "VT100Screen.h"
#import "PTYTabView.h"
#import "PreferencePanel.h"
#import "iTermController.h"
#import "PTYTask.h"
#import "PTYTextView.h"
#import "VT100Terminal.h"
#import "VT100Screen.h"
#import "PTYSession.h"
#import "PTToolbarController.h"
#import "FindPanelWindowController.h"
#import "ITAddressBookMgr.h"
#import "ITConfigPanelController.h"
#import "iTermTerminalProfileMgr.h"
#import "iTermDisplayProfileMgr.h"
#import "Tree.h"
#import <PSMTabBarControl.h>
#import <PSMTabStyle.h>
#import <iTermBookmarkController.h>
#import <iTermOutlineView.h>
#include <unistd.h>
#import "ITMiscNibController.h"
#import "ITTerminalWindowController.h"
#import "PTYWindow.h"
#import "iTermProfileWindowController.h"
#import "ITProcess.h"
#import "ITSharedActionHandler.h"

@interface ITTerminalView (Private)
- (BOOL)beingResized;
- (void)setBeingResized:(BOOL)flag;

- (BOOL)askUserToCloseTab:(PTYSession*)session;
- (NSArray*)runningProcesses:(PTYSession*)session;

- (void)setupView:(NSDictionary *)entry;

- (NSFont *) _getMaxFont:(NSFont* ) font 
				  height:(float) height
				   lines:(float) lines;

- (ITMiscNibController *)nibController;
- (void)setNibController:(ITMiscNibController *)theNibController;

- (BOOL)initialized;
- (void)setInitialized:(BOOL)flag;
@end

@interface ITTerminalView (hidden)
- (void)setTabView:(PTYTabView *)theTabView;
- (void)setTabBarControl:(PSMTabBarControl *)theTabBarControl;
@end

@implementation ITTerminalView

//---------------------------------------------------------- 
// dealloc
//---------------------------------------------------------- 
- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
    
	// Release all our sessions
    NSTabViewItem *aTabViewItem;
    while ([[self tabView] numberOfTabViewItems]) 
    {
        aTabViewItem = [[self tabView] tabViewItemAtIndex:0];
        [(PTYSession*)[aTabViewItem identifier] terminate];
        [[self tabView] removeTabViewItem: aTabViewItem];
    }
	
	[self setTabView:nil];
	[self setTabBarControl:nil];
    [self setNibController:nil];

    [super dealloc];
}

// Utility
+ (void) breakDown:(NSString *)cmdl cmdPath: (NSString **) cmd cmdArgs: (NSArray **) path
{
    int i,j,k,qf,slen;
    char tmp[100];
    const char *s;
    NSMutableArray *p;
    
    p=[[NSMutableArray alloc] init];
    
    s=[cmdl cStringUsingEncoding:NSUTF8StringEncoding];
    slen = strlen(s);
    
    i=j=qf=0;
    k=-1;
    while (i<=slen) {
        if (qf) {
            if (s[i]=='\"') {
                qf=0;
            }
            else {
                tmp[j++]=s[i];
            }
        }
        else {
            if (s[i]=='\"') {
                qf=1;
            }
            else if (s[i]==' ' || s[i]=='\t' || s[i]=='\n'||s[i]==0) {
                tmp[j]=0;
                if (k==-1) {
                    *cmd=[NSString stringWithUTF8String:tmp];
                }
                else
                    [p addObject:[NSString stringWithUTF8String:tmp]];
                j=0;
                k++;

				// SNG fixed
                while (i<slen && ((s[i+1] ==' ') || (s[i+1]=='\t') || (s[i+1]=='\n') || (s[i+1]==0)))
					i++;
            }
            else {
                tmp[j++]=s[i];
            }
        }
        i++;
    }
    
    *path = [NSArray arrayWithArray:p];
    [p release];
}

+ (ITTerminalView*)view:(NSDictionary *)entry;
{    
    ITTerminalView* result = [[ITTerminalView alloc] init];
	
	[result setupView:entry];

    [result setAutoresizingMask: NSViewWidthSizable|NSViewHeightSizable];
	
    return [result autorelease];
}

- (void)setupSession: (PTYSession *) aSession
		       title: (NSString *)title
{
    NSDictionary *addressBookPreferences;
    NSDictionary *tempPrefs;
	NSString *displayProfile;
	iTermDisplayProfileMgr *displayProfileMgr;
			
    NSParameterAssert(aSession != nil);    
	
	// get our shared managers
	displayProfileMgr = [iTermDisplayProfileMgr singleInstance];
	
    // Init the rest of the session
    [aSession setParent: self];
	
    // set some default parameters
    if ([aSession addressBookEntry] == nil)
    {
		// get the default entry
		addressBookPreferences = [[ITAddressBookMgr sharedInstance] defaultBookmarkData];
		[aSession setAddressBookEntry:addressBookPreferences];
		tempPrefs = addressBookPreferences;
    }
    else
		tempPrefs = [aSession addressBookEntry];
	
	displayProfile = [tempPrefs objectForKey: KEY_DISPLAY_PROFILE];
	
    if ([self width] == 0 && [self height] == 0)
    {
		[self setAntiAlias: [displayProfileMgr windowAntiAliasForProfile: displayProfile]];
    }
    [aSession initScreen: [[self tabView] contentRect] width:[self width] height:[self height]];
    if (FONT == nil) 
	{
		[self setFont: [displayProfileMgr windowFontForProfile: displayProfile] 
			   nafont: [displayProfileMgr windowNAFontForProfile: displayProfile]];
		[self setCharacterSpacingHorizontal: [displayProfileMgr windowHorizontalCharSpacingForProfile: displayProfile] 
								   vertical: [displayProfileMgr windowVerticalCharSpacingForProfile: displayProfile]];
    }
    
    [aSession setPreferencesFromAddressBookEntry: tempPrefs];
	 	
    [[aSession SCREEN] setDisplay:[aSession textView]];
	[[aSession textView] setFont:FONT nafont:NAFONT];
	[[aSession textView] setAntiAlias: antiAlias];
    [[aSession textView] setLineHeight: [self charHeight]];
	[[aSession textView] setCharWidth: [self charWidth]];
		
    [[aSession TERMINAL] setTrace:YES];	// debug vt100 escape sequence decode
	
    // tell the shell about our size
    [[aSession SHELL] setWidth:[self width]  height:[self height]];
	
    if (title) 
    {
        [self setWindowTitle: title];
        [aSession setName: title];
		[aSession setDefaultName: title];
    }
}

- (void)insertSession: (PTYSession *) aSession atIndex: (int) index
{
    NSTabViewItem *aTabViewItem;
	
    if (aSession == nil)
		return;
	
    if ([[self tabView] indexOfTabViewItemWithIdentifier: aSession] == NSNotFound)
    {
        // create a new tab
		aTabViewItem = [[NSTabViewItem alloc] initWithIdentifier: aSession];
		[aSession setTabViewItem: aTabViewItem];
		NSParameterAssert(aTabViewItem != nil);
		[aTabViewItem setLabel: [aSession name]];
		[aTabViewItem setView: [aSession view]];
        [[self tabView] insertTabViewItem: aTabViewItem atIndex: index];
		
        [aTabViewItem release];
		[[self tabView] selectTabViewItemAtIndex: index];
		
		[self setWindowSize];
    }
}

- (void)closeSession: (PTYSession*) aSession
{	
    NSTabViewItem *aTabViewItem;
	int numberOfSessions;
    	
    if ([[self tabView] indexOfTabViewItemWithIdentifier: aSession] == NSNotFound)
        return;
    
    numberOfSessions = [[self tabView] numberOfTabViewItems]; 
    if ([[self window] isKindOfClass:[PTYWindow class]] && (numberOfSessions == 1) && [self initialized])
    {   
		// only close if it's one of our windows, not an embedded views window or drawer window
		[[self window] close];
    }
	else {
         // now get rid of this session
        aTabViewItem = [aSession tabViewItem];
        [aSession terminate];
        [[self tabView] removeTabViewItem: aTabViewItem];
    }
}

- (IBAction)previousSession:(id)sender
{
    NSTabViewItem *tvi=[[self tabView] selectedTabViewItem];
    [[self tabView] selectPreviousTabViewItem: sender];
    if (tvi==[[self tabView] selectedTabViewItem]) [[self tabView] selectTabViewItemAtIndex: [[self tabView] numberOfTabViewItems]-1];
}

- (IBAction)nextSession:(id)sender
{
    NSTabViewItem *tvi=[[self tabView] selectedTabViewItem];
    [[self tabView] selectNextTabViewItem: sender];
    if (tvi==[[self tabView] selectedTabViewItem]) [[self tabView] selectTabViewItemAtIndex: 0];
}

- (NSString *) currentSessionName
{
    return ([[[[self tabView] selectedTabViewItem] identifier] defaultName]);
}

- (void)setCurrentSessionName: (NSString *) theSessionName
{
    NSMutableString *title = [NSMutableString string];
    PTYSession *aSession = [[[self tabView] selectedTabViewItem] identifier];
    
    if (theSessionName != nil)
    {
        [aSession setName: theSessionName];
        [aSession setDefaultName: theSessionName];
    }
    else {
        NSString *progpath = [NSString stringWithFormat: @"%@ #%d", [[[[aSession SHELL] path] pathComponents] lastObject], [[self tabView] indexOfTabViewItem:[[self tabView] selectedTabViewItem]]];
		
        if ([aSession exited])
            [title appendString:@"Finish"];
        else
            [title appendString:progpath];
		
        [aSession setName: title];
        [aSession setDefaultName: title];
    }
}

- (PTYSession *) currentSession
{
    return [[[self tabView] selectedTabViewItem] identifier];
}

- (int) currentSessionIndex
{
    return ([[self tabView] indexOfTabViewItem:[[self tabView] selectedTabViewItem]]);
}

- (void)startProgram:(NSString *)program
{
    [[self currentSession] startProgram:program
									 arguments:[NSArray array]
								   environment:[NSDictionary dictionary]];
		
}

- (void)startProgram:(NSString *)program arguments:(NSArray *)prog_argv
{
    [[self currentSession] startProgram:program
									 arguments:prog_argv
								   environment:[NSDictionary dictionary]];
		
}

- (void)startProgram:(NSString *)program
		   arguments:(NSArray *)prog_argv
		 environment:(NSDictionary *)prog_env
{
    [[self currentSession] startProgram:program
									 arguments:prog_argv
								   environment:prog_env];
	
	[self setWindowTitle];
}

- (void)setCharSizeUsingFont: (NSFont *)font
{
	int i;
	NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    NSSize sz;
    [dic setObject:font forKey:NSFontAttributeName];
    sz = [@"W" sizeWithAttributes:dic];
	
	[self setCharWidth:(sz.width * charHorizontalSpacingMultiplier)];
	[self setCharHeight:([font lineHeight] * charVerticalSpacingMultiplier)];

	for (i=0;i<[[self tabView] numberOfTabViewItems]; i++) 
    {
        PTYSession* session = [[[self tabView] tabViewItemAtIndex:i] identifier];
		[[session textView] setCharWidth: [self charWidth]];
		[[session textView] setLineHeight: [self charHeight]];
    }
}	

//---------------------------------------------------------- 
//  width 
//---------------------------------------------------------- 
- (int)width
{
    return mWidth;
}

- (void)setWidth:(int)theWidth
{
    mWidth = theWidth;
}

//---------------------------------------------------------- 
//  height 
//---------------------------------------------------------- 
- (int)height
{
    return mHeight;
}

- (void)setHeight:(int)theHeight
{
    mHeight = theHeight;
}

//---------------------------------------------------------- 
//  charWidth 
//---------------------------------------------------------- 
- (int)charWidth
{
    return mCharWidth;
}

- (void)setCharWidth:(int)theCharWidth
{
    mCharWidth = theCharWidth;
}

//---------------------------------------------------------- 
//  charHeight 
//---------------------------------------------------------- 
- (int)charHeight
{
    return mCharHeight;
}

- (void)setCharHeight:(int)theCharHeight
{
    mCharHeight = theCharHeight;
}

- (float) charSpacingHorizontal
{
	return (charHorizontalSpacingMultiplier);
}

- (float) charSpacingVertical
{
	return (charVerticalSpacingMultiplier);
}

- (void)setWindowSize
{    		
    if (![self initialized] || [self beingResized])
		return;
	
	[self setBeingResized:YES];
	@try {
		NSRect tabViewRect = [self bounds];
		NSRect tabControlRect;

		if ([[self tabView] numberOfTabViewItems] > 1 || ![[PreferencePanel sharedInstance] hideTab]) {
			tabViewRect.size.height -= [[self tabBarControl] frame].size.height;
		}
						
		[self setHeight:tabViewRect.size.height / [self charHeight]];
		[self setWidth:(tabViewRect.size.width - 18) / [self charWidth]];  // 18 for scrollbar room on right
		
		if ([self width]<20) 
			[self setWidth:20];
		if ([self height]<2) 
			[self setHeight:2];
		
		// Display the new size in the window title.
		NSString *aTitle = [NSString stringWithFormat:@"%@ (%d,%d)", [[self currentSession] name], [self width], [self height]];
		[self setWindowTitle: aTitle];
		
		if ([[self tabView] numberOfTabViewItems] == 1 && [[PreferencePanel sharedInstance] hideTab])
		{
			[[self tabBarControl] setHidden: YES];
			[[self tabView] setFrame: tabViewRect];		
		}
		else
		{
			[[self tabBarControl] setHidden: NO];
			[[self tabBarControl] setTabLocation: [[PreferencePanel sharedInstance] tabViewType]];
			
			if ([[PreferencePanel sharedInstance] tabViewType] == PSMTab_TopTab) 
			{
				[[self tabView] setFrame: tabViewRect];
				
				tabControlRect = tabViewRect;
				tabControlRect.origin.y += tabControlRect.size.height;
				tabControlRect.size.height = [[self tabBarControl] frame].size.height;
				[[self tabBarControl] setFrame: tabControlRect];
			}
			else
			{
				tabControlRect = tabViewRect;
				tabControlRect.size.height = [[self tabBarControl] frame].size.height;
				[[self tabBarControl] setFrame: tabControlRect];
				
				tabViewRect.origin.y += [[self tabBarControl] frame].size.height;
				[[self tabView] setFrame: tabViewRect];
			}
		}
	    
		int i;
		for (i=0;i<[[self tabView] numberOfTabViewItems];i++) 
		{
			PTYSession *aSession = [[[self tabView] tabViewItemAtIndex: i] identifier];
			[aSession setObjectCount:i+1];
			[[aSession SCREEN] resizeWidth:[self width] height:[self height]];
			[[aSession SHELL] setWidth:[self width]  height:[self height]];
			[[aSession scrollView] setLineScroll: [[aSession textView] lineHeight]];
			[[aSession scrollView] setPageScroll: 2*[[aSession textView] lineHeight]];
		}
    	
		[[[self currentSession] textView] setForceUpdate: YES];
		[[[self currentSession] scrollView] setNeedsDisplay: YES];
	}
	@catch (NSException * e) {}
	@finally {}
	
	[self setBeingResized:NO];
}

- (void)setWindowTitle
{
    NSString *title = [[self currentSession] windowTitle] ? [[self currentSession] windowTitle] : [self currentSessionName];
	
	[self setWindowTitle: title];
}

- (void)setWindowTitle: (NSString *)title
{
	NSString *temp = title ? title : @"Session";
	
	NSWindow* window = [self window];
	if ([window isKindOfClass:[PTYWindow class]])
		[[self window] setTitle: [self sendInputToAllSessions] ? [NSString stringWithFormat:@">>%@<<", temp] : temp];
}

// increases or dcreases font size
- (void)changeFontSize: (BOOL) increase
{
    float newFontSize;
    
    float asciiFontSize = [[self font] pointSize];
    if (increase == YES)
		newFontSize = [self largerSizeForSize: asciiFontSize];
    else
		newFontSize = [self smallerSizeForSize: asciiFontSize];	
    NSFont *newAsciiFont = [NSFont fontWithName: [[self font] fontName] size: newFontSize];
    
    float nonAsciiFontSize = [[self nafont] pointSize];
    if (increase == YES)
		newFontSize = [self largerSizeForSize: nonAsciiFontSize];
    else
		newFontSize = [self smallerSizeForSize: nonAsciiFontSize];	    
    NSFont *newNonAsciiFont = [NSFont fontWithName: [[self nafont] fontName] size: newFontSize];
    
    if (newAsciiFont != nil && newNonAsciiFont != nil)
		[self setFont: newAsciiFont nafont: newNonAsciiFont];
}

- (float) largerSizeForSize: (float) aSize 
    /*" Given a font size of aSize, return the next larger size.   Uses the 
    same list of font sizes as presented in the font panel. "*/ 
{
    if (aSize <= 8.0) return 9.0;
    if (aSize <= 9.0) return 10.0;
    if (aSize <= 10.0) return 11.0;
    if (aSize <= 11.0) return 12.0;
    if (aSize <= 12.0) return 13.0;
    if (aSize <= 13.0) return 14.0;
    if (aSize <= 14.0) return 18.0;
    if (aSize <= 18.0) return 24.0;
    if (aSize <= 24.0) return 36.0;
    if (aSize <= 36.0) return 48.0;
    if (aSize <= 48.0) return 64.0;
    if (aSize <= 64.0) return 72.0;
    if (aSize <= 72.0) return 96.0;
    if (aSize <= 96.0) return 144.0;
	
    // looks odd, but everything reasonable should have been covered above
    return 288.0; 
} 

- (float) smallerSizeForSize: (float) aSize 
    /*" Given a font size of aSize, return the next smaller size.   Uses 
    the same list of font sizes as presented in the font panel. "*/
{
    if (aSize >= 288.0) return 144.0;
    if (aSize >= 144.0) return 96.0;
    if (aSize >= 96.0) return 72.0;
    if (aSize >= 72.0) return 64.0;
    if (aSize >= 64.0) return 48.0;
    if (aSize >= 48.0) return 36.0;
    if (aSize >= 36.0) return 24.0;
    if (aSize >= 24.0) return 18.0;
    if (aSize >= 18.0) return 14.0;
    if (aSize >= 14.0) return 13.0;
    if (aSize >= 13.0) return 12.0;
    if (aSize >= 12.0) return 11.0;
    if (aSize >= 11.0) return 10.0;
    if (aSize >= 10.0) return 9.0;
    
    // looks odd, but everything reasonable should have been covered above
    return 8.0; 
} 

- (void)setCharacterSpacingHorizontal: (float) horizontal vertical: (float) vertical
{
	charHorizontalSpacingMultiplier = horizontal;
	charVerticalSpacingMultiplier = vertical;
	[self setCharSizeUsingFont: FONT];
}

- (BOOL) antiAlias
{
	return (antiAlias);
}

- (void)setAntiAlias: (BOOL) bAntiAlias
{
	PTYSession *aSession;
	int i, cnt = [[self tabView] numberOfTabViewItems];
	
	antiAlias = bAntiAlias;
	
	for (i=0; i<cnt; i++)
	{
		aSession = [[[self tabView] tabViewItemAtIndex: i] identifier];
		[[aSession textView] setAntiAlias: antiAlias];
	}
	
	[[[self currentSession] textView] setNeedsDisplay: YES];
}

- (void)setFont:(NSFont *)font nafont:(NSFont *)nafont
{
	int i;
	
    [FONT autorelease];
    [font retain];
    FONT=font;
    [NAFONT autorelease];
    [nafont retain];
    NAFONT=nafont;
	[self setCharSizeUsingFont: FONT];
    for (i=0;i<[[self tabView] numberOfTabViewItems]; i++) 
    {
        PTYSession* session = [[[self tabView] tabViewItemAtIndex: i] identifier];
        [[session textView]  setFont:FONT nafont:NAFONT];
    }
}

- (NSFont *) font
{
	return FONT;
}

- (NSFont *) nafont
{
	return NAFONT;
}

- (void)reset:(id)sender
{
	[[[self currentSession] TERMINAL] reset];
}

- (BOOL) useTransparency
{
	int n = [[self tabView] numberOfTabViewItems];
	
	if (n)
		return [(PTYTextView*)[[[[self tabView] tabViewItemAtIndex:0] identifier] textView] useTransparency];
	
	return NO;
}

- (void)setUseTransparency: (BOOL) flag
{	
	int n = [[self tabView] numberOfTabViewItems];
	int i;
	for (i=0;i<n;i++) {
		[(PTYTextView*)[[[[self tabView] tabViewItemAtIndex:i] identifier] textView] setUseTransparency:flag];
	}
}

- (void)clearBuffer:(id)sender
{
    [[self currentSession] clearBuffer];
}

- (void)clearScrollbackBuffer:(id)sender
{
    [[self currentSession] clearScrollbackBuffer];
}

- (IBAction)logStart:(id)sender
{
    if (![[self currentSession] logging]) 
		[[self currentSession] logStart];
}

- (IBAction)logStop:(id)sender
{
    if ([[self currentSession] logging])
		[[self currentSession] logStop];
}

- (void)sendInputToAllSessions: (NSData *) data
{
	PTYSession *aSession;
    int i;
    
    int n = [[self tabView] numberOfTabViewItems];    
    for (i=0; i<n; i++)
    {
        aSession = [[[self tabView] tabViewItemAtIndex: i] identifier];
		
		[[aSession SHELL] writeTask:data];
    }    
}

- (BOOL) sendInputToAllSessions
{
    return (sendInputToAllSessions);
}

- (void)setSendInputToAllSessions: (BOOL) flag
{
    sendInputToAllSessions = flag;
	if (flag)
		sendInputToAllSessions = (NSRunAlertPanel(NSLocalizedStringFromTableInBundle(@"Warning!",@"iTerm", [NSBundle bundleForClass: [self class]], @"Warning"),
									 NSLocalizedStringFromTableInBundle(@"Keyboard input will be sent to all sessions in this terminal.",@"iTerm", [NSBundle bundleForClass: [self class]], @"Keyboard Input"), 
									 NSLocalizedStringFromTableInBundle(@"OK",@"iTerm", [NSBundle bundleForClass: [self class]], @"Profile"), 
                                     NSLocalizedStringFromTableInBundle(@"Cancel",@"iTerm", [NSBundle bundleForClass: [self class]], @"Cancel"), nil) == NSAlertDefaultReturn);
}

- (IBAction)toggleInputToAllSessions:(id)sender
{
	[self setSendInputToAllSessions: ![self sendInputToAllSessions]];
    
    // cause reloading of menus
	[self setWindowTitle];
}

// Contextual menu
- (BOOL) suppressContextualMenu
{
	return (suppressContextualMenu);
}

- (void)setSuppressContextualMenu: (BOOL) aBool
{
	suppressContextualMenu = aBool;
}

- (void)menuForEvent:(NSEvent *)theEvent menu: (NSMenu *) theMenu
{
    int nextIndex;
	NSMenuItem *aMenuItem;
    	
    if (theMenu == nil || suppressContextualMenu)
		return;
		
    // Bookmarks
    [theMenu insertItemWithTitle: NSLocalizedStringFromTableInBundle(@"New",@"iTerm", [NSBundle bundleForClass: [self class]], @"Context menu") action:nil keyEquivalent:@"" atIndex: 0];
    nextIndex = 1;
	
    // Create a menu with a submenu to navigate between tabs if there are more than one
    if ([[self tabView] numberOfTabViewItems] > 1)
    {	
		[theMenu insertItemWithTitle: NSLocalizedStringFromTableInBundle(@"Select",@"iTerm", [NSBundle bundleForClass: [self class]], @"Context menu") action:nil keyEquivalent:@"" atIndex: nextIndex];
		
		NSMenu *tabMenu = [[NSMenu alloc] initWithTitle:@""];
		int i;
		
		for (i = 0; i < [[self tabView] numberOfTabViewItems]; i++)
		{
			aMenuItem = [[NSMenuItem alloc] initWithTitle:[NSString stringWithFormat:@"%@ #%d", [[[self tabView] tabViewItemAtIndex: i] label], i+1]
												   action:@selector(selectTab:) keyEquivalent:@""];
			[aMenuItem setRepresentedObject: [[[self tabView] tabViewItemAtIndex: i] identifier]];
			[aMenuItem setTarget: [self tabView]];
			[tabMenu addItem: aMenuItem];
			[aMenuItem release];
		}
		[theMenu setSubmenu: tabMenu forItem: [theMenu itemAtIndex: nextIndex]];
		[tabMenu release];
		nextIndex++;
    }
	
	// Bookmarks
	[theMenu insertItemWithTitle: 
		NSLocalizedStringFromTableInBundle(@"Bookmarks",@"iTerm", [NSBundle bundleForClass: [self class]], @"Bookmarks") 
						  action:@selector(toggleBookmarksView:) keyEquivalent:@"" atIndex: nextIndex++];
    
    // Separator
    [theMenu insertItem:[NSMenuItem separatorItem] atIndex: nextIndex];
	
    // Build the bookmarks menu
	NSMenu *aMenu = [[[NSMenu alloc] init] autorelease];
    [[iTermController sharedInstance] alternativeMenu: aMenu 
                                              forNode: [[ITAddressBookMgr sharedInstance] rootNode] 
                                               target: self];
    [aMenu addItem: [NSMenuItem separatorItem]];
    NSMenuItem *tip = [[[NSMenuItem alloc] initWithTitle: NSLocalizedStringFromTableInBundle(@"Press Option for New Window",@"iTerm", [NSBundle bundleForClass: [self class]], @"Toolbar Item: New") action:@selector(xyz) keyEquivalent: @""] autorelease];
    [tip setKeyEquivalentModifierMask: NSCommandKeyMask];
    [aMenu addItem: tip];
    tip = [[tip copy] autorelease];
    [tip setTitle:NSLocalizedStringFromTableInBundle(@"Open In New Window",@"iTerm", [NSBundle bundleForClass: [self class]], @"Toolbar Item: New")];
    [tip setKeyEquivalentModifierMask: NSCommandKeyMask | NSAlternateKeyMask];
    [tip setAlternate:YES];
    [aMenu addItem: tip];
	
    [theMenu setSubmenu: aMenu forItem: [theMenu itemAtIndex: 0]];
	
    // Separator
    [theMenu addItem:[NSMenuItem separatorItem]];
	
    // Info
    aMenuItem = [[NSMenuItem alloc] initWithTitle:NSLocalizedStringFromTableInBundle(@"Info...",@"iTerm", [NSBundle bundleForClass: [self class]], @"Context menu") action:@selector(showConfigWindow:) keyEquivalent:@""];
	[aMenuItem setTarget:[ITSharedActionHandler sharedInstance]];
    [theMenu addItem: aMenuItem];
    [aMenuItem release];

    // Separator
    [theMenu addItem:[NSMenuItem separatorItem]];

    // Close current session
    aMenuItem = [[NSMenuItem alloc] initWithTitle:NSLocalizedStringFromTableInBundle(@"Close",@"iTerm", [NSBundle bundleForClass: [self class]], @"Context menu") action:@selector(closeTabAction:) keyEquivalent:@""];
    [aMenuItem setTarget: self];
    [theMenu addItem: aMenuItem];
    [aMenuItem release];
}

// NSTabView
- (void)tabView:(NSTabView *)tabView willSelectTabViewItem:(NSTabViewItem *)tabViewItem
{ 
    if (![[self currentSession] exited]) {
		[[self currentSession] resetStatus];
		[[[tabView selectedTabViewItem] identifier] setTimerMode: SLOW_MODE];
	}
}

- (void)tabView:(NSTabView *)tabView didSelectTabViewItem:(NSTabViewItem *)tabViewItem
{    
	[[tabViewItem identifier] resetStatus];
	[[[tabViewItem identifier] SCREEN] setDirty];
	[[[tabViewItem identifier] textView] setNeedsDisplay: YES];
	[[tabViewItem identifier] setTimerMode: FAST_MODE];
	[[tabViewItem identifier] setLabelAttribute];
	[self setWindowTitle];

    [[self window] makeFirstResponder:[[tabViewItem identifier] textView]];
}

- (void)tabView:(NSTabView *)tabView willRemoveTabViewItem:(NSTabViewItem *)tabViewItem
{ 
}

- (void)tabView:(NSTabView *)tabView willAddTabViewItem:(NSTabViewItem *)tabViewItem
{ 	
    [self tabView: tabView willInsertTabViewItem: tabViewItem atIndex: [tabView numberOfTabViewItems]];
}

- (void)tabView:(NSTabView *)tabView willInsertTabViewItem:(NSTabViewItem *)tabViewItem atIndex: (int) index
{ 
    [[tabViewItem identifier] setParent: self];
}

- (BOOL)tabView:(NSTabView*)tabView shouldCloseTabViewItem:(NSTabViewItem *)tabViewItem
{ 
    PTYSession *aSession = [tabViewItem identifier];
    
	if ([aSession exited])
		return YES;
	
    if ([[PreferencePanel sharedInstance] promptOnClose] || ![[aSession parent] terminalIsIdle:aSession])
		return [self askUserToCloseTab:aSession];
	
	return YES;
}

- (BOOL)tabView:(NSTabView*)aTabView shouldDragTabViewItem:(NSTabViewItem *)tabViewItem fromTabBar:(PSMTabBarControl *)tabBarControl
{ 
    return YES;
}

- (BOOL)tabView:(NSTabView*)aTabView shouldDropTabViewItem:(NSTabViewItem *)tabViewItem inTabBar:(PSMTabBarControl *)tabBarControl
{ 
    //NSLog(@"shouldDropTabViewItem: %@ inTabBar: %@", [tabViewItem label], tabBarControl);
    return YES;
}

- (void)tabView:(NSTabView*)aTabView didDropTabViewItem:(NSTabViewItem *)tabViewItem inTabBar:(PSMTabBarControl *)aTabBarControl
{ 
	//NSLog(@"didDropTabViewItem: %@ inTabBar: %@", [tabViewItem label], aTabBarControl);
	PTYSession *aSession = [tabViewItem identifier];
	ITTerminalView *term = [aTabBarControl delegate];
    
    [[aSession SCREEN] resizeWidth:[term width] height:[term height]];
    [[aSession SHELL] setWidth:[term width]  height:[term height]];
    [[aSession textView] setFont:[term font] nafont:[term nafont]];
    [[aSession textView] setCharWidth: [term charWidth]];
    [[aSession textView] setLineHeight: [term charHeight]];
    if ([[term tabView] numberOfTabViewItems] == 1) [term setWindowSize];

    int i;
    for (i=0;i<[aTabView numberOfTabViewItems];i++) 
    {
		aSession = [[aTabView tabViewItemAtIndex: i] identifier];
        [aSession setObjectCount:i+1];
    }        
}

- (void)tabView:(NSTabView *)aTabView closeWindowForLastTabViewItem:(NSTabViewItem *)tabViewItem
{ 
	// only close if it's one of our windows, not an embedded views window or drawer window
	if ([[self window] isKindOfClass:[PTYWindow class]])
		[[self window] close];
}

- (NSImage *)tabView:(NSTabView *)aTabView imageForTabViewItem:(NSTabViewItem *)tabViewItem offset:(NSSize *)offset styleMask:(unsigned int *)styleMask
{ 
    NSImage *viewImage;
    
    if (tabViewItem == [aTabView selectedTabViewItem]) { 
        NSView *textview = [tabViewItem view];
        NSRect tabFrame = [[self tabBarControl] frame];
        int tabHeight = tabFrame.size.height;

        NSRect contentFrame, viewRect;
        contentFrame = viewRect = [textview frame];
        contentFrame.size.height += tabHeight;

        // grabs whole tabview image
        viewImage = [[[NSImage alloc] initWithSize:contentFrame.size] autorelease];
        NSImage *tabViewImage = [[[NSImage alloc] init] autorelease];

        [textview lockFocus];
        NSBitmapImageRep *tabviewRep = [[[NSBitmapImageRep alloc] initWithFocusedViewRect:viewRect] autorelease];
        [tabViewImage addRepresentation:tabviewRep];
        [textview unlockFocus];

        [viewImage lockFocus];
        //viewRect.origin.x += 10;
        if ([[PreferencePanel sharedInstance] tabViewType] == PSMTab_BottomTab) {
            viewRect.origin.y += tabHeight;
        }
        [tabViewImage compositeToPoint:viewRect.origin operation:NSCompositeSourceOver];
        [viewImage unlockFocus];

        //draw over where the tab bar would usually be
        [viewImage lockFocus];
        [[NSColor windowBackgroundColor] set];
        if ([[PreferencePanel sharedInstance] tabViewType] == PSMTab_TopTab) {
            tabFrame.origin.y += viewRect.size.height;
        }
        NSRectFill(tabFrame);
        //draw the background flipped, which is actually the right way up
        NSAffineTransform *transform = [NSAffineTransform transform];
        [transform scaleXBy:1.0 yBy:-1.0];
        [transform concat];
        tabFrame.origin.y = -tabFrame.origin.y - tabFrame.size.height;
        [(id <PSMTabStyle>)[(PSMTabBarControl*)[aTabView delegate] style] drawBackgroundInRect:tabFrame drawLineAtBottom:NO];
        [transform invert];
        [transform concat];

        [viewImage unlockFocus];

        offset->width = [(id <PSMTabStyle>)[[self tabBarControl] style] leftMarginForTabBarControl];
        if ([[PreferencePanel sharedInstance] tabViewType] == PSMTab_TopTab) {
            offset->height = 22;
        }
        else {
            offset->height = viewRect.size.height + 22;
        }
        *styleMask = NSBorderlessWindowMask;
	}
    else {
        NSView *textview = [tabViewItem view];
        NSRect tabFrame = [[self tabBarControl] frame];
        int tabHeight = tabFrame.size.height;
        
        NSRect contentFrame, viewRect;
        contentFrame = viewRect = [textview frame];
        contentFrame.size.height += tabHeight;
        
        // grabs whole tabview image
        viewImage = [[[NSImage alloc] initWithSize:contentFrame.size] autorelease];
        NSImage *textviewImage = [[[NSImage alloc] initWithSize:viewRect.size] autorelease];
        
        [textviewImage setFlipped: YES];
        [textviewImage lockFocus];
        //draw the background flipped, which is actually the right way up
        [(PTYTextView*)[[tabViewItem identifier] textView] setForceUpdate: YES];
        [(PTYTextView*)[[tabViewItem identifier] textView] drawRect: viewRect];
        [textviewImage unlockFocus];
        
        [viewImage lockFocus];
        //viewRect.origin.x += 10;
        if ([[PreferencePanel sharedInstance] tabViewType] == PSMTab_BottomTab) {
            viewRect.origin.y += tabHeight;
        }
        [textviewImage compositeToPoint:viewRect.origin operation:NSCompositeSourceOver];
        [viewImage unlockFocus];
        
        //draw over where the tab bar would usually be
        [viewImage lockFocus];
        [[NSColor windowBackgroundColor] set];
        if ([[PreferencePanel sharedInstance] tabViewType] == PSMTab_TopTab) {
            tabFrame.origin.y += viewRect.size.height;
        }
        NSRectFill(tabFrame);
        //draw the background flipped, which is actually the right way up
        NSAffineTransform *transform = [NSAffineTransform transform];
        [transform scaleXBy:1.0 yBy:-1.0];
        [transform concat];
        tabFrame.origin.y = -tabFrame.origin.y - tabFrame.size.height;
        [(id <PSMTabStyle>)[(PSMTabBarControl*)[aTabView delegate] style] drawBackgroundInRect:tabFrame drawLineAtBottom:NO];
        [transform invert];
        [transform concat];
        
        [viewImage unlockFocus];
        
        offset->width = [(id <PSMTabStyle>)[[self tabBarControl] style] leftMarginForTabBarControl];
        if ([[PreferencePanel sharedInstance] tabViewType] == PSMTab_TopTab) {
            offset->height = 22;
        }
        else {
            offset->height = viewRect.size.height + 22;
        }
        *styleMask = NSBorderlessWindowMask;
    }
        
	return viewImage;
}

- (void)tabViewDidChangeNumberOfTabViewItems:(NSTabView *)tabView
{ 	
	// check window size in case tabs have to be hidden or shown
    if (([[self tabView] numberOfTabViewItems] == 1) || ([[PreferencePanel sharedInstance] hideTab] && 
		([[self tabView] numberOfTabViewItems] > 1 && [[self tabBarControl] isHidden])) )
    {
        [self setWindowSize];      
    }
	else
		[self setNeedsDisplay:YES];  // zero tabs, must redraw to erase last tab
    	
    int i;
    for (i=0;i<[[self tabView] numberOfTabViewItems];i++) 
    {
        PTYSession *aSession = [[[self tabView] tabViewItemAtIndex: i] identifier];
        [aSession setObjectCount:i+1];
    }        
			
	[[NSNotificationCenter defaultCenter] postNotificationName: @"iTermNumberOfSessionsDidChange" object: self userInfo: nil];		
	//[[self tabBarControl] update];
}

- (NSMenu *)tabView:(NSTabView *)aTabView menuForTabViewItem:(NSTabViewItem *)tabViewItem
{ 
    NSMenuItem *aMenuItem;
	
    NSMenu *theMenu = [[[NSMenu alloc] init] autorelease];
	
    // Create a menu with a submenu to navigate between tabs if there are more than one
    if ([[self tabView] numberOfTabViewItems] > 1)
    {			
		[theMenu insertItemWithTitle: NSLocalizedStringFromTableInBundle(@"Select",@"iTerm", [NSBundle bundleForClass: [self class]], @"Context menu") action:nil keyEquivalent:@"" atIndex: 0];
		NSMenu *tabMenu = [[NSMenu alloc] initWithTitle:@""];
		
		for (int i = 0; i < [[self tabView] numberOfTabViewItems]; i++)
		{
			aMenuItem = [[NSMenuItem alloc] initWithTitle:[NSString stringWithFormat:@"%@ #%d", [[[self tabView] tabViewItemAtIndex: i] label], i+1]
												   action:@selector(selectTab:) keyEquivalent:@""];
			[aMenuItem setRepresentedObject: [[[self tabView] tabViewItemAtIndex: i] identifier]];
			[aMenuItem setTarget: [self tabView]];
			[tabMenu addItem: aMenuItem];
			[aMenuItem release];
		}
		[theMenu setSubmenu: tabMenu forItem: [theMenu itemAtIndex: 0]];
		[tabMenu release];
        [theMenu addItem: [NSMenuItem separatorItem]];
   }
 	
    // add tasks
    aMenuItem = [[NSMenuItem alloc] initWithTitle:NSLocalizedStringFromTableInBundle(@"Close Tab",@"iTerm", [NSBundle bundleForClass: [self class]], @"Context Menu") action:@selector(closeTabContextualMenuAction:) keyEquivalent:@""];
    [aMenuItem setRepresentedObject: tabViewItem];
    [theMenu addItem: aMenuItem];
    [aMenuItem release];
    if ([[self tabView] numberOfTabViewItems] > 1)
    {
		aMenuItem = [[NSMenuItem alloc] initWithTitle:NSLocalizedStringFromTableInBundle(@"Move to new window",@"iTerm", [NSBundle bundleForClass: [self class]], @"Context Menu") action:@selector(moveTabToNewWindowContextualMenuAction:) keyEquivalent:@""];
		[aMenuItem setRepresentedObject: tabViewItem];
		[theMenu addItem: aMenuItem];
		[aMenuItem release];
    }
    
    return theMenu;
}

- (PSMTabBarControl *)tabView:(NSTabView *)aTabView newTabBarForDraggedTabViewItem:(NSTabViewItem *)tabViewItem atPoint:(NSPoint)point
{ 
    ITTerminalView *term;
    PTYSession *aSession = [tabViewItem identifier];
	
    if (aSession == nil)
		return nil;
	
    // create a new terminal window
    term = [[ITTerminalWindowController controller:[aSession addressBookEntry]] term];
			
    if ([[PreferencePanel sharedInstance] tabViewType] == PSMTab_TopTab)
        [[term window] setFrameTopLeftPoint:point];
    else
        [[term window] setFrameOrigin:point];
    
    return [term tabBarControl];
}

- (NSString *)tabView:(NSTabView *)aTabView toolTipForTabViewItem:(NSTabViewItem *)aTabViewItem
{ 
	NSDictionary *ade = [[aTabViewItem identifier] addressBookEntry];
	
	NSString *temp = [NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"Name: %@\nCommand: %@\nTerminal Profile: %@\nDisplay Profile: %@\nKeyboard Profile: %@",@"iTerm", [NSBundle bundleForClass: [self class]], @"Tab Tooltips"),
		[ade objectForKey:KEY_NAME], [ade objectForKey:KEY_COMMAND], [ade objectForKey:KEY_TERMINAL_PROFILE],
		[ade objectForKey:KEY_DISPLAY_PROFILE], [ade objectForKey:KEY_KEYBOARD_PROFILE]];
	
	return temp;
}

- (void)tabView:(NSTabView *)tabView doubleClickTabViewItem:(NSTabViewItem *)tabViewItem
{ 
	[tabView selectTabViewItem:tabViewItem];
	[ITConfigPanelController show];
}

- (void)setLabelColor: (NSColor *) color forTabViewItem: tabViewItem
{
    [[self tabBarControl] setLabelColor: color forTabViewItem:tabViewItem];
}

//---------------------------------------------------------- 
//  tabView 
//---------------------------------------------------------- 
- (PTYTabView *)tabView
{
    return mTabView; 
}

- (void)setTabView:(PTYTabView *)theTabView
{
    if (mTabView != theTabView)
    {
        [mTabView release];
        mTabView = [theTabView retain];
    }
}

//---------------------------------------------------------- 
//  tabBarControl 
//---------------------------------------------------------- 
- (PSMTabBarControl *)tabBarControl
{
    return mTabBarControl; 
}

- (void)setTabBarControl:(PSMTabBarControl *)theTabBarControl
{
    if (mTabBarControl != theTabBarControl)
    {
		[mTabBarControl setDelegate:nil];

        [mTabBarControl release];
        mTabBarControl = [theTabBarControl retain];
		
		[mTabBarControl setDelegate:self];
    }
}

- (void)closeTabWithIdentifier: (id) identifier
{
    [self closeSession: identifier];
}

// moves a tab with its session to a new window
- (void)moveTabToNewWindowContextualMenuAction:(id)sender
{
    ITTerminalView *term;
    NSTabViewItem *aTabViewItem = [sender representedObject];
    PTYSession *aSession = [aTabViewItem identifier];
	
    if (aSession == nil)
		return;
	
    // create a new terminal window
    term = [[ITTerminalWindowController controller:[aSession addressBookEntry]] term];	
	
    // temporarily retain the tabViewItem
    [aTabViewItem retain];
	
    // remove from our window
    [[self tabView] removeTabViewItem: aTabViewItem];
	
    // add the session to the new terminal
    [term insertSession: aSession atIndex: 0];
    [[aSession SCREEN] resizeWidth:[term width] height:[term height]];
    [[aSession SHELL] setWidth:[term width]  height:[term height]];
    [[aSession textView] setFont:[term font] nafont:[term nafont]];
    [[aSession textView] setCharWidth: [term charWidth]];
    [[aSession textView] setLineHeight: [term charHeight]];
    [term setWindowSize];
	
    // release the tabViewItem
    [aTabViewItem release];
}

- (IBAction)closeWindow:(id)sender
{
    [[self window] performClose:sender];
}

- (void)runCommand:(NSString*)command
{	
	NSRange range = [command rangeOfString:@"://"];
	if (range.location != NSNotFound) 
	{
		range = [[command substringToIndex:range.location] rangeOfString:@" "];
		
		if (range.location == NSNotFound) 
		{
			NSURL *url = [NSURL URLWithString: command];
			NSString *urlType = [url scheme];
			id bm = [[PreferencePanel sharedInstance] handlerBookmarkForURL: urlType];
			
			if (bm)
				[[iTermController sharedInstance] launchBookmark:[bm nodeData] inTerminal:self withURL:command];
			else 
				[[NSWorkspace sharedWorkspace] openURL:url];
			
			return;
		}
	}
	
	[[self currentSession] runCommand: command];
	[[[self nibController] commandField] setStringValue:@""];
}

- (void)updateCurretSessionProfiles
{
	iTermDisplayProfileMgr *displayProfileMgr;
	NSDictionary *aDict;
	NSString *displayProfile;
	PTYSession *current;
	
	current = [self currentSession];
	displayProfileMgr = [iTermDisplayProfileMgr singleInstance];
	aDict = [current addressBookEntry];
	displayProfile = [aDict objectForKey: KEY_DISPLAY_PROFILE];
	if (displayProfile == nil)
		displayProfile = [displayProfileMgr defaultProfileName];	
	
	[displayProfileMgr setTransparency: [current transparency] forProfile: displayProfile];
	[displayProfileMgr setUseTransparency: [self useTransparency] forProfile: displayProfile];
	[displayProfileMgr setDisableBold: [current disableBold] forProfile: displayProfile];
	[displayProfileMgr setWindowFont: [self font] forProfile: displayProfile];
	[displayProfileMgr setWindowNAFont: [self nafont] forProfile: displayProfile];
	[displayProfileMgr setWindowHorizontalCharSpacing: charHorizontalSpacingMultiplier forProfile: displayProfile];
	[displayProfileMgr setWindowVerticalCharSpacing: charVerticalSpacingMultiplier forProfile: displayProfile];
	[displayProfileMgr setWindowAntiAlias: [[current textView] antiAlias] forProfile: displayProfile];
	[displayProfileMgr setColor: [current foregroundColor] forType: TYPE_FOREGROUND_COLOR forProfile: displayProfile];
	[displayProfileMgr setColor: [current backgroundColor] forType: TYPE_BACKGROUND_COLOR forProfile: displayProfile];
	[displayProfileMgr setColor: [current boldColor] forType: TYPE_BOLD_COLOR forProfile: displayProfile];
	[displayProfileMgr setColor: [current selectionColor] forType: TYPE_SELECTION_COLOR forProfile: displayProfile];
	[displayProfileMgr setColor: [current selectedTextColor] forType: TYPE_SELECTED_TEXT_COLOR forProfile: displayProfile];
	[displayProfileMgr setColor: [current cursorColor] forType: TYPE_CURSOR_COLOR forProfile: displayProfile];
	[displayProfileMgr setColor: [current cursorTextColor] forType: TYPE_CURSOR_TEXT_COLOR forProfile: displayProfile];

    iTermTerminalProfileMgr *terminalProfileMgr;
	NSString *terminalProfile;
	
    terminalProfileMgr = [iTermTerminalProfileMgr singleInstance];
	aDict = [current addressBookEntry];
	terminalProfile = [aDict objectForKey: KEY_TERMINAL_PROFILE];
	if (terminalProfile == nil)
		terminalProfile = [terminalProfileMgr defaultProfileName];	
    
	[terminalProfileMgr setEncoding: [current encoding] forProfile: terminalProfile];
	[terminalProfileMgr setSendIdleChar: [current antiIdle] forProfile: terminalProfile];
	[terminalProfileMgr setIdleChar: [current antiCode] forProfile: terminalProfile];
    
    id prefs = [NSUserDefaults standardUserDefaults];
    
    [prefs setObject: [[iTermDisplayProfileMgr singleInstance] profiles] forKey: @"iTermDisplays"];
	[prefs setObject: [[iTermTerminalProfileMgr singleInstance] profiles] forKey: @"iTermTerminals"];
	[prefs synchronize];
}

// NSOutlineView delegate methods
- (BOOL)outlineView:(NSOutlineView *)outlineView shouldEditTableColumn:(NSTableColumn *)tableColumn 
			   item:(id)item
{
	return (NO);
}

- (id)commandField
{
	return [[self nibController] commandField];
}

- (NSArray*)ttyPIDs:(BOOL)currentSessionOnly;
{
	NSMutableArray* result = [NSMutableArray array];
	PTYSession* session;

	if (currentSessionOnly)
	{
		session = [self currentSession];
		
		[result addObject:[session ttyPID]];
	}
	else
	{
		NSEnumerator* enumerator = [[self sessions] objectEnumerator];
		
		while (session = [enumerator nextObject])
			[result addObject:[session ttyPID]];
	}
	
	return result;
}

- (NSArray*)sessions
{
    int n = [[self tabView] numberOfTabViewItems];
    NSMutableArray *sessions = [NSMutableArray arrayWithCapacity: n];
    int i;
    
    for (i= 0; i < n; i++)
        [sessions addObject: [[[self tabView] tabViewItemAtIndex:i] identifier]];
	
    return sessions;
}

- (void)addNewSession:(NSDictionary *)addressbookEntry
		  withCommand:(NSString *)command
			  withURL:(NSString*)url;
{	
    PTYSession *aSession;
	
    // Initialize a new session
    aSession = [[PTYSession alloc] init];
	[[aSession SCREEN] setScrollback:[[iTermTerminalProfileMgr singleInstance] scrollbackLinesForProfile: [addressbookEntry objectForKey: KEY_TERMINAL_PROFILE]]];
	
	// set our preferences
    [aSession setAddressBookEntry: addressbookEntry];
	
    // Add this session to our term and make it current
    [self appendSession: aSession];
    
	if (!command)
		command = [addressbookEntry objectForKey: KEY_COMMAND];
	
	if (url)
	{
		NSMutableString* mutableCommand = [NSMutableString stringWithString:command];
		
		// We process the cmd to insert URL parts
		NSURL *urlRep = [NSURL URLWithString: url];
		
		// Grab the addressbook command
		[mutableCommand replaceOccurrencesOfString:@"$$URL$$" withString:url options:NSLiteralSearch range:NSMakeRange(0, [mutableCommand length])];
		[mutableCommand replaceOccurrencesOfString:@"$$HOST$$" withString:[urlRep host]?[urlRep host]:@"" options:NSLiteralSearch range:NSMakeRange(0, [mutableCommand length])];
		[mutableCommand replaceOccurrencesOfString:@"$$USER$$" withString:[urlRep user]?[urlRep user]:@"" options:NSLiteralSearch range:NSMakeRange(0, [mutableCommand length])];
		[mutableCommand replaceOccurrencesOfString:@"$$PASSWORD$$" withString:[urlRep password]?[urlRep password]:@"" options:NSLiteralSearch range:NSMakeRange(0, [mutableCommand length])];
		[mutableCommand replaceOccurrencesOfString:@"$$PORT$$" withString:[urlRep port]?[[urlRep port] stringValue]:@"" options:NSLiteralSearch range:NSMakeRange(0, [mutableCommand length])];
		[mutableCommand replaceOccurrencesOfString:@"$$PATH$$" withString:[urlRep path]?[urlRep path]:@"" options:NSLiteralSearch range:NSMakeRange(0, [mutableCommand length])];
		
		command = [NSString stringWithString:mutableCommand];
	}
	
	NSArray *arg;
	NSString *pwd;
	[ITTerminalView breakDown:command cmdPath:&command cmdArgs:&arg];
    
	command = [[self nibController] askUserForString:command window:[self window]];
	
	pwd = [addressbookEntry objectForKey: KEY_WORKING_DIRECTORY];
	if ([pwd length] <= 0)
		pwd = NSHomeDirectory();
    NSDictionary *env=[NSDictionary dictionaryWithObject: pwd forKey:@"PWD"];
    
    [self setCurrentSessionName:[addressbookEntry objectForKey: KEY_NAME]];	
    
    // Start the command        
    [self startProgram:command
			 arguments:arg 
		   environment:env];
	
    [aSession release];
}

- (void)appendSession:(PTYSession *)object
{
    [self setupSession: object title: nil];
    [self insertSession: object atIndex:[[self tabView] numberOfTabViewItems]];
}

- (void)addInSessions:(PTYSession *)object
{
    [self insertInSessions: object];
}

- (void)insertInSessions:(PTYSession *)object
{
    [self insertInSessions: object atIndex:[[self tabView] numberOfTabViewItems]];
}

- (void)insertInSessions:(PTYSession *)object atIndex:(unsigned)index
{
    [self setupSession: object title: nil];
    [self insertSession: object atIndex: index];
}

- (void)removeFromSessionsAtIndex:(unsigned)index
{
    if (index < [[self tabView] numberOfTabViewItems])
    {
		PTYSession *aSession = [[[self tabView] tabViewItemAtIndex:index] identifier];
		[self closeSession: aSession];
    }
}

- (void)newTabWithDirectory:(NSString*)path;
{
	NSDictionary *aDict = [[ITAddressBookMgr sharedInstance] defaultBookmarkData];
	
	[self addNewSession: aDict withCommand:nil withURL:nil];
	
	path = [path stringWithShellCharactersEscaped:NO];

	[self runCommand:[NSString stringWithFormat:@"cd \"%@\"", path]];
}

- (void)makeFirstResponder;
{
	NSView* view = [[self currentSession] textView];
	
	[[view window] makeFirstResponder:view];
}

- (BOOL)terminalIsIdle:(PTYSession*)session;  // pass nil for all sessions 
{
    NSArray *ttyList;
	
	if (session)
		ttyList = [NSArray arrayWithObject:[session ttyPID]];
	else
		ttyList = [self ttyPIDs:NO];

    NSEnumerator *ttyEnumerator = [ttyList objectEnumerator];
    NSNumber* tty;
	
    while (tty = [ttyEnumerator nextObject])
    {
        ITProcess *process = [ITProcess processForProcessIdentifier:[tty intValue]];
        NSArray *processes = [ITProcess processesForTerminal:[process terminal]];
        
        // if more than one process running, then it's not idle
        if ([processes count])
        {
            // check the commands, if login, tcsh, bash, sh, csh then it's still idle
            NSEnumerator *enumerator = [processes objectEnumerator];
            NSString* command;
            
			while (process = [enumerator nextObject])
			{
				command = [process command];
				
				if ([command isEqualToString:@"login"] || 
					[command isEqualToString:@"tcsh"] ||
					[command isEqualToString:@"csh"] ||
					[command isEqualToString:@"rlogin"] ||
					[command isEqualToString:@"sh"] ||
					[command isEqualToString:@"-bash"] ||  // not sure when this changed, but the -bash appeared in Tiger
					[command isEqualToString:@"bash"])
				{
					;
				}
				else
					return NO;
			}
        }
    }
    
    return YES;
}

@end

@implementation ITTerminalView (Private)

- (NSFont *) _getMaxFont:(NSFont* ) font 
				  height:(float) height
				   lines:(float) lines
{
	float newSize = [font pointSize], newHeight;
	NSFont *newfont=nil;
	
	do {
		newfont = font;
		font = [[NSFontManager sharedFontManager] convertFont:font toSize:newSize];
		newSize++;
		newHeight = [font lineHeight] * charVerticalSpacingMultiplier * lines;
	} while (height >= newHeight);
	
	return newfont;
}

- (void)_refreshTerminal: (NSNotification *) aNotification
{
	[self setWindowSize];
}

//---------------------------------------------------------- 
//  nibController 
//---------------------------------------------------------- 
- (ITMiscNibController *)nibController
{
	if (!mNibController)
		[self setNibController:[ITMiscNibController controller:self]];
	
    return mNibController; 
}

- (void)setNibController:(ITMiscNibController *)theNibController
{
    if (mNibController != theNibController)
    {
        [mNibController release];
        mNibController = [theNibController retain];
    }
}

//---------------------------------------------------------- 
//  initialized 
//---------------------------------------------------------- 
- (BOOL)initialized
{
    return mInitialized;
}

- (void)setInitialized:(BOOL)flag
{
    mInitialized = flag;
}

//---------------------------------------------------------- 
//  beingResized 
//---------------------------------------------------------- 
- (BOOL)beingResized
{
    return mBeingResized;
}

- (void)setBeingResized:(BOOL)flag
{
    mBeingResized = flag;
}

- (void)setupView:(NSDictionary *)entry;
{	
	NSRect aRect;
	
	charHorizontalSpacingMultiplier = charVerticalSpacingMultiplier = 1.0;

	// create the tabview
	aRect = [self bounds];
    [self setTabView:[[[PTYTabView alloc] initWithFrame: aRect] autorelease]];
    [[self tabView] setAutoresizingMask: NSViewWidthSizable|NSViewHeightSizable];
	[[self tabView] setAutoresizesSubviews: YES];
    [[self tabView] setAllowsTruncatedLabels: NO];
    [[self tabView] setControlSize: NSSmallControlSize];
	[[self tabView] setTabViewType: NSNoTabsNoBorder];
	
    // Add to the window
    [self addSubview: [self tabView]];
	
	// create the tab bar control
	aRect = [self bounds];
	aRect.size.height = 22;
	[self setTabBarControl:[[[PSMTabBarControl alloc] initWithFrame: aRect] autorelease]];
	[[self tabBarControl] setAutoresizingMask: (NSViewWidthSizable | NSViewMinYMargin)];
	[[self tabBarControl] setShowAddTabButton:YES];
	[[[self tabBarControl] addTabButton] setAction:@selector(newTabAction:)];
	[[[self tabBarControl] addTabButton] setTarget:self];
	
	// set the style of tabs to match window style
	switch ([[PreferencePanel sharedInstance] windowStyle]) {
        case 0:
            [[self tabBarControl] setStyleNamed:@"Metal"];
            break;
        case 1:
            [[self tabBarControl] setStyleNamed:@"Aqua"];
            break;
        case 2:
            [[self tabBarControl] setStyleNamed:@"Unified"];
            break;
        default:
            [[self tabBarControl] setStyleNamed:@"Adium"];
            break;
    }
    
    [[self tabBarControl] setDisableTabClose:[[PreferencePanel sharedInstance] useCompactLabel]];
    [[self tabBarControl] setCellMinWidth: [[PreferencePanel sharedInstance] useCompactLabel]?
                                  [[PreferencePanel sharedInstance] minCompactTabWidth]:
		[[PreferencePanel sharedInstance] minTabWidth]];
    [[self tabBarControl] setSizeCellsToFit: [[PreferencePanel sharedInstance] useUnevenTabs]];
    [[self tabBarControl] setCellOptimumWidth:  [[PreferencePanel sharedInstance] optimumTabWidth]];
	
	[self addSubview: [self tabBarControl]];
		
	// assign tabview and delegates
	[[self tabBarControl] setTabView: [self tabView]];
	[[self tabView] setDelegate: [self tabBarControl]];
	[[self tabBarControl] setHideForSingleTab: NO];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(_refreshTerminal:)
                                                 name: @"iTermRefreshTerminal"
                                               object: nil];	
	
	[[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(_refreshTerminal:)
                                                 name: NSViewFrameDidChangeNotification
                                               object: self];	
	
    [self setInitialized: YES];
    
    if (entry)
	{
        NSString *displayProfile;
        iTermDisplayProfileMgr *displayProfileMgr;
        
        displayProfileMgr = [iTermDisplayProfileMgr singleInstance];
        
        // grab the profiles
        displayProfile = [entry objectForKey: KEY_DISPLAY_PROFILE];
        if (displayProfile == nil)
            displayProfile = [displayProfileMgr defaultProfileName];
        
		[self setAntiAlias: [displayProfileMgr windowAntiAliasForProfile: displayProfile]];
		[self setFont: [displayProfileMgr windowFontForProfile: displayProfile] 
			   nafont: [displayProfileMgr windowNAFontForProfile: displayProfile]];
		[self setCharacterSpacingHorizontal: [displayProfileMgr windowHorizontalCharSpacingForProfile: displayProfile] 
                                   vertical: [displayProfileMgr windowVerticalCharSpacingForProfile: displayProfile]];
    }
}

// returns an array of ITProcess
- (NSArray*)runningProcesses:(PTYSession*)session;
{
	NSArray *ttyList;

	if (session)
		ttyList = [NSArray arrayWithObject:[session ttyPID]];
	else
		ttyList = [self ttyPIDs:NO];
	
    NSMutableArray* result = [NSMutableArray array];
    NSEnumerator *ttyEnumerator = [ttyList objectEnumerator];
    NSNumber* tty;
    
    while (tty = [ttyEnumerator nextObject])
    {
        ITProcess *process = [ITProcess processForProcessIdentifier:[tty intValue]];
        NSArray *processes = [ITProcess processesForTerminal:[process terminal]];
        
        NSEnumerator *processEnumerator = [processes objectEnumerator];
        
        while (process = [processEnumerator nextObject])
            [result addObject:process];
    }
    
    return result;
}

- (BOOL)askUserToCloseTab:(PTYSession*)session;
{
	NSString* title = NSLocalizedStringFromTableInBundle(@"Do you really want to close this terminal session?",@"iTerm", [NSBundle bundleForClass: [self class]], @"");
    NSMutableString* message = [NSMutableString stringWithString:NSLocalizedStringFromTableInBundle(@"Closing this session will terminate the following processes inside it: ",@"iTerm", [NSBundle bundleForClass: [self class]], @"")];
    NSArray* ttyProcesses = [self runningProcesses:session];
    NSEnumerator *enumerator = [ttyProcesses objectEnumerator];
    ITProcess* process;
    BOOL addComma = NO;
    
    while (process = [enumerator nextObject])
    {
        if (addComma)
            [message appendString:@", "];
        
        addComma = YES;
        
        [message appendString:[process command]];
    }
    
	return NSRunAlertPanel(title,
						   message,
						   NSLocalizedStringFromTableInBundle(@"OK",@"iTerm", [NSBundle bundleForClass: [self class]], @"OK"),
						   NSLocalizedStringFromTableInBundle(@"Cancel",@"iTerm", [NSBundle bundleForClass: [self class]], @"Cancel")
						   , nil);	
}

@end

@implementation ITTerminalView (Resize)

- (NSRect)windowWillUseStandardFrame:(NSRect)defaultFrame
{	
    float nch = [[self window] frame].size.height - [[[self currentSession] scrollView] documentVisibleRect].size.height;
	float wch = [[self window] frame].size.width - [[[self currentSession] scrollView] documentVisibleRect].size.width;
    
    defaultFrame.origin.x = [[self window] frame].origin.x;
    
	int new_height = (defaultFrame.size.height - nch) / [self charHeight];
	int new_width =  (defaultFrame.size.width - wch - MARGIN * 2) /[self charWidth];
	
	defaultFrame.size.height = [self charHeight] * new_height + nch;
	defaultFrame.size.width = ([[PreferencePanel sharedInstance] maxVertically] ? [[self window] frame].size.width : new_width*[self charWidth]+wch+MARGIN*2);
    
	return defaultFrame;
}

@end

@implementation ITTerminalView (Actions)

// this hooks us up to Path Finders tab menu support
- (void)supportsCloseTabMenuItemMessage:(NSMutableDictionary*)outResult;
{
	// had to check for key window, this is sent to first reponder, which can screw up if a panel is in front
	if ([[self window] isKeyWindow])
		[outResult setObject:[NSNumber numberWithInt:[[self sessions] count]] forKey:@"numTabs"];
}

- (void)newTabAction:(id)sender;
{
    [[iTermController sharedInstance] launchBookmark:nil inTerminal:self];
}

- (void)selectNextTabAction:(id)sender;
{
    [mTabView selectNextTabViewItem:nil];
}

- (void)selectPreviousTabAction:(id)sender;
{
    [mTabView selectPreviousTabViewItem:nil];
}

- (BOOL)validateMenuItem:(NSMenuItem *)item
{
    BOOL logging = [[self currentSession] logging];
    BOOL result = YES;
	SEL action = [item action];
	
    if (action == @selector(logStart:)) {
        result = logging == YES ? NO:YES;
    }
    else if (action == @selector(logStop:)) {
        result = logging == NO ? NO:YES;
    }
    else if (action == @selector(selectNextTabAction:) || action == @selector(selectPreviousTabAction:))
	{
		result = [mTabView numberOfTabViewItems] > 1;
			
	}
	
    return result;
}

- (IBAction)closeTabAction:(id)sender
{
	PTYSession *aSession;
	
	if ([sender isKindOfClass:[PTYSession class]])
		aSession = (PTYSession*)sender;
	else
		aSession = [self currentSession];
    
    if (![aSession exited])
    {
		if ([[PreferencePanel sharedInstance] promptOnClose] || ![[aSession parent] terminalIsIdle:aSession])
		{
			int result = [self askUserToCloseTab:aSession];
			
			if (result != NSAlertDefaultReturn)
				return;  // don't close session
		}
    }
	
	[self closeSession:aSession];
} 

// closes a tab
- (void)closeTabContextualMenuAction:(id)sender
{
    [self closeTabAction: [(NSTabViewItem*)[sender representedObject] identifier]];
}

- (void)newSessionInTabAtIndex:(id)sender
{
    [[iTermController sharedInstance] launchBookmark:[sender representedObject] inTerminal:self];
}

- (void)newSessionInWindowAtIndex:(id)sender
{
    [[iTermController sharedInstance] launchBookmark:[sender representedObject] inTerminal:nil];
}

- (void)selectSessionAtIndexAction:(id)sender
{
    [[self tabView] selectTabViewItemAtIndex:[sender tag]];
}

@end

