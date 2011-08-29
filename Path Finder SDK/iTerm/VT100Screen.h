// -*- mode:objc -*-
// $Id: VT100Screen.h,v 1.34 2007/01/17 07:31:20 yfabian Exp $
/*
 **  VT100Screen.h
 **
 **  Copyright (c) 2002, 2003
 **
 **  Author: Fabian, Ujwal S. Setlur
 **	     Initial code by Kiichi Kusama
 **
 **  Project: iTerm
 **
 **  Description: Implements the VT100 screen.
 **
 */

#import <Cocoa/Cocoa.h>
#import "VT100Terminal.h"

enum { NO_CHANGE, CHANGE, CHANGE_PIXEL };
	
@class PTYTask;
@class PTYSession;
@class PTYTextView;

typedef struct screen_char_t
{
	unichar ch;    // the actual character
	unsigned int bg_color; // background color
	unsigned int fg_color; // foreground color
} screen_char_t;

#define TABWINDOW	300

@interface VT100Screen : NSObject
{
    int WIDTH; // width of screen
    int HEIGHT; // height of screen
    int CURSOR_X;
    int CURSOR_Y;
    int SAVE_CURSOR_X;
    int SAVE_CURSOR_Y;
    int SCROLL_TOP;
    int SCROLL_BOTTOM;
    BOOL tabStop[TABWINDOW];
    
    VT100Terminal *TERMINAL;
    PTYTask *SHELL;
    PTYSession *SESSION;
    int charset[4], saveCharset[4];
    BOOL blinkShow;
	BOOL PLAYBELL;
	BOOL SHOWBELL;
    
    BOOL blinkingCursor;
    PTYTextView *display;
	
	// single buffer that holds both scrollback and screen contents
	screen_char_t *buffer_lines;
	// buffer holding flags for each char on whether it needs to be redrawn
	char *dirty;
	// a single default line
	screen_char_t *default_line;
	// temporary buffer to store main buffer in SAVE_BUFFER/RESET_BUFFER mode
	screen_char_t *temp_buffer;
	
	// pointer to last line in buffer
	screen_char_t *last_buffer_line;
	// pointer to first screen line
	screen_char_t *screen_top;
	//pointer to first scrollback line
	screen_char_t *scrollback_top;
	
	// default line stuff
	char default_bg_code;
	char default_fg_code;
	int default_line_width;

	//scroll back stuff
	BOOL dynamic_scrollback_size;
	// max size of scrollback buffer
    unsigned int  max_scrollback_lines;
	// current number of lines in scrollback buffer
	unsigned int current_scrollback_lines;
		
	
	// print to ansi...
	BOOL printToAnsi;		// YES=ON, NO=OFF, default=NO;
	NSMutableString *printToAnsiString;
	
	NSLock *mScreenLock;
	
	// UI related
	int changeSize;
	int newWidth,  newHeight;
	NSString *winTitle;
	NSString *iconTitle;
	BOOL bell;
	int scrollUpLines;
	BOOL printPending;
}

@property (retain) NSString *winTitle;
@property (retain) NSString *iconTitle;

- (id)init;
- (void)dealloc;

- (NSString *)description;

- (void)initScreenWithWidth:(int)width Height:(int)height;
- (void)resizeWidth:(int)width height:(int)height;
- (void)reset;
- (void)setWidth:(int)width height:(int)height;
- (int)width;
- (int)height;
- (unsigned int)scrollbackLines;
- (void)setScrollback:(unsigned int)lines;
- (void)setTerminal:(VT100Terminal *)terminal;
- (VT100Terminal *)terminal;
- (void)setShellTask:(PTYTask *)shell;
- (PTYTask *)shellTask;
- (PTYSession *) session;
- (void)setSession:(PTYSession *)session;

- (PTYTextView *) display;
- (void)setDisplay: (PTYTextView *) aDisplay;

- (BOOL) blinkingCursor;
- (void)setBlinkingCursor: (BOOL) flag;
- (void)showCursor:(BOOL)show;
- (void)setPlayBellFlag:(BOOL)flag;
- (void)setShowBellFlag:(BOOL)flag;

// line access
- (screen_char_t *) getLineAtIndex: (int) theIndex;
- (screen_char_t *) getLineAtScreenIndex: (int) theIndex;
- (char *) dirty;
- (NSString *) getLineString: (screen_char_t *) theLine;

// lock
- (void)acquireLock;
- (void)releaseLock;
- (BOOL) tryLock;

// edit screen buffer
- (void)putToken:(VT100TCC)token;
- (void)clearBuffer;
- (void)clearScrollbackBuffer;
- (void)saveBuffer;
- (void)restoreBuffer;

// internal
- (void)setString:(NSString *)s ascii:(BOOL)ascii;
- (void)setStringToX:(int)x
				   Y:(int)y
			  string:(NSString *)string
			   ascii:(BOOL)ascii;
- (void)setNewLine;
- (void)deleteCharacters:(int)n;
- (void)backSpace;
- (void)setTab;
- (void)clearTabStop;
- (void)clearScreen;
- (void)eraseInDisplay:(VT100TCC)token;
- (void)eraseInLine:(VT100TCC)token;
- (void)selectGraphicRendition:(VT100TCC)token;
- (void)cursorLeft:(int)n;
- (void)cursorRight:(int)n;
- (void)cursorUp:(int)n;
- (void)cursorDown:(int)n;
- (void)cursorToX: (int) x;
- (void)cursorToX:(int)x Y:(int)y; 
- (void)saveCursorPosition;
- (void)restoreCursorPosition;
- (void)setTopBottom:(VT100TCC)token;
- (void)scrollUp;
- (void)scrollDown;
- (void)activateBell;
- (void)deviceReport:(VT100TCC)token;
- (void)deviceAttribute:(VT100TCC)token;
- (void)insertBlank: (int)n;
- (void)insertLines: (int)n;
- (void)deleteLines: (int)n;
- (void)blink;
- (int) cursorX;
- (int) cursorY;

- (void)updateScreen;
- (int) numberOfLines;

- (void)resetDirty;
- (void)setDirty;

// print to ansi...
- (BOOL) printToAnsi;
- (void)setPrintToAnsi: (BOOL) aFlag;
- (void)printStringToAnsi: (NSString *) aString;

// UI stuff
- (int)changeSize;
- (int)newWidth;
- (int)newHeight;
- (void)resetChangeSize;
- (void)resetChangeTitle;
- (void)updateBell;
- (void)setBell;
- (int) scrollUpLines;
- (void)resetScrollUpLines;
- (BOOL) printPending;
- (void)doPrint;

// double width
- (BOOL) isDoubleWidthCharacter:(unichar) c;

@end
