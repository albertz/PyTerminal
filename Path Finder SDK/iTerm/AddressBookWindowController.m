/*
 **  AddressBookWindowController.m
 **
 **  Copyright (c) 2002, 2003
 **
 **  Author: Ujwal S. Setlur, Fabian
 **
 **  Project: iTerm
 **
 **  Description: Implements the addressbook functions.
 **
 **  This program is free software; you can redistribute it and/or modify
 **  it under the terms of the GNU General Public License as published by
 **  the Free Software Foundation; either version 2 of the License, or
 **  (at your option) any later version.
 **
 **  This program is distributed in the hope that it will be useful,
 **  but WITHOUT ANY WARRANTY; without even the implied warranty of
 **  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 **  GNU General Public License for more details.
 **
 **  You should have received a copy of the GNU General Public License
 **  along with this program; if not, write to the Free Software
 **  Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 */

#import <iTerm/AddressBookWindowController.h>
#import <iTerm/PreferencePanel.h>
#import <iTerm/iTermController.h>
#import <iTerm/ITAddressBookMgr.h>

#define DEBUG_ALLOC		0
#define DEBUG_METHOD_TRACE	0

static NSStringEncoding const *encodingList=nil;
static AddressBookWindowController *singleInstance = nil;

static NSColor *iTermBackground;
static NSColor *iTermForeground;
static NSColor *iTermSelection;
static NSColor *iTermBold;
static NSColor *iTermCursor;
static NSColor* iTermColorTable[2][8];
static NSColor *xtermBackground;
static NSColor *xtermForeground;
static NSColor *xtermSelection;
static NSColor *xtermBold;
static NSColor *xtermCursor;
static NSColor* xtermColorTable[2][8];

@implementation AddressBookWindowController

//
// class methods
//
+ (id) singleInstance
{
    if ( !singleInstance )
    {
		singleInstance = [[self alloc] initWithWindowNibName: @"AddressBook"];
        [singleInstance window]; // force the window to load now
    }
    
    return singleInstance;
}

+ (void)initialize
{
    int i;
	
    [super initialize];
	
    iTermBackground = [[NSColor blackColor] retain];
    iTermForeground = [[NSColor colorWithCalibratedRed:0.8f
												 green:0.8f
												  blue:0.8f
												 alpha:1.0f]
        retain];
    iTermSelection = [[NSColor colorWithCalibratedRed:0.45f
												green:0.5f
												 blue:0.55f
												alpha:1.0f]
        retain];
	
    iTermBold = [[NSColor redColor] retain];
	iTermCursor = [[NSColor whiteColor] retain];
	
    xtermBackground = [[NSColor whiteColor] retain];
    xtermForeground = [[NSColor blackColor] retain];
    xtermSelection = [NSColor selectedTextBackgroundColor];
    xtermBold = [[NSColor redColor] retain];
	xtermCursor = [[NSColor grayColor] retain];
	
    xtermColorTable[0][0]  = [[NSColor blackColor] retain];
    xtermColorTable[0][1]  = [[NSColor redColor] retain];
    xtermColorTable[0][2]  = [[NSColor greenColor] retain];
    xtermColorTable[0][3] = [[NSColor yellowColor] retain];
    xtermColorTable[0][4] = [[NSColor blueColor] retain];
    xtermColorTable[0][5] = [[NSColor magentaColor] retain];
    xtermColorTable[0][6]  = [[NSColor cyanColor] retain];
    xtermColorTable[0][7]  = [[NSColor whiteColor] retain];
    iTermColorTable[0][0]  = [[NSColor colorWithCalibratedRed:0.0f
														green:0.0f
														 blue:0.0f
														alpha:1.0f]
        retain];
    iTermColorTable[0][1]  = [[NSColor colorWithCalibratedRed:0.7f
                                                        green:0.0f
                                                         blue:0.0f
                                                        alpha:1.0f]
        retain];
    iTermColorTable[0][2]  = [[NSColor colorWithCalibratedRed:0.0f
                                                        green:0.7f
                                                         blue:0.0f
                                                        alpha:1.0f]
        retain];
    iTermColorTable[0][3] = [[NSColor colorWithCalibratedRed:0.7f
                                                       green:0.7f
                                                        blue:0.0f
                                                       alpha:1.0f]
        retain];
    iTermColorTable[0][4] = [[NSColor colorWithCalibratedRed:0.0f
                                                       green:0.0f
                                                        blue:0.7f
                                                       alpha:1.0f]
        retain];
    iTermColorTable[0][5] = [[NSColor colorWithCalibratedRed:0.7f
                                                       green:0.0f
                                                        blue:0.7f
                                                       alpha:1.0f]
        retain];
    iTermColorTable[0][6]  = [[NSColor colorWithCalibratedRed:0.45f
                                                        green:0.45f
                                                         blue:0.7f
                                                        alpha:1.0f]
        retain];
    iTermColorTable[0][7]  = [[NSColor colorWithCalibratedRed:0.7f
                                                        green:0.7f
                                                         blue:0.7f
                                                        alpha:1.0f]
        retain];
	
    for (i=0;i<8;i++) {
        xtermColorTable[1][i]=[[AddressBookWindowController highlightColor:xtermColorTable[0][i]] retain];
        iTermColorTable[1][i]=[[AddressBookWindowController highlightColor:iTermColorTable[0][i]] retain];
    }
}

