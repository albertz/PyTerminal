// -*- mode:objc -*-
// $Id: ITTerminalView.h,v 1.52 2007/01/23 04:46:14 yfabian Exp $
/*
 **  ITTerminalView.h
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

#import <Cocoa/Cocoa.h>

@class PTYSession, PTYTabView, ITTerminalWindowController, ITMiscNibController, iTermController, PTToolbarController, PSMTabBarControl;

@interface ITTerminalView : NSView
{
    /// tab view
    PTYTabView *mTabView;
	PSMTabBarControl *mTabBarControl;
	ITMiscNibController* mNibController;

    int mWidth;
	int mHeight;
	int mCharWidth;
	int mCharHeight;
	
	float charHorizontalSpacingMultiplier;
	float charVerticalSpacingMultiplier;
	
    NSFont *FONT, *NAFONT;
	
	BOOL antiAlias;
	    
    BOOL mInitialized;
	BOOL sendInputToAllSessions;
	BOOL suppressContextualMenu;
	
	BOOL mBeingResized;
}

+ (ITTerminalView*)view:(NSDictionary *)entry;

- (void)setupSession: (PTYSession *) aSession title: (NSString *)title;
- (void)insertSession: (PTYSession *) aSession atIndex: (int) index;
- (void)closeSession: (PTYSession*) aSession;
- (IBAction)previousSession:(id)sender;
- (IBAction)nextSession:(id)sender;
- (PTYSession *) currentSession;
- (int) currentSessionIndex;
- (NSString *) currentSessionName;
- (void)setCurrentSessionName: (NSString *) theSessionName;

- (void)updateCurretSessionProfiles;

- (void)startProgram:(NSString *)program;
- (void)startProgram:(NSString *)program
           arguments:(NSArray *)prog_argv;
- (void)startProgram:(NSString *)program
                  arguments:(NSArray *)prog_argv
                environment:(NSDictionary *)prog_env;
- (void)setWindowSize;
- (void)setWindowTitle;
- (void)setWindowTitle: (NSString *)title;
- (void)setFont:(NSFont *)font nafont:(NSFont *)nafont;
- (void)setCharacterSpacingHorizontal: (float) horizontal vertical: (float) vertical;
- (void)changeFontSize: (BOOL) increase;
- (float) largerSizeForSize: (float) aSize;
- (float) smallerSizeForSize: (float) aSize;
- (NSFont *) font;
- (NSFont *) nafont;
- (BOOL) antiAlias;
- (void)setAntiAlias: (BOOL) bAntiAlias;

- (void)setCharSizeUsingFont: (NSFont *)font;
- (int)width;
- (void)setWidth:(int)theWidth;
- (int)height;
- (void)setHeight:(int)theHeight;
- (int)charWidth;
- (void)setCharWidth:(int)theCharWidth;
- (int)charHeight;
- (void)setCharHeight:(int)theCharHeight;

- (float) charSpacingVertical;
- (float) charSpacingHorizontal;
- (BOOL) useTransparency;
- (void)setUseTransparency: (BOOL) flag;

// controls which sessions see key events
- (BOOL) sendInputToAllSessions;
- (void)setSendInputToAllSessions: (BOOL) flag;
- (IBAction)toggleInputToAllSessions:(id)sender;
- (void)sendInputToAllSessions: (NSData *) data;

// iTermController
- (void)clearBuffer:(id)sender;
- (void)clearScrollbackBuffer:(id)sender;
- (IBAction)logStart:(id)sender;
- (IBAction)logStop:(id)sender;

// Contextual menu
- (void)menuForEvent:(NSEvent *)theEvent menu: (NSMenu *) theMenu;
- (BOOL) suppressContextualMenu;
- (void)setSuppressContextualMenu: (BOOL) aBool;
- (NSMenu *)tabView:(NSTabView *)aTabView menuForTabViewItem:(NSTabViewItem *)tabViewItem;

// NSTabView
- (PTYTabView *)tabView;
- (PSMTabBarControl *)tabBarControl;

- (void)moveTabToNewWindowContextualMenuAction:(id)sender;
- (void)setLabelColor: (NSColor *) color forTabViewItem: tabViewItem;

// Bookmarks
- (id)commandField;

- (void)runCommand:(NSString*)command;
- (NSArray*)ttyPIDs:(BOOL)currentSessionOnly;
- (BOOL)terminalIsIdle:(PTYSession*)session;  // pass nil for all sessions 
- (void)newTabWithDirectory:(NSString*)path;
- (void)makeFirstResponder;

// Utility methods
+ (void) breakDown:(NSString *)cmdl cmdPath: (NSString **) cmd cmdArgs: (NSArray **) path;

- (void)addNewSession:(NSDictionary *)addressbookEntry
		  withCommand:(NSString *)command
			  withURL:(NSString*)url;

- (void)appendSession:(PTYSession *)object;
- (void)removeFromSessionsAtIndex:(unsigned)index;
- (NSArray*)sessions;
- (void)addInSessions:(PTYSession *)object;
- (void)insertInSessions:(PTYSession *)object;
- (void)insertInSessions:(PTYSession *)object atIndex:(unsigned)index;
@end

@interface ITTerminalView (ScriptingSupport)

// Object specifier
- (NSScriptObjectSpecifier *)objectSpecifier;

- (void)handleSelectScriptCommand: (NSScriptCommand *)command;

- (void)handleLaunchScriptCommand: (NSScriptCommand *)command;
@end


@interface ITTerminalView (WindowStuffTemp)
- (NSRect)windowWillUseStandardFrame:(NSRect)defaultFrame;
@end



