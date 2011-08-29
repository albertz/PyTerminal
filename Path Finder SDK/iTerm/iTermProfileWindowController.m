/*
 **  iTermProfileWindowController.h
 **
 **  Copyright (c) 2002, 2003, 2004
 **
 **  Author: Ujwal S. Setlur
 **
 **  Project: iTerm
 **
 **  Description: window controller for profile editors.
 **
 */

#import "iTermController.h"
#import "iTermKeyBindingMgr.h"
#import "iTermDisplayProfileMgr.h"
#import "iTermTerminalProfileMgr.h"
#import "iTermProfileWindowController.h"

@interface iTermProfileWindowController (Private)
- (void)_addProfileSheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo;
- (void)_deleteProfileSheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo;
- (void)_addKBEntrySheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo;
- (void)_updateFontsDisplay;
@end

@implementation iTermProfileWindowController

static NSArray *profileCategories;
static BOOL addingKBEntry;

+ (iTermProfileWindowController*)sharedInstance
{
    static iTermProfileWindowController* shared = nil;

    if (!shared)
	{
		shared = [[self alloc] initWithWindowNibName: @"ProfilesWindow"];
		[[shared window] setDelegate:shared]; // also forces window to load
	}
	
    profileCategories = [[NSArray arrayWithObjects:[NSNumber numberWithInt: 0],[NSNumber numberWithInt: 1],[NSNumber numberWithInt: 2],nil] retain];
    return shared;
}

- (IBAction)closeWindow:(id)sender
{
	[[self window] close];
}


- (void)windowDidLoad;
{
	[super windowDidLoad];
	
	[NTLocalizedString localizeWindow:[self window] table:@"terminal"];
}

- (void)windowWillClose:(NSNotification *)aNotification
{
    id prefs = [NSUserDefaults standardUserDefaults];
    
    [prefs setObject: [[iTermKeyBindingMgr singleInstance] profiles] forKey: @"iTermKeyBindings"];
	[prefs setObject: [[iTermDisplayProfileMgr singleInstance] profiles] forKey: @"iTermDisplays"];
	[prefs setObject: [[iTermTerminalProfileMgr singleInstance] profiles] forKey: @"iTermTerminals"];
	[prefs synchronize];

	[[NSColorPanel sharedColorPanel] close];
	[[NSFontPanel sharedFontPanel] close];	
}

// Profile editing
- (IBAction)profileAdd:(id)sender
{
    // Check if duplicate button is hit, and there is a profile chosen
	if ([sender tag] == 1 && selectedProfile == nil) {
        return;
    }
        
	[NSApp beginSheet: addProfile
	   modalForWindow: [self window]
		modalDelegate: self
	   didEndSelector: @selector(_addProfileSheetDidEnd:returnCode:contextInfo:)
		  contextInfo: nil];        
    
    // duplicate button?
    if ([sender tag]) {
        [profileName setStringValue: [NSString stringWithFormat:NTLocalizedStringFromTableInBundle(@"%@ copy",@"iTerm", [NSBundle bundleForClass: [self class]], @"Profiles"),
            selectedProfile]];
        [addProfileCategory selectItemAtIndex: [profileTabView indexOfTabViewItem:[profileTabView selectedTabViewItem]]];
        [addProfileCategory setEnabled: NO];
    }
    else {
        [profileName setStringValue: NTLocalizedStringFromTableInBundle(@"Untitled",@"iTerm", [NSBundle bundleForClass: [self class]], @"Profiles")];
        [addProfileCategory setEnabled: YES];
    }
}

- (IBAction)profileDelete:(id)sender
{
    NSBeginAlertSheet(NTLocalizedStringFromTableInBundle(@"Delete Profile",@"iTerm", [NSBundle bundleForClass: [self class]], @"Profiles"),
                      NTLocalizedStringFromTableInBundle(@"Delete",@"iTerm", [NSBundle bundleForClass: [self class]], @"Profiles"),
                      NTLocalizedStringFromTableInBundle(@"Cancel",@"iTerm", [NSBundle bundleForClass: [self class]], @"Profiles"),
                      nil, [self window], self, 
                      @selector(_deleteProfileSheetDidEnd:returnCode:contextInfo:), 
                      NULL, NULL, 
                      [NSString stringWithFormat:NTLocalizedStringFromTableInBundle(@"Are you sure that you want to delete %@? There is no way to undo this action.",@"iTerm", [NSBundle bundleForClass: [self class]], @"Profiles"),
                          selectedProfile]);
}

- (IBAction)profileAddConfirm:(id)sender
{
	id profileMgr;
	
    int categoryChosen = [addProfileCategory indexOfSelectedItem];

	if (categoryChosen == KEYBOARD_PROFILE_TAB)
		profileMgr = [iTermKeyBindingMgr singleInstance];
	else if (categoryChosen == TERMINAL_PROFILE_TAB)
		profileMgr = [iTermTerminalProfileMgr singleInstance];
	else if (categoryChosen == DISPLAY_PROFILE_TAB)
		profileMgr = [iTermDisplayProfileMgr singleInstance];
	else
		return;
    
    // make sure this profile does not already exist
    if ([[profileName stringValue] length]  <= 0 || [[profileMgr profiles] objectForKey: [profileName stringValue]] != nil)
    {
        NSBeep();
        // find a non-duplicated name
        NSString *aString = [NSString stringWithFormat:@"%@ new", [profileName stringValue]];
        int i = 1;
        for (; [[profileMgr profiles] objectForKey: aString] != nil; i++)
            aString = [NSString stringWithFormat:@"%@ new %d", [profileName stringValue], i];
        [profileName setStringValue: aString];
    }

    [NSApp endSheet:addProfile returnCode:NSOKButton];
}

- (IBAction)profileAddCancel:(id)sender
{
    [NSApp endSheet:addProfile returnCode:NSCancelButton];
}

