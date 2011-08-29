/*
 **  PTToolbarController.m
 **
 **  Copyright (c) 2002, 2003
 **
 **  Author: Fabian, Ujwal S. Setlur
 **	     Initial code by Kiichi Kusama
 **
 **  Project: iTerm
 **
 **  Description: manages an the toolbar.
 **
 */

#import "PTToolbarController.h"
#import "iTermController.h"
#import "ITTerminalView.h"
#import "ITAddressBookMgr.h"
#import "ITPopUpButton.h"
#import "ITIconStore.h"
#import "ITSharedActionHandler.h"

NSString *NewToolbarItem = @"New";
NSString *BookmarksToolbarItem = @"Bookmarks";
NSString *CloseToolbarItem = @"Close";
NSString *SettingsToolbarItem = @"Settings";
NSString *CommandToolbarItem = @"Command";

@interface PTToolbarController (Private)
- (void)setupToolbar:(NSWindow*)window;
- (void)buildToolbarItemPopUpMenu:(NSToolbarItem *)toolbarItem;
- (NSMenu*)buildNewPopupMenu:(BOOL)addDummyItem;
- (NSMenu*)buildConfigPopupMenu:(BOOL)addDummyItem;
- (NSToolbarItem*)toolbarItemWithIdentifier:(NSString*)identifier;

- (NSToolbar *)toolbar;
- (void)setToolbar:(NSToolbar *)theToolbar;

- (ITTerminalView *)term;
- (void)setTerm:(ITTerminalView *)theTerm;
@end

@implementation PTToolbarController

- (id)initWithWindow:(NSWindow*)window 
	  term:(ITTerminalView*)term; 
{
    self = [super init];
    [self setTerm:term];
    
    // Add ourselves as an observer for notifications to reload the addressbook.
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(reloadAddressBookMenu:)
                                                 name: @"iTermReloadAddressBook"
                                               object: nil];
    
    [self setupToolbar:window];
    return self;
}

- (void)dealloc;
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
	
    [self setToolbar:nil];
	[self setTerm:nil];

    [super dealloc];
}

- (NSArray *)toolbarDefaultItemIdentifiers: (NSToolbar *) toolbar
{
    NSMutableArray* itemIdentifiers= [[[NSMutableArray alloc]init] autorelease];
    
    [itemIdentifiers addObject: NewToolbarItem];
    [itemIdentifiers addObject: SettingsToolbarItem];
    [itemIdentifiers addObject: NSToolbarSeparatorItemIdentifier];
    [itemIdentifiers addObject: NSToolbarCustomizeToolbarItemIdentifier];
    [itemIdentifiers addObject: CloseToolbarItem];
    [itemIdentifiers addObject: NSToolbarSeparatorItemIdentifier];
    [itemIdentifiers addObject: CommandToolbarItem];
//	[itemIdentifiers addObject: BookmarksToolbarItem];
    
    return itemIdentifiers;
}

- (NSArray *)toolbarAllowedItemIdentifiers: (NSToolbar *) toolbar
{
    NSMutableArray* itemIdentifiers = [[[NSMutableArray alloc]init] autorelease];
    
    [itemIdentifiers addObject: NewToolbarItem];
//	[itemIdentifiers addObject: BookmarksToolbarItem];
    [itemIdentifiers addObject: SettingsToolbarItem];
    [itemIdentifiers addObject: NSToolbarCustomizeToolbarItemIdentifier];
    [itemIdentifiers addObject: CloseToolbarItem];
    [itemIdentifiers addObject: CommandToolbarItem];
    [itemIdentifiers addObject: NSToolbarFlexibleSpaceItemIdentifier];
    [itemIdentifiers addObject: NSToolbarSpaceItemIdentifier];
    [itemIdentifiers addObject: NSToolbarSeparatorItemIdentifier];
    
    return itemIdentifiers;
}

