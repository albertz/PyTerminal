/*
 **  PreferencePanel.h
 **
 **  Copyright (c) 2002, 2003
 **
 **  Author: Fabian, Ujwal S. Setlur
 **
 **  Project: iTerm
 **
 **  Description: Implements the model and controller for the preference panel.
 **
 */

#import <Cocoa/Cocoa.h>

#define OPT_NORMAL 0
#define OPT_META   1
#define OPT_ESC    2

@class iTermController;
@class TreeNode;

typedef enum { CURSOR_UNDERLINE, CURSOR_VERTICAL, CURSOR_BOX } ITermCursorType;

@interface PreferencePanel : NSWindowController <NSWindowDelegate, NSTextFieldDelegate>
{
	IBOutlet NSPopUpButton *windowStyle;
	IBOutlet NSPopUpButton *tabPosition;
    IBOutlet NSOutlineView *urlHandlerOutline;
	IBOutlet NSTableView *urlTable;
    IBOutlet NSButton *selectionCopiesText;
	IBOutlet NSButton *middleButtonPastesFromClipboard;
    IBOutlet NSButton* hideTab;
    IBOutlet NSButton* promptOnClose;
    IBOutlet NSButton *focusFollowsMouse;
	IBOutlet NSTextField *wordChars;
	IBOutlet NSButton *enableBonjour;
    IBOutlet NSButton *cmdSelection;
	IBOutlet NSButton *maxVertically;
	IBOutlet NSButton *useCompactLabel;
    IBOutlet NSButton *openBookmark;
    IBOutlet NSSlider *refreshRate;
	IBOutlet NSMatrix *cursorType;
    
    NSUserDefaults *prefs;

	int defaultWindowStyle;
    BOOL defaultCopySelection;
	BOOL defaultPasteFromClipboard;
    BOOL defaultHideTab;
    int defaultTabViewType;
    BOOL defaultPromptOnClose;
    BOOL defaultFocusFollowsMouse;
	BOOL defaultEnableBonjour;
	BOOL defaultCmdSelection;
	BOOL defaultMaxVertically;
    BOOL defaultUseCompactLabel;
    BOOL defaultOpenBookmark;
    int  defaultRefreshRate;
	NSString *defaultWordChars;
	ITermCursorType defaultCursorType;
	
	// url handler stuff
	NSMutableArray *urlTypes;
	NSMutableDictionary *urlHandlers;
}

+ (PreferencePanel*)sharedInstance;

- (void)readPreferences;
- (void)savePreferences;

- (IBAction)settingChanged:(id)sender;
- (IBAction)connectURL:(id)sender;

- (void)run;

- (BOOL) copySelection;
- (void)setCopySelection: (BOOL) flag;
- (BOOL) pasteFromClipboard;
- (void)setPasteFromClipboard: (BOOL) flag;
- (BOOL) hideTab;
- (NSTabViewType) tabViewType;
- (int) windowStyle;
- (void)setTabViewType: (NSTabViewType) type;
- (BOOL) promptOnClose;
- (BOOL) focusFollowsMouse;
- (BOOL) enableBonjour;
- (BOOL) cmdSelection;
- (BOOL) maxVertically;
- (BOOL) useCompactLabel;
- (BOOL) openBookmark;
- (int)  refreshRate;
- (NSString *) wordChars;
- (ITermCursorType) cursorType;
- (TreeNode *) handlerBookmarkForURL:(NSString *)url;

// Hidden preferences
- (BOOL) useUnevenTabs;
- (int) minTabWidth;
- (int) minCompactTabWidth;
- (int) optimumTabWidth;
- (float) strokeWidth;
- (float) boldStrokeWidth;
- (int) cacheSize;
- (NSString *) searchCommand;

@end