- (IBAction)profileDuplicate:(id)sender
{
    int selectedTabViewItem;
	id profileMgr;
	
	selectedTabViewItem  = [profileTabView indexOfTabViewItem: [profileTabView selectedTabViewItem]];
	
	if (selectedTabViewItem == KEYBOARD_PROFILE_TAB)
		profileMgr = [iTermKeyBindingMgr singleInstance];
	else if (selectedTabViewItem == TERMINAL_PROFILE_TAB)
		profileMgr = [iTermTerminalProfileMgr singleInstance];
	else if (selectedTabViewItem == DISPLAY_PROFILE_TAB)
		profileMgr = [iTermDisplayProfileMgr singleInstance];
	else
		return;

    // find a non-duplicated name
    NSString *aString = [NSString stringWithFormat:@"%@ copy", selectedProfile];
    int i = 1;
    for (; [[profileMgr profiles] objectForKey: aString] != nil; i++)
        aString = [NSString stringWithFormat:@"%@ copy %d", selectedProfile, i];
    [profileMgr addProfileWithName: aString 
                       copyProfile: selectedProfile];
    
    [profileOutline reloadData];
    [self selectProfile:aString withInCategory: selectedTabViewItem];
}

// Keybinding profile UI
- (void)kbOptionKeyChanged:(id)sender
{
	[[iTermKeyBindingMgr singleInstance] setOptionKey: [kbOptionKey selectedColumn] 
										   forProfile:selectedProfile];
}

- (void)kbProfileChangedTo: (NSString *) selectedKBProfile
{	
	[deleteButton setEnabled: ![[iTermKeyBindingMgr singleInstance] isGlobalProfile: selectedKBProfile]];
    [duplicateButton setEnabled:YES];

    [kbOptionKey selectCellAtRow:0 column:[[iTermKeyBindingMgr singleInstance] optionKeyForProfile:selectedKBProfile]];
	
	[kbEntryTableView reloadData];
}

- (IBAction)kbEntryAdd:(id)sender
{
	int i;
	
	addingKBEntry = YES;

	[kbEntryKeyCode setStringValue: @""];
	[kbEntryText setStringValue: @""];
	[kbEntryKeyModifierOption setState: NSOffState];
	[kbEntryKeyModifierControl setState: NSOffState];
	[kbEntryKeyModifierShift setState: NSOffState];
	[kbEntryKeyModifierCommand setState: NSOffState];
	[kbEntryKeyModifierOption setEnabled: YES];
	[kbEntryKeyModifierControl setEnabled: YES];
	[kbEntryKeyModifierShift setEnabled: YES];
	[kbEntryKeyModifierCommand setEnabled: YES];
	if ([kbEntryKeyCode respondsToSelector: @selector(setHidden:)] == YES)
	{
		[kbEntryKeyCode setHidden: YES];
		[kbEntryText setHidden: YES];
	}
				
	[kbEntryKey selectItemAtIndex: 0];
	[kbEntryKey setTarget: self];
	[kbEntryKey setAction: @selector(kbEntrySelectorChanged:)];
	[kbEntryAction selectItemAtIndex: 0];
	[kbEntryAction setTarget: self];
	[kbEntryAction setAction: @selector(kbEntrySelectorChanged:)];	
	
	if ([[iTermKeyBindingMgr singleInstance] isGlobalProfile: selectedProfile])
	{
		for (i = KEY_ACTION_NEXT_SESSION; i < KEY_ACTION_ESCAPE_SEQUENCE; i++)
		{
			[[kbEntryAction itemAtIndex: i] setEnabled: YES];
			[[kbEntryAction itemAtIndex: i] setAction: @selector(kbEntrySelectorChanged:)];
			[[kbEntryAction itemAtIndex: i] setTarget: self];
		}
	}
	else
	{
		for (i = KEY_ACTION_NEXT_SESSION; i < KEY_ACTION_ESCAPE_SEQUENCE; i++)
		{
			[[kbEntryAction itemAtIndex: i] setEnabled: NO];
			[[kbEntryAction itemAtIndex: i] setAction: nil];
		}
		[kbEntryAction selectItemAtIndex: KEY_ACTION_ESCAPE_SEQUENCE];
		
	}
	[kbEntryHighPriority setState: NSOffState];
	
	[self kbEntrySelectorChanged: kbEntryAction];
	
	[NSApp beginSheet: addKBEntry
       modalForWindow: [self window]
        modalDelegate: self
       didEndSelector: @selector(_addKBEntrySheetDidEnd:returnCode:contextInfo:)
          contextInfo: nil];        
}