- (NSToolbarItem *)toolbar: (NSToolbar *)toolbar itemForItemIdentifier: (NSString *) itemIdent willBeInsertedIntoToolbar:(BOOL) willBeInserted
{
    NSToolbarItem *toolbarItem = [[[NSToolbarItem alloc] initWithItemIdentifier: itemIdent] autorelease];
    NSBundle *thisBundle = [NSBundle bundleForClass: [self class]];
    NSString *imagePath;
    NSImage *anImage;
    
    if ([itemIdent isEqual: CloseToolbarItem]) 
    {
        [toolbarItem setLabel: NTLocalizedStringFromTableInBundle(@"Close",@"iTerm", thisBundle, @"Toolbar Item: Close Session")];
        [toolbarItem setPaletteLabel: NTLocalizedStringFromTableInBundle(@"Close",@"iTerm", thisBundle, @"Toolbar Item: Close Session")];
        [toolbarItem setToolTip: NTLocalizedStringFromTableInBundle(@"Close the current session",@"iTerm", thisBundle, @"Toolbar Item Tip: Close")];
        imagePath = [thisBundle pathForResource:@"close"
                                         ofType:@"png"];
        anImage = [[NSImage alloc] initByReferencingFile: imagePath];
        [toolbarItem setImage: anImage];
        [anImage release];
        [toolbarItem setTarget:nil];
        [toolbarItem setAction: @selector(closeTabAction:)];
    }
    else if ([itemIdent isEqual: SettingsToolbarItem]) 
    {
        ITPopUpButton *aPopUpButton;
		
        if ([toolbar sizeMode] == NSToolbarSizeModeSmall)
            aPopUpButton = [[[ITPopUpButton alloc] initWithFrame: NSMakeRect(0.0, 0.0, 24.0, 24.0) pullsDown: YES] autorelease];
        else
            aPopUpButton = [[[ITPopUpButton alloc] initWithFrame: NSMakeRect(0.0, 0.0, 32.0, 32.0) pullsDown: YES] autorelease];
		
		// build the menu
      	[aPopUpButton setMenu:[self buildConfigPopupMenu:YES]];

		[aPopUpButton setBezelStyle:NSRegularSquareBezelStyle];
		[aPopUpButton setImagePosition:NSImageOnly];
		[aPopUpButton setTarget: nil];
		[aPopUpButton setBordered: NO];
		
		[aPopUpButton setContentImageID:@"GenericPreferencesIcon"]; 
		
        // Release the popup button since it is retained by the toolbar item.
		[toolbarItem setView: aPopUpButton];
        
		NSSize sz = [aPopUpButton bounds].size;
        [toolbarItem setMinSize:sz];
        [toolbarItem setMaxSize:sz];

        [toolbarItem setLabel: NTLocalizedStringFromTableInBundle(SettingsToolbarItem,@"iTerm", thisBundle, @"Toolbar Item:Info") ];
        [toolbarItem setPaletteLabel: NTLocalizedStringFromTableInBundle(SettingsToolbarItem,@"iTerm", thisBundle, @"Toolbar Item:Info") ];
        [toolbarItem setToolTip: NTLocalizedStringFromTableInBundle(@"Window/Session Info",@"iTerm", thisBundle, @"Toolbar Item Tip:Info")];
		
		// text only mode menu
		{
			NSMenuItem *menuItem = [[[NSMenuItem alloc] initWithTitle:[toolbarItem label] action:0 keyEquivalent: @""] autorelease];
			
			[menuItem setTarget:nil];
			[menuItem setSubmenu:[self buildConfigPopupMenu:NO]];
			
			[toolbarItem setMenuFormRepresentation:menuItem];
		}		
    } 
	else if ([itemIdent isEqual: BookmarksToolbarItem]) 
    {
        [toolbarItem setLabel: NTLocalizedStringFromTableInBundle(@"Bookmarks",@"iTerm", thisBundle, @"Toolbar Item: Bookmarks") ];
        [toolbarItem setPaletteLabel: NTLocalizedStringFromTableInBundle(@"Bookmarks",@"iTerm", thisBundle, @"Toolbar Item: Bookmarks") ];
        [toolbarItem setToolTip: NTLocalizedStringFromTableInBundle(@"Bookmarks",@"iTerm", thisBundle, @"Toolbar Item Tip: Bookmarks")];
        imagePath = [thisBundle pathForResource:@"addressbook"
                                         ofType:@"png"];
        anImage = [[NSImage alloc] initByReferencingFile: imagePath];
        [toolbarItem setImage: anImage];
        [anImage release];
        [toolbarItem setTarget: nil];
        [toolbarItem setAction: @selector(toggleBookmarksView:)];
    } 	
    else if ([itemIdent isEqual: NewToolbarItem])
    {
        ITPopUpButton *aPopUpButton;
		
        if ([toolbar sizeMode] == NSToolbarSizeModeSmall)
            aPopUpButton = [[[ITPopUpButton alloc] initWithFrame: NSMakeRect(0.0, 0.0, 24.0, 24.0) pullsDown: YES] autorelease];
        else
            aPopUpButton = [[[ITPopUpButton alloc] initWithFrame: NSMakeRect(0.0, 0.0, 32.0, 32.0) pullsDown: YES] autorelease];
        		
		// build the menu
      	[aPopUpButton setMenu:[self buildNewPopupMenu:YES]];

		[aPopUpButton setBezelStyle:NSRegularSquareBezelStyle];
		[aPopUpButton setImagePosition:NSImageOnly];
		[aPopUpButton setTarget: nil];
		[aPopUpButton setBordered: NO];
		
		[aPopUpButton setContentImageID:@"newwin"]; 
		
        // Release the popup button since it is retained by the toolbar item.
		[toolbarItem setView: aPopUpButton];
        
		NSSize sz = [aPopUpButton bounds].size;
        [toolbarItem setMinSize:sz];
        [toolbarItem setMaxSize:sz];
        [toolbarItem setLabel: NTLocalizedStringFromTableInBundle(@"New",@"iTerm", thisBundle, @"Toolbar Item:New")];
        [toolbarItem setPaletteLabel: NTLocalizedStringFromTableInBundle(@"New",@"iTerm", thisBundle, @"Toolbar Item:New")];
        [toolbarItem setToolTip: NTLocalizedStringFromTableInBundle(@"Open a new session",@"iTerm", thisBundle, @"Toolbar Item:New")];
		
		// text only mode menu
		{
			NSMenuItem *menuItem = [[[NSMenuItem alloc] initWithTitle:[toolbarItem label] action:0 keyEquivalent: @""] autorelease];
			
			[menuItem setTarget:nil];
			[menuItem setSubmenu:[self buildNewPopupMenu:NO]];
			
			[toolbarItem setMenuFormRepresentation:menuItem];
		}				
    }
    else if ([itemIdent isEqual: CommandToolbarItem])
	{
		// Set up the standard properties 
		[toolbarItem setLabel:NTLocalizedStringFromTableInBundle(@"Execute",@"iTerm", thisBundle, @"Toolbar Item:New")];
		[toolbarItem setPaletteLabel:NTLocalizedStringFromTableInBundle(@"Execute",@"iTerm", thisBundle, @"Toolbar Item:New")];
		[toolbarItem setToolTip:NTLocalizedStringFromTableInBundle(@"Execute Command or Launch URL",@"iTerm", thisBundle, @"Toolbar Item:New")];
		
		// Use a custom view, a rounded text field,
		[toolbarItem setView:[[self term] commandField]];
		[toolbarItem setMinSize:NSMakeSize(100,NSHeight([[[self term] commandField] frame]))];
		[toolbarItem setMaxSize:NSMakeSize(700,NSHeight([[[self term] commandField] frame]))];
	}
	else
        toolbarItem=nil;
    
    return toolbarItem;
}