+ (NSColor *) highlightColor:(NSColor *)color
{
	
    color=[color colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
    if ([color brightnessComponent]>0.5) {
        if ([color brightnessComponent]>0.81) {
            color=[NSColor colorWithCalibratedHue:[color hueComponent]
                                       saturation:[color saturationComponent]
                                       brightness:[color brightnessComponent]-0.3
                                            alpha:[color alphaComponent]];
            //                color=[color shadowWithLevel:0.2];
        }
        else {
            color=[NSColor colorWithCalibratedHue:[color hueComponent]
                                       saturation:[color saturationComponent]
                                       brightness:[color brightnessComponent]+0.3
                                            alpha:[color alphaComponent]];
        }
        //            color=[color highlightWithLevel:0.2];
    }
    else {
        if ([color brightnessComponent]>0.19) {
            color=[NSColor colorWithCalibratedHue:[color hueComponent]
                                       saturation:[color saturationComponent]
                                       brightness:[color brightnessComponent]-0.3
                                            alpha:[color alphaComponent]];
            //                color=[color shadowWithLevel:0.2];
        }
        else {
            color=[NSColor colorWithCalibratedHue:[color hueComponent]
                                       saturation:[color saturationComponent]
                                       brightness:[color brightnessComponent]+0.3
                                            alpha:[color alphaComponent]];
            //                color=[color highlightWithLevel:0.2];
        }
    }
	
    return color;
}

- (void)windowWillLoad;
{
    // We finally set our autosave window frame name and restore the one from the user's defaults.
    [self setWindowFrameAutosaveName: @"Bookmarks"];
}

- (void)windowDidLoad;
{
    encodingList=[NSString availableStringEncodings];
    
    [[self window] setDelegate: self];
}

- (void) dealloc
{
#if DEBUG_ALLOC
    NSLog(@"AddressBookWindowController: -dealloc");
#endif
	
    singleInstance = nil;
    [backgroundImagePath release];
    backgroundImagePath = nil;
    [super dealloc];
}

+ (NSColor *) colorFromTable:(int)index highLight:(BOOL)hili
{    
    if(iTermColorTable[0][0] == nil)
		[self initialize];
    
    if (index<8)
        return iTermColorTable[hili?1:0][index];
    else return nil;    
}

+ (NSColor *) defaultSelectionColor
{
    if(iTermSelection == nil)
		[self initialize];
    return (iTermSelection);
}

+ (NSColor *) defaultBoldColor
{
    if(iTermBold == nil)
		[self initialize];
    return (iTermBold);
}

+ (NSColor *) defaultCursorColor
{
    if(xtermCursor == nil)
		[self initialize];
    return (xtermCursor);
}

// NSWindow delegate methods
- (void)windowWillClose:(NSNotification *)aNotification
{
    [self autorelease];
}

- (void)windowDidBecomeKey:(NSNotification *)aNotification
{
    // Post a notification
    [[NSNotificationCenter defaultCenter] postNotificationName: @"nonTerminalWindowBecameKey" object: nil userInfo: nil];        
}

// get/set methods
- (NSMutableArray *) addressBook
{
    return (addressBook);
}

- (void) setAddressBook: (NSMutableArray *) anAddressBook
{
    addressBook = anAddressBook;
}

// Action methods

- (IBAction)adbDuplicateEntry:(id)sender
{
    NSMutableDictionary *entry, *ae;
    int i;
	
    entry=[[self addressBook] objectAtIndex:[adTable selectedRow]];
	
    if(entry == nil)
    {
		NSBeep();
		return;
    }
	
    ae = [[NSMutableDictionary alloc] initWithDictionary: entry];
    [ae removeObjectForKey: @"DefaultEntry"];
    [ae setObject: [NSString stringWithFormat: @"%@ copy", [entry objectForKey: @"Name"]] forKey: @"Name"];
    
    [[self addressBook] addObject:ae];
    [ae release];
	
    [[self addressBook] sortUsingFunction: addressBookComparator context: nil];
    //        NSLog(@"%s(%d):-[Address entry added:%@]",
    //              __FILE__, __LINE__, ae );
    [adTable reloadData];
	
    for(i = 0; i < [[self addressBook] count]; i++)
    {
		if([[self addressBook] objectAtIndex: i] == ae)
		{
			[adTable selectRow: i byExtendingSelection: NO];
			break;
		}
    }
	
    // Save the bookmarks.
    [[ITAddressBookMgr sharedInstance] saveAddressBook];
	
    // Post a notification to all open terminals to reload their addressbooks into the shortcut menu
    [[NSNotificationCenter defaultCenter]
    postNotificationName: @"iTermReloadAddressBook"
				  object: nil
				userInfo: nil];    
}

- (IBAction)adbEditEntry:(id)sender
{
    if(sender == nil)
    {
		// edit the default entry;
		int i;
		for(i = 0; i < [[self addressBook] count]; i++)
		{
			if(isDefaultEntry([[self addressBook] objectAtIndex: i]))
				break;
		}
		if (i == [[self addressBook] count])
		{
			[self adbEditEntryAtIndex: i newEntry: NO];
		}
		
    }
    else if ([adTable selectedRow]>= 0)
    {
		[self adbEditEntryAtIndex: [adTable selectedRow] newEntry: NO];
    }
}

- (void)adbEditEntryAtIndex:(int)index newEntry: (BOOL) newEntry
{
    int r;
    NSStringEncoding const *p=encodingList;
    id entry = nil;
	
    if(index < 0 || index >= [[self addressBook] count])
    {
		return;
    }
	
    entry=[[self addressBook] objectAtIndex: index];
	
    if(entry == nil)
		return;
    
    [AE_PANEL center];
	
    [tabSelection selectItemAtIndex: 1];
    [tabView selectTabViewItemAtIndex: [tabSelection indexOfSelectedItem]];
    
    defaultEntry = isDefaultEntry( entry );
    [adName setStringValue:[entry objectForKey:@"Name"]];
    [adCommand setStringValue:[entry objectForKey:@"Command"]];
    [adEncoding removeAllItems];
    r=0;
    while (*p) {
        //        NSLog(@"%@",[NSString localizedNameOfStringEncoding:*p]);
        [adEncoding addItemWithTitle:[NSString localizedNameOfStringEncoding:*p]];
        if (*p==[[entry objectForKey:@"Encoding"] unsignedIntValue]) r=p-encodingList;
        p++;
    }
    [adEncoding selectItemAtIndex:r];
    if ([entry objectForKey:@"Term Type"])
        [adTermType selectItemWithTitle:[entry objectForKey:@"Term Type"]];
    else
        [adTermType selectItemAtIndex:0];
    if ([entry objectForKey:@"Shortcut"]&&[[entry objectForKey:@"Shortcut"] intValue]) {
        [adShortcut setStringValue:[NSString stringWithFormat:@"%c",[[entry  objectForKey:@"Shortcut"] intValue]]];
    }
    else
        [adShortcut selectItemAtIndex:0];
	
    // set the colors
    [colorScheme selectItemAtIndex: [[entry objectForKey: @"ColorScheme"] intValue]];
    [adForeground setColor:[entry objectForKey:@"Foreground"]];
    [adBackground setColor:[entry objectForKey:@"Background"]];
    if([entry objectForKey:@"SelectionColor"])
        [adSelection setColor:[entry objectForKey:@"SelectionColor"]];
    else
        [adSelection setColor: iTermSelection];
    if([entry objectForKey:@"BoldColor"])
        [adBold setColor:[entry objectForKey:@"BoldColor"]];
    else
        [adBold setColor: iTermBold];
	if([entry objectForKey:@"CursorColor"])
        [adCursor setColor:[entry objectForKey:@"CursorColor"]];
    else
        [adCursor setColor: xtermCursor];	
    if([entry objectForKey:@"AnsiBlackColor"])
        [ansiBlack setColor:[entry objectForKey:@"AnsiBlackColor"]];
    else
        [ansiBlack setColor: iTermColorTable[0][0]];
    if([entry objectForKey:@"AnsiRedColor"])
        [ansiRed setColor:[entry objectForKey:@"AnsiRedColor"]];
    else
        [ansiRed setColor: iTermColorTable[0][1]];
    if([entry objectForKey:@"AnsiGreenColor"])
        [ansiGreen setColor:[entry objectForKey:@"AnsiGreenColor"]];
    else
		[ansiGreen setColor:iTermColorTable[0][2]];
    if([entry objectForKey:@"AnsiYellowColor"])
        [ansiYellow setColor:[entry objectForKey:@"AnsiYellowColor"]];
    else
		[ansiYellow setColor:iTermColorTable[0][3]];
    if([entry objectForKey:@"AnsiBlueColor"])
        [ansiBlue setColor:[entry objectForKey:@"AnsiBlueColor"]];
    else
		[ansiBlue setColor:iTermColorTable[0][4]];
    if([entry objectForKey:@"AnsiMagentaColor"])
        [ansiMagenta setColor:[entry objectForKey:@"AnsiMagentaColor"]];
    else
		[ansiMagenta setColor:iTermColorTable[0][5]];
    if([entry objectForKey:@"AnsiCyanColor"])
        [ansiCyan setColor:[entry objectForKey:@"AnsiCyanColor"]];
    else
		[ansiCyan setColor:iTermColorTable[0][6]];
    if([entry objectForKey:@"AnsiWhiteColor"])
        [ansiWhite setColor:[entry objectForKey:@"AnsiWhiteColor"]];
    else
		[ansiWhite setColor:iTermColorTable[0][7]];
    if([entry objectForKey:@"AnsiHiBlackColor"])
        [ansiHiBlack setColor:[entry objectForKey:@"AnsiHiBlackColor"]];
    else
        [ansiHiBlack setColor: iTermColorTable[1][0]];
    if([entry objectForKey:@"AnsiHiRedColor"])
        [ansiHiRed setColor:[entry objectForKey:@"AnsiHiRedColor"]];
    else
        [ansiHiRed setColor: iTermColorTable[1][1]];
    if([entry objectForKey:@"AnsiHiGreenColor"])
        [ansiHiGreen setColor:[entry objectForKey:@"AnsiHiGreenColor"]];
    else
		[ansiHiGreen setColor:iTermColorTable[1][2]];
    if([entry objectForKey:@"AnsiHiYellowColor"])
        [ansiHiYellow setColor:[entry objectForKey:@"AnsiHiYellowColor"]];
    else
		[ansiHiYellow setColor:iTermColorTable[1][3]];
    if([entry objectForKey:@"AnsiHiBlueColor"])
        [ansiHiBlue setColor:[entry objectForKey:@"AnsiHiBlueColor"]];
    else
		[ansiHiBlue setColor:iTermColorTable[1][4]];
    if([entry objectForKey:@"AnsiHiMagentaColor"])
        [ansiHiMagenta setColor:[entry objectForKey:@"AnsiHiMagentaColor"]];
    else
		[ansiHiMagenta setColor:iTermColorTable[1][5]];
    if([entry objectForKey:@"AnsiHiCyanColor"])
        [ansiHiCyan setColor:[entry objectForKey:@"AnsiHiCyanColor"]];
    else
		[ansiHiCyan setColor:iTermColorTable[1][6]];
    if([entry objectForKey:@"AnsiHiWhiteColor"])
        [ansiHiWhite setColor:[entry objectForKey:@"AnsiHiWhiteColor"]];
    else
		[ansiHiWhite setColor:iTermColorTable[1][7]];
    
    [adRow setStringValue:[entry objectForKey:@"Row"]];
    [adCol setStringValue:[entry objectForKey:@"Col"]];
    if ([entry objectForKey:@"Transparency"]) {
        [adTransparency setIntValue:[[entry objectForKey:@"Transparency"] intValue]];
        [adTransparency2 setIntValue:[[entry objectForKey:@"Transparency"] intValue]];
    }
    else {
        [adTransparency setIntValue:10];
        [adTransparency2 setIntValue:10];
    }
    if ([entry objectForKey:@"Directory"]) {
        [adDir setStringValue:[entry objectForKey:@"Directory"]];
    }
    else {
        [adDir setStringValue:[@"~"  stringByExpandingTildeInPath]];
    }
    if ([entry objectForKey:@"Scrollback"]) {
        [adScrollback setIntValue:[[entry objectForKey:@"Scrollback"] intValue]];
    }
    else {
        [adScrollback setIntValue: 1000];
    }
	
    aeFont=[entry objectForKey:@"Font"];
    [adTextExample setStringValue:[NSString stringWithFormat:@"%@ %g", [aeFont fontName], [aeFont pointSize]]];
    [adTextExample setTextColor:[entry objectForKey:@"Foreground"]];
    [adTextExample setBackgroundColor:[entry objectForKey:@"Background"]];
    [adTextExample setFont:aeFont];
	
    aeNAFont=[entry objectForKey:@"NAFont"];
    if (aeNAFont==nil) {
        aeNAFont = aeFont;
    }
    [adNATextExample setStringValue:[NSString stringWithFormat:@"%@ %g", [aeNAFont fontName], [aeNAFont pointSize]]];
    [adNATextExample setTextColor:[entry objectForKey:@"Foreground"]];
    [adNATextExample setBackgroundColor:[entry objectForKey:@"Background"]];
    [adNATextExample setFont:aeNAFont];
    [adAI setState:([entry objectForKey:@"AntiIdle"]==nil?NO:[[entry objectForKey:@"AntiIdle"] boolValue])?NSOnState:NSOffState];
    [adAICode setIntValue:[entry objectForKey:@"AICode"]==nil?0:[[entry objectForKey:@"AICode"] intValue]];
    [adClose setState:([entry objectForKey:@"AutoClose"]==nil?NO:[[entry objectForKey:@"AutoClose"] boolValue])?NSOnState:NSOffState];
    [adDoubleWidth setState:([entry objectForKey:@"DoubleWidth"]==nil?0:[[entry objectForKey:@"DoubleWidth"] boolValue])?NSOnState:NSOffState];
    [adRemapDeleteKey setState:([entry objectForKey:@"RemapDeleteKey"]==nil?NO:[[entry objectForKey:@"RemapDeleteKey"] boolValue])?NSOnState:NSOffState];
	
    // background image
    NSString *imageFilePath;
    imageFilePath = [(NSString *)[entry objectForKey:@"BackgroundImagePath"] stringByExpandingTildeInPath];
    [backgroundImage setEditable: NO];
    if([imageFilePath length] > 0)
    {
		if([imageFilePath isAbsolutePath] == NO)
		{
			NSBundle *myBundle = [NSBundle bundleForClass: [self class]];
			backgroundImagePath = [myBundle pathForResource: imageFilePath ofType: @""];
			[backgroundImagePath retain];
		}
		else
		{
			backgroundImagePath = [[NSString alloc] initWithString: imageFilePath];
		}
		
		NSImage *anImage = [[NSImage alloc] initWithContentsOfFile: backgroundImagePath];
		if(anImage != nil)
		{
			[backgroundImage setImage: anImage];
			[anImage release];
			[adBackground setEnabled: (anImage == nil)?YES:NO];
			[useBackgroundImage setState: (anImage == nil)?NSOffState:NSOnState];
		}
		else
		{
			[useBackgroundImage setState: NSOffState];
		}	
    }
    else
    {
		[useBackgroundImage setState: NSOffState];
    }
	
	
    r= [NSApp runModalForWindow:AE_PANEL];
    [AE_PANEL close];
    if (r == NSRunStoppedResponse) {
        NSDictionary *ae;
        ae=[self _getUpdatedPropertyDictionary];
        [[self addressBook] replaceObjectAtIndex:[[self addressBook] indexOfObject: entry] withObject:ae];
		[[self addressBook] sortUsingFunction: addressBookComparator context: nil];
		//        NSLog(@"%s(%d):-[Address entry replaced:%@]",
		//              __FILE__, __LINE__, ae );
		
		// Save the bookmarks.
		[[ITAddressBookMgr sharedInstance] saveAddressBook];
		
		// Post a notification to all open terminals to reload their addressbooks into the shortcut menu
		[[NSNotificationCenter defaultCenter]
    postNotificationName: @"iTermReloadAddressBook"
				  object: nil
				userInfo: nil];	
        [adTable reloadData];
    }
    else if (newEntry)
    {
		[self adbRemoveEntry: nil];
    }
	
    [backgroundImagePath release];
    backgroundImagePath = nil;
}

- (IBAction)adbAddEntry:(id)sender
{
    [adTable selectRow: 0 byExtendingSelection: NO];
    [self adbDuplicateEntry: nil];
	
    [self adbEditEntryAtIndex: [adTable selectedRow] newEntry: YES];
}

- (IBAction)adbRemoveEntry:(id)sender
{
    if ([adTable selectedRow]<0) return;
    
    if ( isDefaultEntry( [[self addressBook] objectAtIndex:[adTable selectedRow]] ) ) {
        // Post Alert or better yet, disable the remove button
    } else {
        NSBeginAlertSheet(
						  NSLocalizedStringFromTableInBundle(@"Do you really want to remove this item?",@"iTerm", [NSBundle bundleForClass: [self class]], @"Removal Alert"),
						  NSLocalizedStringFromTableInBundle(@"Remove",@"iTerm", [NSBundle bundleForClass: [self class]], @"Remove"),
						  NSLocalizedStringFromTableInBundle(@"Cancel",@"iTerm", [NSBundle bundleForClass: [self class]], @"Cancel"),
						  nil,
						  [self window],               // window sheet is attached to
						  self,                   // we'll be our own delegate
						  @selector(sheetDidEnd:returnCode:contextInfo:),     // did-end selector
						  NULL,                   // no need for did-dismiss selector
						  sender,                 // context info
						  NSLocalizedStringFromTableInBundle(@"There is no undo for this operation.",@"iTerm", [NSBundle bundleForClass: [self class]], @"Removal Alert"),
						  nil);                   // no parameters in message
		
		[[self window] makeKeyAndOrderFront: self];
    }
}

- (void)sheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
    if ( returnCode == NSAlertDefaultReturn) {
        [[self addressBook] removeObjectAtIndex:[adTable selectedRow]];
		[[self addressBook] sortUsingFunction: addressBookComparator context: nil];
        [adTable reloadData];
		// Save the bookmarks.
		[[ITAddressBookMgr sharedInstance] saveAddressBook];
		
		// Post a notification to all open terminals to reload their addressbooks into the shortcut menu
		[[NSNotificationCenter defaultCenter]
    postNotificationName: @"iTermReloadAddressBook"
				  object: nil
				userInfo: nil];	
    }
}