- (IBAction)kbEntryEdit:(id)sender
{
	int index;
	int selectedRow = [kbEntryTableView selectedRow];
	
	NSMutableDictionary *keyMappings;
	NSArray *allKeys;
	NSString *theKeyCombination;
	unsigned int keyCode, keyModifiers;
	int action;
	NSString *auxText;
	BOOL priority;
		
	keyMappings = [[[[iTermKeyBindingMgr singleInstance] profiles] objectForKey: selectedProfile] objectForKey: @"Key Mappings"];
	allKeys = [keyMappings allKeys];
	
	if (selectedRow >= 0 && selectedRow < [allKeys count])
	{
		theKeyCombination = [allKeys objectAtIndex: selectedRow];
		action = [[[keyMappings objectForKey: [allKeys objectAtIndex: selectedRow]] objectForKey: @"Action"] intValue];
		auxText = [[keyMappings objectForKey: [allKeys objectAtIndex: selectedRow]] objectForKey: @"Text"];
		priority = [[keyMappings objectForKey: [allKeys objectAtIndex: selectedRow]] objectForKey: @"Priority"] ? [[[keyMappings objectForKey: [allKeys objectAtIndex: selectedRow]] objectForKey: @"Priority"] boolValue] : NO;
		
	}
	else
		return;
	
	addingKBEntry = NO;
	sscanf([theKeyCombination UTF8String], "%x-%x", &keyCode, &keyModifiers);
	
	[kbEntryKey setTarget: self];
	[kbEntryKey setAction: @selector(kbEntrySelectorChanged:)];
	[kbEntryAction setTarget: self];
	[kbEntryAction setAction: @selector(kbEntrySelectorChanged:)];
	
	switch (keyCode)
	{
		case NSDownArrowFunctionKey:
			index = KEY_CURSOR_DOWN;
			break;
		case NSLeftArrowFunctionKey:
			index = KEY_CURSOR_LEFT;
			break;
		case NSRightArrowFunctionKey:
			index = KEY_CURSOR_RIGHT;
			break;
		case NSUpArrowFunctionKey:
			index = KEY_CURSOR_UP;
			break;
		case NSDeleteFunctionKey:
			index = KEY_DEL;
			break;
		case 0x7f:
			index = KEY_DELETE;
			break;
		case NSEndFunctionKey:
			index = KEY_END;
			break;
		case NSF1FunctionKey:
		case NSF2FunctionKey:
		case NSF3FunctionKey:
		case NSF4FunctionKey:
		case NSF5FunctionKey:
		case NSF6FunctionKey:
		case NSF7FunctionKey:
		case NSF8FunctionKey:
		case NSF9FunctionKey:
		case NSF10FunctionKey:
		case NSF11FunctionKey:
		case NSF12FunctionKey:
		case NSF13FunctionKey:
		case NSF14FunctionKey:
		case NSF15FunctionKey:
		case NSF16FunctionKey:
		case NSF17FunctionKey:
		case NSF18FunctionKey:
		case NSF19FunctionKey:
		case NSF20FunctionKey:
			index = KEY_F1 + keyCode - NSF1FunctionKey;
			break;
		case NSHelpFunctionKey:
			index = KEY_HELP;
			break;
		case NSHomeFunctionKey:
			index = KEY_HOME;
			break;
		case '0':
		case '1':
		case '2':
		case '3':
		case '4':
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			index = KEY_NUMERIC_0 + keyCode - '0';
			break;
		case '=':
			index = KEY_NUMERIC_EQUAL;
			break;
		case '/':
			index = KEY_NUMERIC_DIVIDE;
			break;
		case '*':
			index = KEY_NUMERIC_MULTIPLY;
			break;
		case '-':
			index = KEY_NUMERIC_MINUS;
			break;
		case '+':
			index = KEY_NUMERIC_PLUS;
			break;
		case '.':
			index = KEY_NUMERIC_PERIOD;
			break;
		case NSClearLineFunctionKey:
			index = KEY_NUMLOCK;
			break;
		case NSPageDownFunctionKey:
			index = KEY_PAGE_DOWN;
			break;
		case NSPageUpFunctionKey:
			index = KEY_PAGE_UP;
			break;
		case 0x3: // 'enter' on numeric key pad
			index = KEY_NUMERIC_ENTER;
			break;
		default:
			index = KEY_HEX_CODE;
			[kbEntryKeyCode setStringValue: [NSString stringWithFormat:@"0x%x", keyCode]];
			break;
	}
	
	[kbEntryKey selectItemAtIndex:index];
	[self kbEntrySelectorChanged: kbEntryKey];
	
	[kbEntryKeyModifierCommand setState: (keyModifiers & NSCommandKeyMask)];
	[kbEntryKeyModifierOption setState: (keyModifiers & NSAlternateKeyMask)];
	[kbEntryKeyModifierControl setState: (keyModifiers & NSControlKeyMask)];
	[kbEntryKeyModifierShift setState: (keyModifiers & NSShiftKeyMask)];
	
	[kbEntryKeyModifierOption setEnabled: YES];
	[kbEntryKeyModifierControl setEnabled: YES];
	[kbEntryKeyModifierShift setEnabled: YES];
	[kbEntryKeyModifierCommand setEnabled: YES];
	
	if (action == KEY_ACTION_HEX_CODE || action == KEY_ACTION_ESCAPE_SEQUENCE)
		[kbEntryText setStringValue: auxText];
	else
		[kbEntryText setStringValue: @""];
	
	[kbEntryAction selectItemAtIndex: action];
	[self kbEntrySelectorChanged: kbEntryAction];
	
	int i;
	
	if ([[iTermKeyBindingMgr singleInstance] isGlobalProfile: selectedProfile])
	{
		for (i = KEY_ACTION_NEXT_SESSION; i < KEY_ACTION_ESCAPE_SEQUENCE; i++)
		{
			[[kbEntryAction itemAtIndex: i] setEnabled: YES];
			[[kbEntryAction itemAtIndex: i] setAction: @selector(kbEntrySelectorChanged:)];
			[[kbEntryAction itemAtIndex: i] setTarget: self];
		}
	}
	else
	{
		for (i = KEY_ACTION_NEXT_SESSION; i < KEY_ACTION_ESCAPE_SEQUENCE; i++)
		{
			[[kbEntryAction itemAtIndex: i] setEnabled: NO];
			[[kbEntryAction itemAtIndex: i] setAction: nil];
		}
		[kbEntryAction selectItemAtIndex: KEY_ACTION_ESCAPE_SEQUENCE];
		
	}
	
	[kbEntryHighPriority setState: priority ? NSOnState : NSOffState];
	[self kbEntrySelectorChanged: kbEntryAction];
	
	[NSApp beginSheet: addKBEntry
       modalForWindow: [self window]
        modalDelegate: self
       didEndSelector: @selector(_addKBEntrySheetDidEnd:returnCode:contextInfo:)
          contextInfo: nil];        
}

- (IBAction)kbEntryAddConfirm:(id)sender
{
	[NSApp endSheet:addKBEntry returnCode:NSOKButton];
}

- (IBAction)kbEntryAddCancel:(id)sender
{
	[NSApp endSheet:addKBEntry returnCode:NSCancelButton];
}

