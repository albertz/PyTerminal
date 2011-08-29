/*
 **  PTYSession.h
 **
 **  Copyright (c) 2002, 2003
 **
 **  Author: Fabian, Ujwal S. Setlur
 **
 **  Project: iTerm
 **
 **  Description: Implements the model class for a terminal session.
 **
 */

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

#include <sys/time.h>

@class PTYTask;
@class PTYTextView;
@class PTYScrollView;
@class VT100Screen;
@class VT100Terminal;
@class PreferencePanel;
@class ITTerminalView;
@class iTermController;

@interface PTYSession : NSResponder
{        
    // Owning tab view item
    NSTabViewItem *tabViewItem;
	
    // tty device
    NSString *tty;
    
    ITTerminalView *parent;  // parent controller
    NSString *name;
	NSString *defaultName;
    NSString *windowTitle;
	
    PTYTask *SHELL;
    VT100Terminal *TERMINAL;
    NSString *TERM_VALUE;
    VT100Screen   *SCREEN;
    BOOL EXIT;
    PTYScrollView *mScrollView;
    PTYTextView *mTextView;
    
    // anti-idle
    BOOL antiIdle;
    char ai_code;

    BOOL autoClose;
    BOOL doubleWidth;
	BOOL xtermMouseReporting;
    int bell;

    NSDictionary *addressBookEntry;
    
    // Status reporting
    struct timeval lastInput, lastOutput, lastUpdate, lastBlink;
    int objectCount;
	NSImage *icon;
	BOOL isProcessing;
    BOOL newOutput;
		
	// semaphore to coordinate updating UI
	MPSemaphoreID	updateSemaphore;
	
	// update timer stuff
	NSTimer *updateTimer;
	unsigned int updateCount;
}

// Session specific methods
- (void)initScreen: (NSRect) aRect width:(int)width height:(int) height;
- (void)startProgram:(NSString *)program
	   arguments:(NSArray *)prog_argv
	 environment:(NSDictionary *)prog_env;
- (void)terminate;
- (BOOL) isActiveSession;

// Preferences
- (void)setPreferencesFromAddressBookEntry: (NSDictionary *) aePrefs;

// PTYTask
- (void)writeTask:(NSData *)data;
- (void)readTask:(char *)buf length:(int)length;
- (void)brokenPipe;

- (PTYTextView *)textView;
- (PTYScrollView *)scrollView;

// PTYTextView
- (BOOL)hasKeyMappingForEvent: (NSEvent *) event highPriority: (BOOL) priority;
- (void)keyDown:(NSEvent *)event;
- (BOOL)willHandleEvent: (NSEvent *) theEvent;
- (BOOL)handleEvent: (NSEvent *) theEvent;
- (void)insertText:(NSString *)string;
- (void)insertNewline:(id)sender;
- (void)insertTab:(id)sender;
- (void)moveUp:(id)sender;
- (void)moveDown:(id)sender;
- (void)moveLeft:(id)sender;
- (void)moveRight:(id)sender;
- (void)pageUp:(id)sender;
- (void)pageDown:(id)sender;
- (void)paste:(id)sender;
- (void)pasteString: (NSString *) aString;
- (void)deleteBackward:(id)sender;
- (void)deleteForward:(id)sender;
- (void)textViewDidChangeSelection: (NSNotification *) aNotification;
- (void)textViewResized: (NSNotification *) aNotification;
- (void)tabViewWillRedraw: (NSNotification *) aNotification;

// misc
- (void)handleOptionClick: (NSEvent *) theEvent;
- (void)doIdleTasks;

// Contextual menu
- (void)menuForEvent:(NSEvent *)theEvent menu: (NSMenu *) theMenu;