// address entry window
- (IBAction)adEditBackground:(id)sender
{
    [adTextExample setBackgroundColor:[adBackground color]];
    //    [[NSColorPanel sharedColorPanel] close];
}

- (IBAction)adEditCancel:(id)sender
{
    [NSApp abortModal];
    [[NSColorPanel sharedColorPanel] close];
    [[NSFontPanel sharedFontPanel] close];
    
}

- (IBAction)adEditFont:(id)sender
{
    changingNA=NO;
    [[adTextExample window] makeFirstResponder:self];
    [[NSFontManager sharedFontManager] setSelectedFont:aeFont isMultiple:NO];
    [[NSFontManager sharedFontManager] orderFrontFontPanel:self];
}

- (IBAction)adEditNAFont:(id)sender
{
    changingNA=YES;
    [[adNATextExample window] makeFirstResponder:self];
    [[NSFontManager sharedFontManager] setSelectedFont:aeNAFont isMultiple:NO];
    [[NSFontManager sharedFontManager] orderFrontFontPanel:self];
}

- (IBAction)adEditForeground:(id)sender
{
    [adTextExample setTextColor:[sender color]];
    //    [[NSColorPanel sharedColorPanel] close];
}

- (IBAction)adEditOK:(id)sender
{
    if ([adCol intValue]<1||[adRow intValue]<1) {
        NSRunAlertPanel(NSLocalizedStringFromTableInBundle(@"Wrong Input",@"iTerm", [NSBundle bundleForClass: [self class]], @"wrong input"),
                        NSLocalizedStringFromTableInBundle(@"Please enter a valid window size",@"iTerm", [NSBundle bundleForClass: [self class]], @"wrong input"),
                        NSLocalizedStringFromTableInBundle(@"OK",@"iTerm", [NSBundle bundleForClass: [self class]], @"OK"),
                        nil,nil);
    }
    else {
        [NSApp stopModal];
        [[NSColorPanel sharedColorPanel] close];
        [[NSFontPanel sharedFontPanel] close];	
    }
}