- (IBAction)kbEntryDelete:(id)sender
{
	if ([kbEntryTableView selectedRow] >= 0)
	{
		[[iTermKeyBindingMgr singleInstance] deleteEntryAtIndex: [kbEntryTableView selectedRow] 
													  inProfile: selectedProfile];
		[kbEntryTableView reloadData];
	}
	else
		NSBeep();
}

- (IBAction)kbEntrySelectorChanged:(id)sender
{
	if (sender == kbEntryKey)
	{
		if ([kbEntryKey indexOfSelectedItem] == KEY_HEX_CODE && [kbEntryKeyCode respondsToSelector: @selector(setHidden:)] == YES)
			[kbEntryKeyCode setHidden: NO];
		else
		{			
			[kbEntryKeyCode setStringValue: @""];
			if ([kbEntryKeyCode respondsToSelector: @selector(setHidden:)] == YES)
				[kbEntryKeyCode setHidden: YES];
		}
	}
	else if (sender == kbEntryAction)
	{
		if ([kbEntryAction indexOfSelectedItem] == KEY_ACTION_HEX_CODE ||
		   [kbEntryAction indexOfSelectedItem] == KEY_ACTION_ESCAPE_SEQUENCE)
		{		
			[kbEntryText setHidden: NO];
			[kbEntryHint setHidden: NO];
			[kbEntryHint setStringValue: ([kbEntryAction indexOfSelectedItem] == KEY_ACTION_HEX_CODE) ?
				NTLocalizedStringFromTableInBundle(@"eg. 7F for forward delete.",@"iTerm", [NSBundle bundleForClass: [self class]], @"Profiles") :
				NTLocalizedStringFromTableInBundle(@"eg. [OC for ESC [OC.",@"iTerm", [NSBundle bundleForClass: [self class]], @"Profiles")];
		}
		else
		{
			[kbEntryText setStringValue: @""];
			[kbEntryText setHidden: YES];
			[kbEntryHint setHidden: YES];
		}
	}	
}

// NSTableView data source
- (int) numberOfRowsInTableView: (NSTableView *)aTableView
{
	if ([[[iTermKeyBindingMgr singleInstance] profiles] count] == 0 || selectedProfile == nil)
		return (0);
    
	return([[iTermKeyBindingMgr singleInstance] numberOfEntriesInProfile: selectedProfile]);
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex
{    
    if ([[aTableColumn identifier] intValue] ==  0)
	{
		return ([[iTermKeyBindingMgr singleInstance] keyCombinationAtIndex: rowIndex 
																 inProfile: selectedProfile]);
	}
	else
	{
		return ([[iTermKeyBindingMgr singleInstance] actionForKeyCombinationAtIndex: rowIndex 
																		  inProfile: selectedProfile]);
	}
}

// NSTableView delegate
- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
	if ([kbEntryTableView selectedRow] < 0)
		[kbEntryDeleteButton setEnabled: NO];
	else
		[kbEntryDeleteButton setEnabled: YES];
}

// Display profile UI
- (void)displayProfileChangedTo: (NSString *) theProfile
{
	// load the colors
	[displayFGColor setColor:[[iTermDisplayProfileMgr singleInstance] color: TYPE_FOREGROUND_COLOR 
																  forProfile:theProfile]];
	[displayBGColor setColor:[[iTermDisplayProfileMgr singleInstance] color: TYPE_BACKGROUND_COLOR 
																  forProfile:theProfile]];
	[displayBoldColor setColor:[[iTermDisplayProfileMgr singleInstance] color: TYPE_BOLD_COLOR 
																  forProfile:theProfile]];
	[displaySelectionColor setColor:[[iTermDisplayProfileMgr singleInstance] color: TYPE_SELECTION_COLOR 
																  forProfile:theProfile]];
	[displaySelectedTextColor setColor:[[iTermDisplayProfileMgr singleInstance] color: TYPE_SELECTED_TEXT_COLOR 
																  forProfile:theProfile]];
	[displayCursorColor setColor:[[iTermDisplayProfileMgr singleInstance] color: TYPE_CURSOR_COLOR 
																  forProfile:theProfile]];
	[displayCursorTextColor setColor:[[iTermDisplayProfileMgr singleInstance] color: TYPE_CURSOR_TEXT_COLOR 
																  forProfile:theProfile]];
	[displayAnsi0Color setColor:[[iTermDisplayProfileMgr singleInstance] color: TYPE_ANSI_0_COLOR 
																  forProfile:theProfile]];
	[displayAnsi1Color setColor:[[iTermDisplayProfileMgr singleInstance] color: TYPE_ANSI_1_COLOR 
																  forProfile:theProfile]];
	[displayAnsi2Color setColor:[[iTermDisplayProfileMgr singleInstance] color: TYPE_ANSI_2_COLOR 
																  forProfile:theProfile]];
	[displayAnsi3Color setColor:[[iTermDisplayProfileMgr singleInstance] color: TYPE_ANSI_3_COLOR 
																  forProfile:theProfile]];
	[displayAnsi4Color setColor:[[iTermDisplayProfileMgr singleInstance] color: TYPE_ANSI_4_COLOR 
																  forProfile:theProfile]];
	[displayAnsi5Color setColor:[[iTermDisplayProfileMgr singleInstance] color: TYPE_ANSI_5_COLOR 
																  forProfile:theProfile]];
	[displayAnsi6Color setColor:[[iTermDisplayProfileMgr singleInstance] color: TYPE_ANSI_6_COLOR 
																  forProfile:theProfile]];
	[displayAnsi7Color setColor:[[iTermDisplayProfileMgr singleInstance] color: TYPE_ANSI_7_COLOR 
																  forProfile:theProfile]];
	[displayAnsi8Color setColor:[[iTermDisplayProfileMgr singleInstance] color: TYPE_ANSI_8_COLOR 
																  forProfile:theProfile]];
	[displayAnsi9Color setColor:[[iTermDisplayProfileMgr singleInstance] color: TYPE_ANSI_9_COLOR 
																  forProfile:theProfile]];
	[displayAnsi10Color setColor:[[iTermDisplayProfileMgr singleInstance] color: TYPE_ANSI_10_COLOR 
																  forProfile:theProfile]];
	[displayAnsi11Color setColor:[[iTermDisplayProfileMgr singleInstance] color: TYPE_ANSI_11_COLOR 
																  forProfile:theProfile]];
	[displayAnsi12Color setColor:[[iTermDisplayProfileMgr singleInstance] color: TYPE_ANSI_12_COLOR 
																  forProfile:theProfile]];
	[displayAnsi13Color setColor:[[iTermDisplayProfileMgr singleInstance] color: TYPE_ANSI_13_COLOR 
																  forProfile:theProfile]];
	[displayAnsi14Color setColor:[[iTermDisplayProfileMgr singleInstance] color: TYPE_ANSI_14_COLOR 
																  forProfile:theProfile]];
	[displayAnsi15Color setColor:[[iTermDisplayProfileMgr singleInstance] color: TYPE_ANSI_15_COLOR 
																  forProfile:theProfile]];
	// transparency
	[displayTransparency setStringValue: [NSString stringWithFormat: @"%d", 
		(int)(100*[[iTermDisplayProfileMgr singleInstance] transparencyForProfile:theProfile])]];
	
	// disable bold
	[displayDisableBold setState: [[iTermDisplayProfileMgr singleInstance] disableBoldForProfile:theProfile]];
	
	// fonts
	[self _updateFontsDisplay];
	
	// anti-alias
	[displayAntiAlias setState: [[iTermDisplayProfileMgr singleInstance] windowAntiAliasForProfile:theProfile]];
	
	// window size
	[displayColTextField setStringValue: [NSString stringWithFormat: @"%d",
		[[iTermDisplayProfileMgr singleInstance] windowColumnsForProfile:theProfile]]];
	[displayRowTextField setStringValue: [NSString stringWithFormat: @"%d",
		[[iTermDisplayProfileMgr singleInstance] windowRowsForProfile:theProfile]]];
	
	[deleteButton setEnabled: ![[iTermDisplayProfileMgr singleInstance] isDefaultProfile: theProfile]];
    [duplicateButton setEnabled:YES];
}