// get/set methods
- (ITTerminalView *) parent;
- (void)setParent: (ITTerminalView *) theParent;
- (NSTabViewItem *) tabViewItem;
- (void)setTabViewItem: (NSTabViewItem *) theTabViewItem;
- (NSString *) name;
- (void)setName: (NSString *) theName;
- (NSString *) defaultName;
- (void)setDefaultName: (NSString *) theName;
- (NSString *) uniqueID;
- (void)setUniqueID: (NSString *)uniqueID;
- (NSString *) windowTitle;
- (void)setWindowTitle: (NSString *) theTitle;
- (PTYTask *) SHELL;
- (void)setSHELL: (PTYTask *) theSHELL;
- (VT100Terminal *) TERMINAL;
- (void)setTERMINAL: (VT100Terminal *) theTERMINAL;
- (NSString *) TERM_VALUE;
- (void)setTERM_VALUE: (NSString *) theTERM_VALUE;
- (VT100Screen *) SCREEN;
- (void)setSCREEN: (VT100Screen *) theSCREEN;
- (NSView *) view;
- (NSStringEncoding) encoding;
- (void)setEncoding:(NSStringEncoding)encoding;
- (BOOL) antiIdle;
- (int) antiCode;
- (void)setAntiIdle:(BOOL)set;
- (void)setAntiCode:(int)code;
- (BOOL) autoClose;
- (void)setAutoClose:(BOOL)set;
- (BOOL) doubleWidth;
- (void)setDoubleWidth:(BOOL)set;
- (BOOL) xtermMouseReporting;
- (void)setXtermMouseReporting:(BOOL)set;
- (NSDictionary *) addressBookEntry;
- (void)setAddressBookEntry:(NSDictionary*) entry;
- (int) number;
- (int) objectCount;
- (int) realObjectCount;
- (void)setObjectCount:(int)value;
- (NSString *) tty;
- (NSString *) contents;
- (NSImage *) icon;
- (void)setIcon: (NSImage *) anIcon;
- (NSNumber*)ttyPID;

- (void)clearBuffer;
- (void)clearScrollbackBuffer;
- (BOOL)logging;
- (void)logStart;
- (void)logStop;
- (NSColor *) foregroundColor;
- (void)setForegroundColor:(NSColor*) color;
- (NSColor *) backgroundColor;
- (void)setBackgroundColor:(NSColor*) color;
- (NSColor *) selectionColor;
- (void)setSelectionColor: (NSColor *) color;
- (NSColor *) boldColor;
- (void)setBoldColor:(NSColor*) color;
- (NSColor *) cursorColor;
- (void)setCursorColor:(NSColor*) color;
- (NSColor *) selectedTextColor;
- (void)setSelectedTextColor: (NSColor *) aColor;
- (NSColor *) cursorTextColor;
- (void)setCursorTextColor: (NSColor *) aColor;
- (float) transparency;
- (void)setTransparency:(float)transparency;

- (BOOL)useTransparency;
- (void)setUseTransparency:(BOOL)useTransparency;

- (BOOL) disableBold;
- (void)setDisableBold: (BOOL) boldFlag;
- (BOOL) disableBold;
- (void)setDisableBold: (BOOL) boldFlag;
- (void)setColorTable:(int) index highLight:(BOOL)hili color:(NSColor *) c;
- (int) optionKey;

// Session status
- (void)resetStatus;
- (BOOL)exited;
- (void)setLabelAttribute;
- (BOOL)bell;
- (void)setBell: (BOOL) flag;
- (BOOL)isProcessing;
- (void)setIsProcessing: (BOOL) aFlag;

- (void)runCommand: (NSString *)command;

// Display timer stuff
- (void)updateDisplay;
- (void)signalUpdateSemaphore;

enum {
	FAST_MODE, SLOW_MODE
};

- (void)setTimerMode:(int)mode;
@end

@interface PTYSession (ScriptingSupport)

// Object specifier
- (NSScriptObjectSpecifier *)objectSpecifier;
- (void)handleExecScriptCommand: (NSScriptCommand *)aCommand;
- (void)handleTerminateScriptCommand: (NSScriptCommand *)command;
- (void)handleSelectScriptCommand: (NSScriptCommand *)command;
- (void)handleWriteScriptCommand: (NSScriptCommand *)command;
@end