- (IBAction) changeTab: (id) sender
{
    [tabView selectTabViewItemAtIndex: [sender indexOfSelectedItem]];
}

- (IBAction) executeABCommand: (id) sender
{
#if DEBUG_METHOD_TRACE
    NSLog(@"%s(%d):-[AddressBookWindowController executeABCommand:%@]",
          __FILE__, __LINE__, sender);
#endif
	
    if(([adTable selectedRow] < 0) || ([adTable numberOfRows] == 0))
		return;
	
    [NSApp stopModal];
	
    NSEnumerator *selectedRowEnumerator = [adTable selectedRowEnumerator];
    NSNumber *selectedRow;
	
    // launch all the selected sessions
    while((selectedRow = [selectedRowEnumerator nextObject]) != nil)
    {
		if(sender == openInWindow)
			[[iTermController sharedInstance] executeABCommandAtIndex: [selectedRow intValue] inTerminal: nil];
		else
			[[iTermController sharedInstance] executeABCommandAtIndex: [selectedRow intValue] inTerminal: [[iTermController sharedInstance] currentTerminal]];
    }
	
    // close the bookmarks window
    [self close];
}

- (IBAction)editColorScheme: (id) sender
{
    // set the color scheme to custom
    [colorScheme selectItemAtIndex: 0];
}