- (IBAction)displaySetDisableBold:(id)sender
{
	if (sender == displayDisableBold)
	{
		[[iTermDisplayProfileMgr singleInstance] setDisableBold: [displayDisableBold state] 
														 forProfile:selectedProfile];
	}
}

- (IBAction)displaySetAntiAlias:(id)sender
{
	if (sender == displayAntiAlias)
	{
		[[iTermDisplayProfileMgr singleInstance] setWindowAntiAlias: [displayAntiAlias state] 
												   forProfile:selectedProfile];
	}
}

- (IBAction)displayChangeColor:(id)sender
{
	int type;
	
	type = [sender tag];
	
	[[iTermDisplayProfileMgr singleInstance] setColor:[sender color]
											  forType: type
										   forProfile:selectedProfile];
	
	// update fonts display
	[self _updateFontsDisplay];
}

// sent by NSFontManager
- (void)changeFont:(id)fontManager
{
	NSFont *aFont;
	
	if (changingNAFont)
	{
		aFont = [fontManager convertFont: [displayNAFontTextField font]];
		[[iTermDisplayProfileMgr singleInstance] setWindowNAFont: aFont forProfile:selectedProfile];
	}
	else
	{
		aFont = [fontManager convertFont: [displayFontTextField font]];
		[[iTermDisplayProfileMgr singleInstance] setWindowFont: aFont forProfile:selectedProfile];
	}
	
	[self _updateFontsDisplay];
}

- (IBAction)displaySelectFont:(id)sender
{
	NSFont *aFont;
	NSFontPanel *aFontPanel;
	
	changingNAFont = NO;
	
	aFont = [[iTermDisplayProfileMgr singleInstance] windowFontForProfile:selectedProfile];
	
	// make sure we get the messages from the NSFontManager
    [[self window] makeFirstResponder:self];
	aFontPanel = [[NSFontManager sharedFontManager] fontPanel: YES];
	[aFontPanel setAccessoryView: displayFontAccessoryView];
    [[NSFontManager sharedFontManager] setSelectedFont:aFont isMultiple:NO];
    [[NSFontManager sharedFontManager] orderFrontFontPanel:self];
}

- (IBAction)displaySelectNAFont:(id)sender
{
	NSFont *aFont;
	NSFontPanel *aFontPanel;
	
	changingNAFont = YES;
	
	aFont = [[iTermDisplayProfileMgr singleInstance] windowNAFontForProfile:selectedProfile];
	
	// make sure we get the messages from the NSFontManager
    [[self window] makeFirstResponder:self];
	aFontPanel = [[NSFontManager sharedFontManager] fontPanel: YES];
	[aFontPanel setAccessoryView: displayFontAccessoryView];
    [[NSFontManager sharedFontManager] setSelectedFont:aFont isMultiple:NO];
    [[NSFontManager sharedFontManager] orderFrontFontPanel:self];
}

- (IBAction)displaySetFontSpacing:(id)sender
{
	
	if (sender == displayFontSpacingWidth)
		[[iTermDisplayProfileMgr singleInstance] setWindowHorizontalCharSpacing: [sender floatValue] 
																	 forProfile:selectedProfile];
	else if (sender == displayFontSpacingHeight)
		[[iTermDisplayProfileMgr singleInstance] setWindowVerticalCharSpacing: [sender floatValue]
                                                                   forProfile:selectedProfile];
}

