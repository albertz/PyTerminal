// -*- mode:objc -*-
// $Id: PTYTextView.h,v 1.66 2007/01/10 07:42:05 yfabian Exp $
//
/*
 **  PTYTextView.h
 **
 **  Copyright (c) 2002, 2003
 **
 **  Author: Fabian, Ujwal S. Setlur
 **	     Initial code by Kiichi Kusama
 **
 **  Project: iTerm
 **
 **  Description: NSTextView subclass. The view object for the VT100 screen.
 **
 */

#import <Cocoa/Cocoa.h>
#import "iTerm.h"

#include <sys/time.h>

#define MARGIN  5
#define VMARGIN 5

@class VT100Screen;

typedef struct 
{
	int code;
	unsigned int color;
	unsigned int bgColor;
	NSImage *image;
	int count;
} CharCache;
	
enum { SELECT_CHAR, SELECT_WORD, SELECT_LINE };

@interface PTYTextView : NSView <NSTextInput>
{
    // This is a flag to let us know whether we are handling this
    // particular drag and drop operation. We are using it because
    // the prepareDragOperation and performDragOperation of the
    // parent NSTextView class return "YES" even if the parent
    // cannot handle the drag type. To make matters worse, the
    // concludeDragOperation does not have any return value.
    // This all results in the inability to test whether the
    // parent could handle the drag type properly. Is this a Cocoa
    // implementation bug?
    // Fortunately, the draggingEntered and draggingUpdated methods
    // seem to return a real status, based on which we can set this flag.
    BOOL bExtendedDragNDrop;

    // anti-alias flag
    BOOL antiAlias;
	
	// option to not render in bold
	BOOL disableBold;

	// NSTextInput support
    BOOL IM_INPUT_INSERT;
    NSRange IM_INPUT_SELRANGE;
    NSRange IM_INPUT_MARKEDRANGE;
    NSDictionary *markedTextAttributes;
    NSAttributedString *markedText;
	
    BOOL CURSOR;
	BOOL mForceUpdate;
	
	// wacky hack to fixing drawing problems when resizing splitview vertically only
	NSSize mPreviousWindowSize;
	NSRect mPreviousViewRect;
	
    // geometry
	float mLineHeight;
	float mCharWidth;
	float mCharWidthWithoutSpacing;
	float mCharHeightWithoutSpacing;
	int mNumberOfLines;
    
    NSFont *font;
    NSFont *nafont;
    NSColor* colorTable[16];
    NSColor* defaultFGColor;
    NSColor* defaultBGColor;
    NSColor* defaultBoldColor;
	NSColor* defaultCursorColor;
	NSColor* selectionColor;
	NSColor* selectedTextColor;
	NSColor* cursorTextColor;
	
	// transparency
	float transparency;
    BOOL useTransparency;
	
    // data source
    VT100Screen *mScreen;
    id _delegate;
	
    //selection
    int startX, startY, endX, endY;
	BOOL mouseDown;
	BOOL mouseDragged;
    char selectMode;
	BOOL mouseDownOnSelection;
	NSEvent *mouseDownEvent;
		
	//find support
	int lastFindX, lastFindY;
	
	BOOL reportingMouseDown;
	
	//cache
	CharCache	*charImages;
	
	// blinking cursor
	BOOL blinkingCursor;
	BOOL showCursor;
	BOOL blinkShow;
    struct timeval lastBlink;
    int oldCursorX, oldCursorY;
	
	// trackingRect tab
	NSTrackingRectTag trackingRectTag;
	
	BOOL keyIsARepeat;
}

+ (NSCursor *) textViewCursor;
- (id)initWithFrame: (NSRect) aRect;
- (void)dealloc;
- (BOOL)isFlipped;
- (BOOL)isOpaque;
- (BOOL)shouldDrawInsertionPoint;
- (void)drawRect:(NSRect)rect;
- (void)keyDown:(NSEvent *)event;
- (BOOL) keyIsARepeat;
- (void)mouseExited:(NSEvent *)event;
- (void)mouseEntered:(NSEvent *)event;
- (void)mouseDown:(NSEvent *)event;
- (void)mouseUp:(NSEvent *)event;
- (void)mouseDragged:(NSEvent *)event;
- (void)otherMouseDown: (NSEvent *) event;
- (void)otherMouseUp:(NSEvent *)event;
- (void)otherMouseDragged:(NSEvent *)event;
- (void)rightMouseDown:(NSEvent *)event;
- (void)rightMouseUp:(NSEvent *)event;
- (void)rightMouseDragged:(NSEvent *)event;
- (void)scrollWheel:(NSEvent *)event;
- (NSString *) contentFromX:(int)startx Y:(int)starty ToX:(int)endx Y:(int)endy pad: (BOOL) pad;
- (NSString *) selectedText;
- (NSString *) selectedTextWithPad: (BOOL) pad;
- (NSString *) content;
- (void)copy:(id)sender;
- (void)paste:(id)sender;
- (void)pasteSelection:(id)sender;
- (BOOL)validateMenuItem:(NSMenuItem *)item;
- (void)changeFont:(id)sender;
- (NSMenu *)menuForEvent:(NSEvent *)theEvent;
- (void)browse:(id)sender;
- (void)searchInBrowser:(id)sender;
- (void)mail:(id)sender;

