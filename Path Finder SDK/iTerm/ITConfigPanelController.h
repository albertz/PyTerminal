/*
 **  ITConfigPanelController.h
 **
 **  Copyright (c) 2002, 2003
 **
 **  Author: Fabian, Ujwal S. Setlur
 **	     Initial code by Kiichi Kusama
 **
 **  Project: iTerm
 **
 **  Description: controls the config sheet.
 **
 */

#import <Cocoa/Cocoa.h>

@class ITTerminalView;

@interface ITConfigPanelController : NSWindowController <NSWindowDelegate>
{
    ITTerminalView* _pseudoTerminal;
    
    IBOutlet NSPopUpButton *CONFIG_ENCODING;
    IBOutlet NSColorWell *CONFIG_BACKGROUND;
    IBOutlet NSColorWell *CONFIG_FOREGROUND;
    IBOutlet id CONFIG_EXAMPLE;
    IBOutlet id CONFIG_NAEXAMPLE;
    IBOutlet id CONFIG_TRANSPARENCY;
    IBOutlet id CONFIG_TRANS2;
    IBOutlet id CONFIG_NAME;
    IBOutlet NSButton* CONFIG_ANTIALIAS;
    IBOutlet NSColorWell *CONFIG_SELECTION;
    IBOutlet NSColorWell *CONFIG_BOLD;
	IBOutlet NSColorWell *CONFIG_CURSOR;
	IBOutlet NSColorWell *CONFIG_CURSORTEXT;
	IBOutlet NSColorWell *CONFIG_SELECTIONTEXT;
    
    // anti-idle
    IBOutlet id AI_CODE;
    IBOutlet NSButton* AI_ON;
    char ai_code;    
    
    BOOL changingNA;
	IBOutlet NSSlider *charHorizontalSpacing;
	IBOutlet NSSlider *charVerticalSpacing;
	
	IBOutlet NSButton *boldButton;
	IBOutlet NSButton *transparencyButton;
	IBOutlet NSButton *updateProfileButton;
	
	NSFont *mConfigFont;
	NSFont *mConfigNAFont;

	// for bindings
	NSNumber* mTransparencyValue;
}

+ (id)singleInstance;

+ (void)show;
+ (void)close;
+ (BOOL)onScreen;

- (void)loadConfigWindow: (NSNotification *) aNotification;

// actions
- (IBAction)setWindowSize:(id)sender;
- (IBAction)setCharacterSpacing:(id)sender;
- (IBAction)toggleAntiAlias:(id)sender;
- (IBAction)setForegroundColor:(id)sender;
- (IBAction)setBackgroundColor:(id)sender;
- (IBAction)setBoldColor:(id)sender;
- (IBAction)setSelectionColor:(id)sender;
- (IBAction)setSelectedTextColor:(id)sender;
- (IBAction)setCursorColor:(id)sender;
- (IBAction)setCursorTextColor:(id)sender;
- (IBAction)setSessionName:(id)sender;
- (IBAction)setSessionEncoding:(id)sender;
- (IBAction)setAntiIdle:(id)sender;
- (IBAction)setAntiIdleCode:(id)sender;
- (IBAction)windowConfigFont:(id)sender;
- (IBAction)windowConfigNAFont:(id)sender;
- (IBAction)setBold:(id)sender;
- (IBAction)updateProfile:(id)sender;

@end