// NSTextField delegate
- (void)controlTextDidChange:(NSNotification *)aNotification
{
	int iVal;
	float fVal;
	id sender;

	sender = [aNotification object];

	iVal = [sender intValue];
	fVal = [sender floatValue];
	if (sender == displayColTextField)
		[[iTermDisplayProfileMgr singleInstance] setWindowColumns: iVal forProfile:selectedProfile];
	else if (sender == displayRowTextField)
		[[iTermDisplayProfileMgr singleInstance] setWindowRows: iVal forProfile:selectedProfile];
	else if (sender == displayTransparency)
		[[iTermDisplayProfileMgr singleInstance] setTransparency: fVal/100 forProfile:selectedProfile];
	else if (sender == terminalScrollback)
		[[iTermTerminalProfileMgr singleInstance] setScrollbackLines: iVal forProfile:selectedProfile];
	else if (sender == terminalIdleChar)
		[[iTermTerminalProfileMgr singleInstance] setIdleChar: iVal forProfile:selectedProfile];
}

// Terminal profile UI
- (void)terminalProfileChangedTo: (NSString *)theProfile
{    
	[terminalType setStringValue: [[iTermTerminalProfileMgr singleInstance] typeForProfile:theProfile]];
	[terminalEncoding setTitle: [NSString localizedNameOfStringEncoding:
		[[iTermTerminalProfileMgr singleInstance] encodingForProfile:theProfile]]];
	[terminalScrollback setStringValue: [NSString stringWithFormat: @"%d",
		[[iTermTerminalProfileMgr singleInstance] scrollbackLinesForProfile:theProfile]]];
	[terminalSilenceBell setState: [[iTermTerminalProfileMgr singleInstance] silenceBellForProfile:theProfile]];
	[terminalShowBell setState: [[iTermTerminalProfileMgr singleInstance] showBellForProfile:theProfile]];
	[terminalBlink setState: [[iTermTerminalProfileMgr singleInstance] blinkCursorForProfile:theProfile]];
	[terminalCloseOnSessionEnd setState: [[iTermTerminalProfileMgr singleInstance] closeOnSessionEndForProfile:theProfile]];
	[terminalDoubleWidth setState: [[iTermTerminalProfileMgr singleInstance] doubleWidthForProfile:theProfile]];
	[terminalSendIdleChar setState: [[iTermTerminalProfileMgr singleInstance] sendIdleCharForProfile:theProfile]];
	[terminalIdleChar setStringValue: [NSString stringWithFormat: @"%d",  
		[[iTermTerminalProfileMgr singleInstance] idleCharForProfile:theProfile]]];
	[xtermMouseReporting setState: [[iTermTerminalProfileMgr singleInstance] xtermMouseReportingForProfile:theProfile]];
	[terminalAppendTitle setState: [[iTermTerminalProfileMgr singleInstance] appendTitleForProfile:theProfile]];
	
	[deleteButton setEnabled: ![[iTermTerminalProfileMgr singleInstance] isDefaultProfile: theProfile]];
    [duplicateButton setEnabled: YES];
}

- (IBAction)terminalSetType:(id)sender
{
	[[iTermTerminalProfileMgr singleInstance] setType: [sender stringValue] 
										   forProfile:selectedProfile];
}

- (IBAction)terminalSetEncoding:(id)sender
{
	[[iTermTerminalProfileMgr singleInstance] setEncoding: [[terminalEncoding selectedItem] tag] 
											   forProfile:selectedProfile];
}

- (IBAction)terminalSetSilenceBell:(NSButton*)sender
{
	[[iTermTerminalProfileMgr singleInstance] setSilenceBell: [sender state] 
												  forProfile:selectedProfile];
}	

- (IBAction)terminalSetShowBell:(NSButton*)sender
{
	[[iTermTerminalProfileMgr singleInstance] setShowBell: [sender state] 
												  forProfile:selectedProfile];
}

- (IBAction)terminalSetBlink:(NSButton*)sender
{
	[[iTermTerminalProfileMgr singleInstance] setBlinkCursor: [sender state] 
												  forProfile:selectedProfile];
}	

- (IBAction)terminalSetCloseOnSessionEnd:(NSButton*)sender
{
	[[iTermTerminalProfileMgr singleInstance] setCloseOnSessionEnd: [sender state] 
														forProfile:selectedProfile];
}	

- (IBAction)terminalSetDoubleWidth:(NSButton*)sender
{
	[[iTermTerminalProfileMgr singleInstance] setDoubleWidth: [sender state] 
												  forProfile:selectedProfile];
}	

- (IBAction)terminalSetSendIdleChar:(NSButton*)sender
{
	[[iTermTerminalProfileMgr singleInstance] setSendIdleChar: [sender state] 
												   forProfile:selectedProfile];
}

- (IBAction)terminalSetXtermMouseReporting:(NSButton*)sender
{
	[[iTermTerminalProfileMgr singleInstance] setXtermMouseReporting: [sender state] 
												  forProfile:selectedProfile];
}	

- (IBAction)terminalSetAppendTitle:(NSButton*)sender
{
	[[iTermTerminalProfileMgr singleInstance] setAppendTitle: [sender state] 
												  forProfile:selectedProfile];
}	

//outline view
// NSOutlineView delegate methods
- (void)outlineViewSelectionDidChange: (NSNotification *) aNotification
{
	int selectedRow;
	id selectedItem;
	
    selectedRow = [profileOutline selectedRow];
	selectedItem = [profileOutline itemAtRow: selectedRow];
    if (selectedProfile) {
        selectedProfile = nil;
    }
	
    if (!selectedItem || [selectedItem isKindOfClass:[NSNumber class]]) {
        // Choose the instruction tab
        [profileTabView selectTabViewItemAtIndex:3];
    }
	else {
        selectedProfile = selectedItem;
        if (selectedRow > [profileOutline rowForItem:[profileCategories objectAtIndex:DISPLAY_PROFILE_TAB]]) {
            [self displayProfileChangedTo: selectedItem];
            [profileTabView selectTabViewItemAtIndex:DISPLAY_PROFILE_TAB];
        }
        else if (selectedRow > [profileOutline rowForItem:[profileCategories objectAtIndex:TERMINAL_PROFILE_TAB]]) {
            [self terminalProfileChangedTo: selectedItem];
            [profileTabView selectTabViewItemAtIndex:TERMINAL_PROFILE_TAB];
        }
        else {
            [self kbProfileChangedTo: selectedItem];
            [profileTabView selectTabViewItemAtIndex:KEYBOARD_PROFILE_TAB];
        }
    }
}