- (IBAction)changeColorScheme:(id)sender
{
	
    switch ([sender indexOfSelectedItem]) {
        case 0:
            break;
        case 1:
			[adBackground setColor:iTermBackground];
			[adForeground setColor:iTermForeground];
			[adSelection setColor: iTermSelection];
			[adBold setColor: iTermBold];
			[adCursor setColor: iTermCursor];
			[ansiBlack setColor:iTermColorTable[0][0]];
			[ansiRed setColor:iTermColorTable[0][1]];
			[ansiGreen setColor:iTermColorTable[0][2]];
			[ansiYellow setColor:iTermColorTable[0][3]];
			[ansiBlue setColor:iTermColorTable[0][4]];
			[ansiMagenta setColor:iTermColorTable[0][5]];
			[ansiCyan setColor:iTermColorTable[0][6]];
			[ansiWhite setColor:iTermColorTable[0][7]];
			[ansiHiBlack setColor:iTermColorTable[1][0]];
			[ansiHiRed setColor:iTermColorTable[1][1]];
			[ansiHiGreen setColor:iTermColorTable[1][2]];
			[ansiHiYellow setColor:iTermColorTable[1][3]];
			[ansiHiBlue setColor:iTermColorTable[1][4]];
			[ansiHiMagenta setColor:iTermColorTable[1][5]];
			[ansiHiCyan setColor:iTermColorTable[1][6]];
			[ansiHiWhite setColor:iTermColorTable[1][7]];	    
			break;
        case 2:
			[adBackground setColor:xtermBackground];
			[adForeground setColor:xtermForeground];
			[adSelection setColor: xtermSelection];
			[adBold setColor: xtermBold];
			[adCursor setColor: xtermCursor];
			[ansiBlack setColor:xtermColorTable[0][0]];
			[ansiRed setColor:xtermColorTable[0][1]];
			[ansiGreen setColor:xtermColorTable[0][2]];
			[ansiYellow setColor:xtermColorTable[0][3]];
			[ansiBlue setColor:xtermColorTable[0][4]];
			[ansiMagenta setColor:xtermColorTable[0][5]];
			[ansiCyan setColor:xtermColorTable[0][6]];
			[ansiWhite setColor:xtermColorTable[0][7]];
			[ansiHiBlack setColor:xtermColorTable[1][0]];
			[ansiHiRed setColor:xtermColorTable[1][1]];
			[ansiHiGreen setColor:xtermColorTable[1][2]];
			[ansiHiYellow setColor:xtermColorTable[1][3]];
			[ansiHiBlue setColor:xtermColorTable[1][4]];
			[ansiHiMagenta setColor:xtermColorTable[1][5]];
			[ansiHiCyan setColor:xtermColorTable[1][6]];
			[ansiHiWhite setColor:xtermColorTable[1][7]];	    
			break;
    }
    [adTextExample setBackgroundColor:[adBackground color]];
    [adNATextExample setBackgroundColor:[adBackground color]];
    [adTextExample setTextColor:[adForeground color]];
    [adNATextExample setTextColor:[adForeground color]];
}