@end

@implementation PTToolbarController (Private)

//---------------------------------------------------------- 
//  toolbar 
//---------------------------------------------------------- 
- (NSToolbar *)toolbar
{
    return mToolbar; 
}

- (void)setToolbar:(NSToolbar *)theToolbar
{
    if (mToolbar != theToolbar)
    {
        [mToolbar release];
        mToolbar = [theToolbar retain];
    }
}

- (void)setupToolbar:(NSWindow*)window;
{   
	[self setToolbar:[[[NSToolbar alloc] initWithIdentifier: NSStringFromClass([self class])] autorelease]];
    [[self toolbar] setVisible:true];
    [[self toolbar] setDelegate:self];
    [[self toolbar] setAllowsUserCustomization:YES];
    [[self toolbar] setAutosavesConfiguration:YES];
	[[self toolbar] setShowsBaselineSeparator:NO];

	[[self toolbar] setDisplayMode:NSToolbarDisplayModeDefault];
	[[self toolbar] setSizeMode:NSToolbarSizeModeSmall];
    [[self toolbar] insertItemWithItemIdentifier: NewToolbarItem atIndex:0];
    [[self toolbar] insertItemWithItemIdentifier: SettingsToolbarItem atIndex:1];
    [[self toolbar] insertItemWithItemIdentifier: NSToolbarFlexibleSpaceItemIdentifier atIndex:2];
    [[self toolbar] insertItemWithItemIdentifier: NSToolbarCustomizeToolbarItemIdentifier atIndex:3];
    [[self toolbar] insertItemWithItemIdentifier: NSToolbarSeparatorItemIdentifier atIndex:4];
    [[self toolbar] insertItemWithItemIdentifier: CommandToolbarItem atIndex:5];
    [[self toolbar] insertItemWithItemIdentifier: CloseToolbarItem atIndex:6];
    
    [window setToolbar:[self toolbar]];
}