// NSOutlineView data source methods
// required
- (id)outlineView:(NSOutlineView *)ov child:(int)index ofItem:(id)item
{    
    if (item) {
        id value;
        NSEnumerator *enumerator;

        switch ([item intValue]) {
            case KEYBOARD_PROFILE_TAB:
                enumerator = [[[iTermKeyBindingMgr singleInstance] profiles] keyEnumerator];
                break;
            case TERMINAL_PROFILE_TAB:
                enumerator = [[[iTermTerminalProfileMgr singleInstance] profiles] keyEnumerator];
                break;
            default:
                enumerator = [[[iTermDisplayProfileMgr singleInstance] profiles] keyEnumerator];
        }
            
        while ((value = [enumerator nextObject]) && index>0) 
            index--;
        
        return value;
    }
    else
        return [profileCategories objectAtIndex:index];
}

- (BOOL)outlineView:(NSOutlineView *)ov isItemExpandable:(id)item
{
    return [item isKindOfClass:[NSNumber class]];
}

- (int)outlineView:(NSOutlineView *)ov numberOfChildrenOfItem:(id)item
{
    if (item) 
	{
        switch ([item intValue]) 
		{
            case KEYBOARD_PROFILE_TAB:
                return [[[iTermKeyBindingMgr singleInstance] profiles] count];
            case TERMINAL_PROFILE_TAB:
                return [[[iTermTerminalProfileMgr singleInstance] profiles] count];
        }
        return [[[iTermDisplayProfileMgr singleInstance] profiles] count];
    }
    else
        return 3;
}

- (id)outlineView:(NSOutlineView *)ov objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{	
    if ([item isKindOfClass:[NSNumber class]])
	{
        switch ([item intValue])
		{
            case KEYBOARD_PROFILE_TAB:
                return NTLocalizedStringFromTableInBundle(@"Keyboard Profiles",@"iTerm", [NSBundle bundleForClass: [self class]], @"Profiles");
            case TERMINAL_PROFILE_TAB:
                return NTLocalizedStringFromTableInBundle(@"Terminal Profiles",@"iTerm", [NSBundle bundleForClass: [self class]], @"Profiles");
			default:
				return NTLocalizedStringFromTableInBundle(@"Display Profiles",@"iTerm", [NSBundle bundleForClass: [self class]], @"Profiles");
		}
    }
    else
		return item;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldEditTableColumn:(NSTableColumn *)tableColumn item:(id)item
{
    if ([item isKindOfClass:[NSNumber class]])
        return NO;
 
    int categoryChosen = [profileTabView indexOfTabViewItem: [profileTabView selectedTabViewItem]];
    
	if (categoryChosen == KEYBOARD_PROFILE_TAB)
		return ![[iTermKeyBindingMgr singleInstance] isGlobalProfile:item];
	else if (categoryChosen == TERMINAL_PROFILE_TAB)
		return ![[iTermTerminalProfileMgr singleInstance] isDefaultProfile:item];
	else if (categoryChosen == DISPLAY_PROFILE_TAB)
		return ![[iTermDisplayProfileMgr singleInstance] isDefaultProfile:item];
	else
		return NO;
}

// Optional method: needed to allow editing.
- (void)outlineView:(NSOutlineView *)olv setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn byItem:(id)item  
{
    int categoryChosen = [profileTabView indexOfTabViewItem: [profileTabView selectedTabViewItem]];
    id profileMgr;
    
	if (categoryChosen == KEYBOARD_PROFILE_TAB)
		profileMgr = [iTermKeyBindingMgr singleInstance];
	else if (categoryChosen == TERMINAL_PROFILE_TAB)
		profileMgr = [iTermTerminalProfileMgr singleInstance];
	else if (categoryChosen == DISPLAY_PROFILE_TAB)
		profileMgr = [iTermDisplayProfileMgr singleInstance];
	else
		return;
    
    if ([[profileMgr profiles] objectForKey: object] != nil)
        [profileOutline reloadData];
    else 
	{
        id temp = [[[profileMgr profiles] objectForKey: item] retain];
        [profileMgr deleteProfileWithName: item];
        [(NSMutableDictionary *)[profileMgr profiles] setObject: temp forKey: object];
        [temp release];
        [profileOutline reloadData];
        [self selectProfile:object withInCategory: categoryChosen];
    }
}

- (void)selectProfile:(NSString *)profile withInCategory: (int) category
{
    int i;
    
    i = [profileOutline rowForItem: [profileCategories objectAtIndex: category]]+1;
    for (;i<[profileOutline numberOfRows] && ![[profileOutline itemAtRow:i] isKindOfClass:[NSNumber class]];i++)
        if ([[profileOutline itemAtRow:i] isEqualToString: profile])
		{
            [profileOutline selectRowIndexes:[NSIndexSet indexSetWithIndex:i] byExtendingSelection:NO];
            [self outlineViewSelectionDidChange: nil];
            break;
        }
}

- (IBAction)showProfilesWindow:(id)sender
{    
 	[self tableViewSelectionDidChange: nil];	
	
	// add list of encodings
	NSEnumerator *anEnumerator;
	NSNumber *anEncoding;
	
	[terminalEncoding removeAllItems];
	anEnumerator = [[[iTermController sharedInstance] sortedEncodingList] objectEnumerator];
	while((anEncoding = [anEnumerator nextObject]) != NULL)
	{
		[terminalEncoding addItemWithTitle: [NSString localizedNameOfStringEncoding: [anEncoding unsignedIntValue]]];
		[[terminalEncoding lastItem] setTag: [anEncoding unsignedIntValue]];
	}
 	
	[profileOutline deselectAll:nil];
	[deleteButton setEnabled:NO];
    [duplicateButton setEnabled:NO];
	
	[self showWindow: self];
}

@end

@implementation iTermProfileWindowController (Private)

- (void)_addKBEntrySheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{	
	if (returnCode == NSOKButton)
	{
		unsigned int modifiers = 0;
		unsigned int hexCode = 0;
		int selectedRow = [kbEntryTableView selectedRow];

		// if we are editing, we remove the old entry first
		if (!addingKBEntry && selectedRow>=0)
			[[iTermKeyBindingMgr singleInstance] deleteEntryAtIndex: [kbEntryTableView selectedRow] 
														  inProfile: selectedProfile];

		if ([kbEntryKeyModifierOption state] == NSOnState)
			modifiers |= NSAlternateKeyMask;
		if ([kbEntryKeyModifierControl state] == NSOnState)
			modifiers |= NSControlKeyMask;
		if ([kbEntryKeyModifierShift state] == NSOnState)
			modifiers |= NSShiftKeyMask;
		if ([kbEntryKeyModifierCommand state] == NSOnState)
			modifiers |= NSCommandKeyMask;
		
		if ([kbEntryKey indexOfSelectedItem] == KEY_HEX_CODE)
		{
			if (sscanf([[kbEntryKeyCode stringValue] UTF8String], "%x", &hexCode) == 1)
			{
				[[iTermKeyBindingMgr singleInstance] addEntryForKeyCode: hexCode 
															  modifiers: modifiers 
																 action: [kbEntryAction indexOfSelectedItem] 
														   highPriority: [kbEntryHighPriority state] == NSOnState
																   text: [kbEntryText stringValue]
																profile: selectedProfile];
			}
		}
		else
		{
			[[iTermKeyBindingMgr singleInstance] addEntryForKey: [kbEntryKey indexOfSelectedItem] 
													  modifiers: modifiers 
														 action: [kbEntryAction indexOfSelectedItem] 
												   highPriority: [kbEntryHighPriority state] == NSOnState
														   text: [kbEntryText stringValue]
														profile: selectedProfile];			
		}
		[self kbProfileChangedTo: selectedProfile];
	}
	
	[addKBEntry close];
	[kbEntryTableView reloadData];
}

- (void)_addProfileSheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
	id profileMgr;
	
    int categoryChosen = [addProfileCategory indexOfSelectedItem];
    
    if (categoryChosen == KEYBOARD_PROFILE_TAB)
		profileMgr = [iTermKeyBindingMgr singleInstance];
	else if (categoryChosen == TERMINAL_PROFILE_TAB)
		profileMgr = [iTermTerminalProfileMgr singleInstance];
	else if (categoryChosen == DISPLAY_PROFILE_TAB)
		profileMgr = [iTermDisplayProfileMgr singleInstance];
	else
		return;
	
	if (returnCode == NSOKButton)
	{
        [profileMgr addProfileWithName: [profileName stringValue] 
                           copyProfile: [profileMgr defaultProfileName]];
		[profileOutline reloadData];
        [self selectProfile:[profileName stringValue]  withInCategory: categoryChosen];
        [deleteButton setEnabled:YES];
        [duplicateButton setEnabled:NO];
	}
	
	[addProfile close];
}

