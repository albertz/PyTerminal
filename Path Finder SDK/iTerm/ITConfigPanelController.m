/*
 **  ITConfigPanelController.m
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

#import "ITConfigPanelController.h"
#import "ITViewLocalizer.h"
#import "ITAddressBookMgr.h"
#import "iTermController.h"
#import "PTYSession.h"
#import "ITTerminalView.h"
#import "VT100Screen.h"
#import "PTYTextView.h"
#import "PTYScrollView.h"
#import "iTermDisplayProfileMgr.h"
#import "iTermTerminalProfileMgr.h"

static ITConfigPanelController *singleInstance = nil;
static BOOL onScreen = NO;

@interface ITConfigPanelController (Bindings)
- (NSNumber *)transparencyValue;
- (void)setTransparencyValue:(NSNumber *)theTransparencyValue;
@end

@interface ITConfigPanelController (Private)
- (NSFont *)configFont;
- (void)setConfigFont:(NSFont *)theConfigFont;

- (NSFont *)configNAFont;
- (void)setConfigNAFont:(NSFont *)theConfigNAFont;
@end

@implementation ITConfigPanelController

+ (void)show
{
    // controller will be deleted when closed
	if (singleInstance == nil)
		singleInstance = [[ITConfigPanelController alloc] initWithWindowNibName:@"ITConfigPanel"];
	
    [singleInstance loadConfigWindow: nil];
	
	[[singleInstance window] setFrameAutosaveName: @"Config Panel"];
	[[singleInstance window] makeKeyAndOrderFront: self];
    onScreen = YES;
}

+ (void) close
{
	if (singleInstance != nil)
		[[singleInstance window] performClose: self];
}

+ (BOOL) onScreen
{
    return onScreen;
}

+ (id)singleInstance
{
	return singleInstance;
}

- (void)dealloc
{
	if (self == singleInstance)
		singleInstance = nil;
	
	[self setTransparencyValue:nil];
	[self setConfigFont:nil];
    [self setConfigNAFont:nil];

    [super dealloc];
}

- (void)windowDidBecomeKey:(NSNotification *)notification
{
	[self loadConfigWindow:nil];
}

- (void)windowWillClose:(NSNotification *)notification
{
	[[NSColorPanel sharedColorPanel] close];
	[[NSFontPanel sharedFontPanel] close];
    onScreen = NO;
	
    // since this NSWindowController doesn't have a document, the releasing is not automatic when the window closes
    [self autorelease];
}

- (void)windowDidLoad
{
	[NTLocalizedString localizeWindow:[self window] table:@"terminal"];
}

// actions
- (IBAction)setWindowSize:(id)sender
{
}

- (IBAction)setCharacterSpacing:(id)sender
{
	[_pseudoTerminal setCharacterSpacingHorizontal: [charHorizontalSpacing floatValue] 
										  vertical: [charVerticalSpacing floatValue]];
}

- (IBAction)toggleAntiAlias:(NSButton*)sender
{
	[_pseudoTerminal setAntiAlias: ([CONFIG_ANTIALIAS state] == NSOnState)];
}

- (IBAction)setBold:(id)sender
{
	[[_pseudoTerminal currentSession] setDisableBold: ([boldButton state] == NSOffState)];
    [CONFIG_BOLD setEnabled:[boldButton state]];
}

- (IBAction)updateProfile:(id)sender
{
    [_pseudoTerminal updateCurretSessionProfiles];
}

- (IBAction)setTransparency:(id)sender
{
	// toggle it
	[_pseudoTerminal setUseTransparency:![_pseudoTerminal useTransparency]];
}

- (IBAction)setForegroundColor:(id)sender
{
	[CONFIG_EXAMPLE setTextColor:[CONFIG_FOREGROUND color]];
    [CONFIG_NAEXAMPLE setTextColor:[CONFIG_FOREGROUND color]];
	[[_pseudoTerminal currentSession] setForegroundColor:  [CONFIG_FOREGROUND color]];
}

- (IBAction)setBackgroundColor:(id)sender
{
	NSColor *bgColor;
	
	// set the background color for the scrollview with the appropriate transparency
	bgColor = [[CONFIG_BACKGROUND color] colorWithAlphaComponent: (1-[CONFIG_TRANSPARENCY floatValue]/100.0)];
	[[[_pseudoTerminal currentSession] scrollView] setBackgroundColor: bgColor];
	[[_pseudoTerminal currentSession] setBackgroundColor:  bgColor];
	[[[_pseudoTerminal currentSession] textView] setNeedsDisplay:YES];
	
	[CONFIG_EXAMPLE setBackgroundColor:[CONFIG_BACKGROUND color]];
    [CONFIG_NAEXAMPLE setBackgroundColor:[CONFIG_BACKGROUND color]];
}

- (IBAction)setBoldColor:(id)sender
{
	[[_pseudoTerminal currentSession] setBoldColor: [CONFIG_BOLD color]];
}

- (IBAction)setSelectionColor:(id)sender
{
	[[[_pseudoTerminal currentSession] textView] setSelectionColor: [CONFIG_SELECTION color]];
}

- (IBAction)setSelectedTextColor:(id)sender
{
	[[[_pseudoTerminal currentSession] textView] setSelectedTextColor: [CONFIG_SELECTIONTEXT color]];
}

- (IBAction)setCursorColor:(id)sender
{
	[[_pseudoTerminal currentSession] setCursorColor: [CONFIG_CURSOR color]];
}

- (IBAction)setCursorTextColor:(id)sender
{
	[[[_pseudoTerminal currentSession] textView] setCursorTextColor: [CONFIG_CURSORTEXT color]];
}

- (IBAction)setSessionName:(id)sender
{
	[_pseudoTerminal setCurrentSessionName: [CONFIG_NAME stringValue]]; 
}

- (IBAction)setSessionEncoding:(id)sender
{
	[[_pseudoTerminal currentSession] setEncoding:[[CONFIG_ENCODING selectedItem] tag]];
}

- (IBAction)setAntiIdle:(id)sender
{
	[[_pseudoTerminal currentSession] setAntiIdle:([AI_ON state]==NSOnState)];
}

- (IBAction)setAntiIdleCode:(id)sender
{
	[[_pseudoTerminal currentSession] setAntiCode:[AI_CODE intValue]];
}

- (IBAction)windowConfigFont:(id)sender
{
	NSFontPanel *aFontPanel;
	
    changingNA=NO;
    [[CONFIG_EXAMPLE window] makeFirstResponder:[CONFIG_EXAMPLE window]];
    [[CONFIG_EXAMPLE window] setDelegate:self];
	aFontPanel = [[NSFontManager sharedFontManager] fontPanel: YES];
	[aFontPanel setAccessoryView: nil];
    [[NSFontManager sharedFontManager] setSelectedFont:[self configFont] isMultiple:NO];
    [[NSFontManager sharedFontManager] orderFrontFontPanel:self];
}

- (IBAction)windowConfigNAFont:(id)sender
{
	NSFontPanel *aFontPanel;

    changingNA=YES;
    [[CONFIG_NAEXAMPLE window] makeFirstResponder:[CONFIG_NAEXAMPLE window]];
    [[CONFIG_NAEXAMPLE window] setDelegate:self];
	aFontPanel = [[NSFontManager sharedFontManager] fontPanel: YES];
	[aFontPanel setAccessoryView: nil];
    [[NSFontManager sharedFontManager] setSelectedFont:[self configNAFont] isMultiple:NO];
    [[NSFontManager sharedFontManager] orderFrontFontPanel:self];
}

- (void)changeFont:(id)sender
{
	NSFont* newFont;
	
    if (changingNA)
    {
        newFont=[[NSFontManager sharedFontManager] convertFont:[self configNAFont]];
        if (newFont!=nil)
        {
			[self setConfigNAFont:newFont];
            [CONFIG_NAEXAMPLE setStringValue:[NSString stringWithFormat:@"%@ %g", [newFont fontName], [newFont pointSize]]];
            [CONFIG_NAEXAMPLE setFont:newFont];
        }
    }
    else
    {
        newFont=[[NSFontManager sharedFontManager] convertFont:[self configFont]];
        if (newFont!=nil) 
        {
			[self setConfigFont:newFont];
            [CONFIG_EXAMPLE setStringValue:[NSString stringWithFormat:@"%@ %g", [newFont fontName], [newFont pointSize]]];
            [CONFIG_EXAMPLE setFont:newFont];
        }
    }
	
	[_pseudoTerminal setFont:[self configFont] nafont:[self configNAFont]];
}

// config panel sheet
- (void)loadConfigWindow: (NSNotification *) aNotification
{
	NSEnumerator *anEnumerator;
	NSNumber *anEncoding;
	
	[self window]; // force window to load
	
    _pseudoTerminal = [[iTermController sharedInstance] currentTerminal]; // don't retain
	if (_pseudoTerminal == nil)
		return;
	
    PTYSession* currentSession = [_pseudoTerminal currentSession];
	
    [CONFIG_FOREGROUND setColor:[[currentSession textView] defaultFGColor]];
    [CONFIG_BACKGROUND setColor:[[currentSession textView] defaultBGColor]];
  //  [CONFIG_BACKGROUND setEnabled: NO];
    [CONFIG_SELECTION setColor:[[currentSession textView] selectionColor]];
    [CONFIG_SELECTIONTEXT setColor:[[currentSession textView] selectedTextColor]];
    [CONFIG_BOLD setColor:[[currentSession textView] defaultBoldColor]];
	[CONFIG_CURSOR setColor:[[currentSession textView] defaultCursorColor]];
	[CONFIG_CURSORTEXT setColor:[[currentSession textView] cursorTextColor]];
	
    [self setConfigFont:[_pseudoTerminal font]];
    [CONFIG_EXAMPLE setStringValue:[NSString stringWithFormat:@"%@ %g", [[self configFont] fontName], [[self configFont] pointSize]]];
    [CONFIG_EXAMPLE setTextColor:[[currentSession textView] defaultFGColor]];
    [CONFIG_EXAMPLE setBackgroundColor:[[currentSession textView] defaultBGColor]];
    [CONFIG_EXAMPLE setFont:[self configFont]];
    [self setConfigNAFont:[_pseudoTerminal nafont]];
    [CONFIG_NAEXAMPLE setStringValue:[NSString stringWithFormat:@"%@ %g", [[self configNAFont] fontName], [[self configNAFont] pointSize]]];
    [CONFIG_NAEXAMPLE setTextColor:[[currentSession textView] defaultFGColor]];
    [CONFIG_NAEXAMPLE setBackgroundColor:[[currentSession textView] defaultBGColor]];
    [CONFIG_NAEXAMPLE setFont:[self configNAFont]];
	[charHorizontalSpacing setFloatValue: [_pseudoTerminal charSpacingHorizontal]];
	[charVerticalSpacing setFloatValue: [_pseudoTerminal charSpacingVertical]];
    [CONFIG_NAME setStringValue:[_pseudoTerminal currentSessionName]];
	
    [CONFIG_ENCODING removeAllItems];
	anEnumerator = [[[iTermController sharedInstance] sortedEncodingList] objectEnumerator];
	while((anEncoding = [anEnumerator nextObject]) != NULL)
	{
        [CONFIG_ENCODING addItemWithTitle: [NSString localizedNameOfStringEncoding: [anEncoding unsignedIntValue]]];
		[[CONFIG_ENCODING lastItem] setTag: [anEncoding unsignedIntValue]];
	}
	[CONFIG_ENCODING selectItemAtIndex: [CONFIG_ENCODING indexOfItemWithTag: [[currentSession TERMINAL] encoding]]];
	
	[self setTransparencyValue:[NSNumber numberWithInt:([currentSession transparency]*100)]];
	
    [transparencyButton setState: [_pseudoTerminal useTransparency]];
    [CONFIG_TRANS2 setEnabled:[transparencyButton state]];
    [CONFIG_TRANSPARENCY setEnabled:[transparencyButton state]];
    
    [AI_ON setState:[currentSession antiIdle]?NSOnState:NSOffState];
    [AI_CODE setIntValue:[currentSession antiCode]];
    
    [CONFIG_ANTIALIAS setState: [[currentSession textView] antiAlias]];
	
	[boldButton setState: ![currentSession disableBold]];
    [CONFIG_BOLD setEnabled:[boldButton state]];
	
    [updateProfileButton setTitle:[NSString stringWithFormat:
        NTLocalizedStringFromTableInBundle(@"Update %@", @"iTerm", [NSBundle bundleForClass: [self class]], SettingsToolbarItem), 
        [[currentSession addressBookEntry] objectForKey: @"Name"]]];

	[[self window] setLevel: NSFloatingWindowLevel];
	[[self window] setDelegate: self];
    
}

- (void)sheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
    [[self window] close];
}

@end

@implementation ITConfigPanelController (Bindings)

//---------------------------------------------------------- 
//  transparencyValue 
//---------------------------------------------------------- 
- (NSNumber *)transparencyValue
{
    return mTransparencyValue; 
}

- (void)setTransparencyValue:(NSNumber *)theTransparencyValue
{
    if (mTransparencyValue != theTransparencyValue)
    {
        [mTransparencyValue release];
        mTransparencyValue = [theTransparencyValue retain];
		
		if (mTransparencyValue)
		{
			PTYSession* currentSession = [_pseudoTerminal currentSession];
			
			[currentSession setTransparency:[mTransparencyValue floatValue]/100.0];
		}
    }
}

@end

@implementation ITConfigPanelController (Private)

//---------------------------------------------------------- 
//  configFont 
//---------------------------------------------------------- 
- (NSFont *)configFont
{
    return mConfigFont; 
}

- (void)setConfigFont:(NSFont *)theConfigFont
{
    if (mConfigFont != theConfigFont)
    {
        [mConfigFont release];
        mConfigFont = [theConfigFont retain];
    }
}

//---------------------------------------------------------- 
//  configNAFont 
//---------------------------------------------------------- 
- (NSFont *)configNAFont
{
    return mConfigNAFont; 
}

- (void)setConfigNAFont:(NSFont *)theConfigNAFont
{
    if (mConfigNAFont != theConfigNAFont)
    {
        [mConfigNAFont release];
        mConfigNAFont = [theConfigNAFont retain];
    }
}

@end