//get/set methods
- (NSFont *)font;
- (NSFont *)nafont;
- (void)setFont:(NSFont*)aFont nafont:(NSFont*)naFont;
- (BOOL) antiAlias;
- (void)setAntiAlias: (BOOL) antiAliasFlag;
- (BOOL) disableBold;
- (void)setDisableBold: (BOOL) boldFlag;
- (BOOL) blinkingCursor;
- (void)setBlinkingCursor: (BOOL) bFlag;

//color stuff
- (NSColor *) defaultFGColor;
- (NSColor *) defaultBGColor;
- (NSColor *) defaultBoldColor;
- (NSColor *) colorForCode:(unsigned int) index;
- (NSColor *) selectionColor;
- (NSColor *) defaultCursorColor;
- (NSColor *) selectedTextColor;
- (NSColor *) cursorTextColor;
- (void)setFGColor:(NSColor*)color;
- (void)setBGColor:(NSColor*)color;
- (void)setBoldColor:(NSColor*)color;
- (void)setColorTable:(int) index highLight:(BOOL)hili color:(NSColor *) c;
- (void)setSelectionColor: (NSColor *) aColor;
- (void)setCursorColor:(NSColor*) color;
- (void)setSelectedTextColor: (NSColor *) aColor;
- (void)setCursorTextColor:(NSColor*) color;

- (NSDictionary*) markedTextAttributes;
- (void)setMarkedTextAttributes: (NSDictionary *) attr;

- (VT100Screen *)screen;
- (void)setScreen:(VT100Screen *)theScreen;

- (id)delegate;
- (void)setDelegate:(id)delegate;

- (float)lineHeight;
- (void)setLineHeight:(float)theLineHeight;

- (float)charWidth;
- (void)setCharWidth:(float)theCharWidth;

- (float)charWidthWithoutSpacing;
- (void)setCharWidthWithoutSpacing:(float)theCharWidthWithoutSpacing;

- (float)charHeightWithoutSpacing;
- (void)setCharHeightWithoutSpacing:(float)theCharHeightWithoutSpacing;

- (int)numberOfLines;
- (void)setNumberOfLines:(int)theNumberOfLines;

- (void)refresh;
- (void)setFrameSize: (NSSize) aSize;

- (BOOL)forceUpdate;
- (void)setForceUpdate:(BOOL)flag;

- (void)showCursor;
- (void)hideCursor;

// selection
- (IBAction)selectAll:(id)sender;
- (void)deselect;

// transparency
- (float) transparency;
- (void)setTransparency: (float) fVal;
- (BOOL) useTransparency;
- (void)setUseTransparency: (BOOL) flag;

//
// Drag and Drop methods for our text view
//
- (unsigned int) draggingEntered: (id<NSDraggingInfo>) sender;
- (unsigned int) draggingUpdated: (id<NSDraggingInfo>) sender;
- (void)draggingExited: (id<NSDraggingInfo>) sender;
- (BOOL) prepareForDragOperation: (id<NSDraggingInfo>) sender;
- (BOOL) performDragOperation: (id<NSDraggingInfo>) sender;
- (void)concludeDragOperation: (id<NSDraggingInfo>) sender;

// Cursor control
- (void)resetCursorRects;

// Scrolling control
- (void)scrollLineUp:(id)sender;
- (void)scrollLineDown:(id)sender;
- (void)scrollPageUp:(id)sender;
- (void)scrollPageDown:(id)sender;
- (void)scrollHome;
- (void)scrollEnd;
- (void)scrollToSelection;

    // Save method
- (void)saveDocumentAs:(id)sender;
- (void)print:(id)sender;
- (void)printContent: (NSString *) aString;

// Find method
- (void)findString: (NSString *) aString forwardDirection: (BOOL) direction ignoringCase: (BOOL) ignoreCase;

// NSTextInput
- (void)insertText:(id)aString;
- (void)setMarkedText:(id)aString selectedRange:(NSRange)selRange;
- (void)unmarkText;
- (BOOL)hasMarkedText;
- (NSRange)markedRange;
- (NSRange)selectedRange;
- (NSArray *)validAttributesForMarkedText;
- (NSAttributedString *)attributedSubstringFromRange:(NSRange)theRange;
- (void)doCommandBySelector:(SEL)aSelector;
- (unsigned int)characterIndexForPoint:(NSPoint)thePoint;
- (long)conversationIdentifier;
- (NSRect)firstRectForCharacterRange:(NSRange)theRange;

	// service stuff
- (id)validRequestorForSendType:(NSString *)sendType returnType:(NSString *)returnType;
- (BOOL)writeSelectionToPasteboard:(NSPasteboard *)pboard types:(NSArray *)types;
- (BOOL)readSelectionFromPasteboard:(NSPasteboard *)pboard;	

- (void)resetCharCache;

@end