- (void)_deleteProfileSheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
	int selectedTabViewItem;
	id profileMgr;
	
	selectedTabViewItem  = [profileTabView indexOfTabViewItem: [profileTabView selectedTabViewItem]];
	
	if (selectedTabViewItem == KEYBOARD_PROFILE_TAB)
		profileMgr = [iTermKeyBindingMgr singleInstance];
	else if (selectedTabViewItem == TERMINAL_PROFILE_TAB)
		profileMgr = [iTermTerminalProfileMgr singleInstance];
	else if (selectedTabViewItem == DISPLAY_PROFILE_TAB)
		profileMgr = [iTermDisplayProfileMgr singleInstance];
	else
		return;
	
	if (returnCode == NSAlertDefaultReturn)
	{
		
		[profileMgr deleteProfileWithName: selectedProfile];
		
	    [profileOutline reloadData];
        [profileOutline deselectAll: nil];
        [deleteButton setEnabled:NO];
        [duplicateButton setEnabled:NO];
    }
	
	[sheet close];
}

- (void)_updateFontsDisplay
{
	float horizontalSpacing, verticalSpacing;
	
	// load the fonts
	NSString *fontName;
	NSFont *font;
	
	font = [[iTermDisplayProfileMgr singleInstance] windowFontForProfile:selectedProfile];
	if (font != nil)
	{
		fontName = [NSString stringWithFormat: @"%@ %g", [font fontName], [font pointSize]];
		[displayFontTextField setStringValue: fontName];
		[displayFontTextField setFont: font];
		[displayFontTextField setTextColor: [displayFGColor color]];
		[displayFontTextField setBackgroundColor: [displayBGColor color]];
	}
	else
	{
		fontName = @"Unknown Font";
		[displayFontTextField setStringValue: fontName];
	}
	font = [[iTermDisplayProfileMgr singleInstance] windowNAFontForProfile:selectedProfile];
	if (font != nil)
	{
		fontName = [NSString stringWithFormat: @"%@ %g", [font fontName], [font pointSize]];
		[displayNAFontTextField setStringValue: fontName];
		[displayNAFontTextField setFont: font];
		[displayNAFontTextField setTextColor: [displayFGColor color]];
		[displayNAFontTextField setBackgroundColor: [displayBGColor color]];
	}
	else
	{
		fontName = @"Unknown NA Font";
		[displayNAFontTextField setStringValue: fontName];
	}
	
	horizontalSpacing = [[iTermDisplayProfileMgr singleInstance] windowHorizontalCharSpacingForProfile:selectedProfile];
	verticalSpacing = [[iTermDisplayProfileMgr singleInstance] windowVerticalCharSpacingForProfile:selectedProfile];

	[displayFontSpacingWidth setFloatValue: horizontalSpacing];
	[displayFontSpacingHeight setFloatValue: verticalSpacing];
}

@end