// misc
- (void) run;
{
    [adTable setDataSource: self];
    [adTable setDelegate: self];
    if([adTable numberOfRows] > 0 && [adTable numberOfSelectedRows] <= 0){
		[adTable selectRow: 0 byExtendingSelection: NO];
    }
    if(isDefaultEntry([addressBook objectAtIndex: [adTable selectedRow]]))
		[deleteButton setEnabled: NO];
    else
		[deleteButton setEnabled: YES];
    
    [[self window] makeFirstResponder: adTable];
	
    [adTable setDoubleAction: @selector(executeABCommand:)];
    [adTable setAllowsColumnReordering: NO];
	
    [self showWindow: self];
}

- (void)changeFont:(id)fontManager
{
    if (changingNA) {
        [aeNAFont autorelease];
        aeNAFont=[fontManager convertFont:[adNATextExample font]];
        [adNATextExample setStringValue:[NSString stringWithFormat:@"%@ %g", [aeNAFont fontName], [aeNAFont pointSize]]];
        [adNATextExample setFont:aeNAFont];
    }
    else {
        [aeFont autorelease];
        aeFont=[fontManager convertFont:[adTextExample font]];
        [adTextExample setStringValue:[NSString stringWithFormat:@"%@ %g", [aeFont fontName], [aeFont pointSize]]];
        [adTextExample setFont:aeFont];
    }
}