- (NSMenu*)buildNewPopupMenu:(BOOL)addDummyItem;
{
    NSMenuItem *tip;
    NSMenu *aMenu;
    
    aMenu = [[[NSMenu alloc] init] autorelease];
	
	if (addDummyItem)
		[aMenu addItem:[[[NSMenuItem alloc] init] autorelease]];  // dummy item
	
    [[iTermController sharedInstance] alternativeMenu: aMenu 
                                              forNode: [[ITAddressBookMgr sharedInstance] rootNode] 
                                               target: [self term]];    
    [aMenu addItem: [NSMenuItem separatorItem]];
    tip = [[[NSMenuItem alloc] initWithTitle: NTLocalizedStringFromTableInBundle(@"Press Option for New Window",@"iTerm", [NSBundle bundleForClass: [self class]], @"Toolbar Item: New") action:@selector(xyz) keyEquivalent: @""] autorelease];
    [tip setKeyEquivalentModifierMask: NSCommandKeyMask];
    [aMenu addItem: tip];
    tip = [[tip copy] autorelease];
    [tip setTitle:NTLocalizedStringFromTableInBundle(@"Open In New Window",@"iTerm", [NSBundle bundleForClass: [self class]], @"Toolbar Item: New")];
    [tip setKeyEquivalentModifierMask: NSCommandKeyMask | NSAlternateKeyMask];
    [tip setAlternate:YES];
    [aMenu addItem: tip];
	
	return aMenu;
}