- (IBAction) useBackgroundImage: (id) sender
{
    [adBackground setEnabled: ([useBackgroundImage state] == NSOffState)?YES:NO];
    if([useBackgroundImage state]==NSOffState)
    {
		backgroundImagePath = [[NSString alloc] initWithString:@""];
		[backgroundImage setImage: nil];
    }
    else
		[self chooseBackgroundImage: sender];
}

- (IBAction) chooseBackgroundImage: (id) sender
{
    NSOpenPanel *panel;
    int sts;
    NSString *directory, *filename;
    NSDictionary *entry;
	
#if DEBUG_METHOD_TRACE
    NSLog(@"%s(%d):-[AddressBookWindowController chooseBackgroundImage:%@]",
          __FILE__, __LINE__);
#endif
	
    if([useBackgroundImage state]==NSOffState)
    {
		NSBeep();
		return;
    }
	
    panel = [NSOpenPanel openPanel];
    [panel setAllowsMultipleSelection: NO];
	
    directory = NSHomeDirectory();
    filename = [NSString stringWithString: @""];
	
    [backgroundImagePath release];
    backgroundImagePath = nil;
	
    if([adTable selectedRow] > -1)
    {
		entry=[[self addressBook] objectAtIndex: [adTable selectedRow]];
		if([entry objectForKey:@"BackgroundImagePath"] != nil)
			backgroundImagePath = [[NSString alloc] initWithString: [[entry objectForKey:@"BackgroundImagePath"] stringByExpandingTildeInPath]];
		else
			backgroundImagePath = [[NSString alloc] initWithString: @""];
		
		if(entry != nil && [backgroundImagePath length] > 0)
		{
			directory = [backgroundImagePath stringByDeletingLastPathComponent];
			filename = [backgroundImagePath lastPathComponent];
		}
    }
		
    [backgroundImagePath release];
    backgroundImagePath = nil;
    sts = [panel runModalForDirectory: directory file:filename types: [NSImage imageFileTypes]];
    if (sts == NSOKButton) {
		if([[panel filenames] count] > 0)
			backgroundImagePath = [[NSString alloc] initWithString: [[panel filenames] objectAtIndex: 0]];
		
		if(backgroundImagePath != nil)
		{
			NSImage *anImage = [[NSImage alloc] initWithContentsOfFile: backgroundImagePath];
			if(anImage != nil)
			{
				[backgroundImage setImage: anImage];
				[anImage release];
			}
			else
				[useBackgroundImage setState: NSOffState];
		}
		else
			[useBackgroundImage setState: NSOffState];
    }
    else
    {
		[useBackgroundImage setState: NSOffState];
    }
	
}

// Table data source
- (int)numberOfRowsInTableView:(NSTableView*)table
{
    return [addressBook count];
}

// this message is called for each row of the table
- (id)tableView:(NSTableView*)table objectValueForTableColumn:(NSTableColumn*)col
			row:(int)rowIndex
{
    NSDictionary *theRecord;
    NSString *s=nil;
	
    NSParameterAssert(rowIndex >= 0 && rowIndex < [addressBook count]);
    theRecord = [addressBook objectAtIndex:rowIndex];
    switch ([[col identifier] intValue]) {
        case 0:
            s=entryVisibleName( theRecord, self );
            break;
        case 1:
            s=[theRecord objectForKey:@"Command"];
            break;
        case 2:
			//            NSLog(@"%@:%d",[theRecord objectForKey:@"Name"],[[theRecord objectForKey:@"Shortcut"] intValue]);
            s=([[theRecord objectForKey:@"Shortcut"] intValue]?
			   [NSString stringWithFormat:@"%c",[[theRecord objectForKey:@"Shortcut"] intValue]]:@"");
    }
	
    return s;
}


// Table view delegate
- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
    if([adTable numberOfSelectedRows] == 1)
    {
		[addButton setEnabled: YES];
		if(isDefaultEntry([addressBook objectAtIndex: [adTable selectedRow]]))
			[deleteButton setEnabled: NO];
		else
			[deleteButton setEnabled: YES];
		[duplicateButton setEnabled: YES];
		[editButton setEnabled: YES];
    }
    else
    {
		[addButton setEnabled: NO];
		[deleteButton setEnabled: NO];
		[duplicateButton setEnabled: NO];
		[editButton setEnabled: NO];
    }
	
    if([adTable numberOfSelectedRows] > 0)
    {
		[openInTab setEnabled: YES];
		[openInWindow setEnabled: YES];
    }
    else
    {
		[openInTab setEnabled: NO];
		[openInWindow setEnabled: NO];
    }
}

@end

@implementation AddressBookWindowController (Private)

- (NSDictionary *) _getUpdatedPropertyDictionary
{
    NSDictionary *ae;
	
    if(backgroundImagePath == nil)
		backgroundImagePath = [[NSString alloc] initWithString: @""];
	
    ae = [[NSDictionary alloc] initWithObjectsAndKeys:
		[adName stringValue],@"Name",
		[adCommand stringValue],@"Command",
		[NSNumber numberWithUnsignedInt:encodingList[[adEncoding indexOfSelectedItem]]],@"Encoding",
		[NSNumber numberWithUnsignedInt: [colorScheme indexOfSelectedItem]], @"ColorScheme",
		[adForeground color],@"Foreground",
		[adBackground color],@"Background",
		[adSelection color],@"SelectionColor",
		[adBold color],@"BoldColor",
		[adCursor color],@"CursorColor",
		[ansiBlack color], @"AnsiBlackColor",
		[ansiRed color], @"AnsiRedColor",
		[ansiGreen color], @"AnsiGreenColor",
		[ansiYellow color], @"AnsiYellowColor",
		[ansiBlue color], @"AnsiBlueColor",
		[ansiMagenta color], @"AnsiMagentaColor",
		[ansiCyan color], @"AnsiCyanColor",
		[ansiWhite color], @"AnsiWhiteColor",
		[ansiHiBlack color], @"AnsiHiBlackColor",
		[ansiHiRed color], @"AnsiHiRedColor",
		[ansiHiGreen color], @"AnsiHiGreenColor",
		[ansiHiYellow color], @"AnsiHiYellowColor",
		[ansiHiBlue color], @"AnsiHiBlueColor",
		[ansiHiMagenta color], @"AnsiHiMagentaColor",
		[ansiHiCyan color], @"AnsiHiCyanColor",
		[ansiHiWhite color], @"AnsiHiWhiteColor",
		[adRow stringValue],@"Row",
		[adCol stringValue],@"Col",
		[NSNumber numberWithInt:[adTransparency2 intValue]],@"Transparency",
		[adTermType titleOfSelectedItem],@"Term Type",
		[adDir stringValue],@"Directory",
		aeFont,@"Font",
		aeNAFont,@"NAFont",
		[NSNumber numberWithBool:([adAI state]==NSOnState)],@"AntiIdle",
		[NSNumber numberWithUnsignedInt:[adAICode intValue]],@"AICode",
		[NSNumber numberWithBool:([adClose state]==NSOnState)],@"AutoClose",
		[NSNumber numberWithBool:([adDoubleWidth state]==NSOnState)],@"DoubleWidth",
		[NSNumber numberWithBool:([adRemapDeleteKey state]==NSOnState)],@"RemapDeleteKey",
		[NSNumber numberWithUnsignedInt:[adShortcut indexOfSelectedItem]?[[adShortcut stringValue] characterAtIndex:0]:0],@"Shortcut",
        [NSNumber numberWithInt:[adScrollback intValue]], @"Scrollback",
		[NSString stringWithString: backgroundImagePath],@"BackgroundImagePath",
		[NSNumber numberWithBool:defaultEntry],@"DefaultEntry",
		NULL];
	
    [ae autorelease];
    return (ae);
}

@end