- (NSMenu*)buildConfigPopupMenu:(BOOL)addDummyItem;
{
    NSMenuItem *menuItem;
    NSMenu *aMenu;
    
    aMenu = [[[NSMenu alloc] init] autorelease];
	
	if (addDummyItem)
		[aMenu addItem:[[[NSMenuItem alloc] init] autorelease]];  // dummy item
	
    menuItem = [[[NSMenuItem alloc] initWithTitle:NTLocalizedStringFromTableInBundle(@"Configuration", @"iTerm", [NSBundle bundleForClass: [self class]], @"") action:@selector(showConfigWindow:) keyEquivalent: @""] autorelease];
	[menuItem setTarget:[ITSharedActionHandler sharedInstance]];
    [aMenu addItem: menuItem];
	
	menuItem = [[[NSMenuItem alloc] initWithTitle:NTLocalizedStringFromTableInBundle(@"Preferences", @"iTerm", [NSBundle bundleForClass: [self class]], @"") action:@selector(showPreferencesAction:) keyEquivalent: @""] autorelease];
  	[menuItem setTarget:[ITSharedActionHandler sharedInstance]];
	[aMenu addItem: menuItem];
	
//	menuItem = [[[NSMenuItem alloc] initWithTitle:NTLocalizedStringFromTableInBundle(@"Profiles", @"iTerm", [NSBundle bundleForClass: [self class]], @"") action:@selector(showProfilesAction:) keyEquivalent: @""] autorelease];
// 	[menuItem setTarget:[ITSharedActionHandler sharedInstance]];
//	[aMenu addItem: menuItem];
	
	return aMenu;
}

- (void)buildToolbarItemPopUpMenu:(NSToolbarItem *)toolbarItem;
{
	NSMenuItem *item, *tip;
    NSMenu *aMenu;
    
    if (toolbarItem == nil)
        return;
	
    // build a menu representation for text only.
    item = [[[NSMenuItem alloc] initWithTitle: NTLocalizedStringFromTableInBundle(@"New",@"iTerm", [NSBundle bundleForClass: [self class]], @"Toolbar Item:New") action: nil keyEquivalent: @""] autorelease];
    aMenu = [[[NSMenu alloc] init] autorelease];
    [[iTermController sharedInstance] alternativeMenu: aMenu 
                                              forNode: [[ITAddressBookMgr sharedInstance] rootNode] 
                                               target: [self term]];    
    [aMenu addItem: [NSMenuItem separatorItem]];
    tip = [[[NSMenuItem alloc] initWithTitle: NTLocalizedStringFromTableInBundle(@"Press Option for New Window",@"iTerm", [NSBundle bundleForClass: [self class]], @"Toolbar Item: New") action:@selector(xyz) keyEquivalent: @""] autorelease];
    [tip setKeyEquivalentModifierMask: NSCommandKeyMask];
    [aMenu addItem: tip];
    tip = [[tip copy] autorelease];
    [tip setTitle:NTLocalizedStringFromTableInBundle(@"Open In New Window",@"iTerm", [NSBundle bundleForClass: [self class]], @"Toolbar Item: New")];
    [tip setKeyEquivalentModifierMask: NSCommandKeyMask | NSAlternateKeyMask];
    [tip setAlternate:YES];
    [aMenu addItem: tip];
	[item setSubmenu: aMenu];
        
    [toolbarItem setMenuFormRepresentation: item];
}

// Reloads the addressbook entries into the popup toolbar item
- (void)reloadAddressBookMenu:(NSNotification *)aNotification
{
    NSToolbarItem *aToolbarItem = [self toolbarItemWithIdentifier:NewToolbarItem];
    
    if (aToolbarItem )
        [self buildToolbarItemPopUpMenu: aToolbarItem];
}

- (NSToolbarItem*)toolbarItemWithIdentifier:(NSString*)identifier
{
    NSArray *toolbarItemArray;
    NSToolbarItem *aToolbarItem;
    int i;
    
    toolbarItemArray = [[self toolbar] items];
    
    // Find the addressbook popup item and reset it
    for (i = 0; i < [toolbarItemArray count]; i++)
    {
        aToolbarItem = [toolbarItemArray objectAtIndex: i];
        
        if ([[aToolbarItem itemIdentifier] isEqual: identifier])
            return aToolbarItem;
    }

	return nil;
}

//---------------------------------------------------------- 
//  term 
//---------------------------------------------------------- 
- (ITTerminalView *)term
{
    return mTerm; 
}

- (void)setTerm:(ITTerminalView *)theTerm
{
    if (mTerm != theTerm)
    {
        [mTerm release];
        mTerm = [theTerm retain];
    }
}

@end

