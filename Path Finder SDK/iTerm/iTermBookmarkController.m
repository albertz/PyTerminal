//
//  untitled.m
//  iTerm
//
//  Created by Tianming Yang on 10/11/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "iTermBookmarkController.h"
#import "NSStringITerm.h"
#import "iTermController.h"
#import "ITAddressBookMgr.h"
#import "iTermKeyBindingMgr.h"
#import "iTermDisplayProfileMgr.h"
#import "iTermTerminalProfileMgr.h"
#import "Tree.h"

static BOOL editingBookmark = NO;

#define iTermOutlineViewPboardType 	@"iTermOutlineViewPboardType"

#define DEBUG_OBJALLOC 0

@implementation iTermBookmarkController

+ (iTermBookmarkController*)sharedInstance
{
    static iTermBookmarkController* shared = nil;
    
    if (!shared)
	{
		shared = [[self alloc] init];
	}
     
    return shared;
}

- (id)init
{
    if ((self = [super init]) == nil)
        return nil;

    _prefs = [NSUserDefaults standardUserDefaults];
 	// load bookmarks
	[[ITAddressBookMgr sharedInstance] setBookmarks: [_prefs objectForKey: @"Bookmarks"]];
	// migrate old bookmarks, if any
	[[ITAddressBookMgr sharedInstance] migrateOldBookmarks];
	[_prefs setObject: [[ITAddressBookMgr sharedInstance] bookmarks] forKey: @"Bookmarks"];
    
    return self;
}

- (id)initWithWindowNibName: (NSString *) windowNibName
{
#if DEBUG_OBJALLOC
    NSLog(@"%s(%d):-[iTermBookmarkController init]", __FILE__, __LINE__);
#endif
    if ((self = [super init]) == nil)
        return nil;
	
	[super initWithWindowNibName: windowNibName];
    
	[[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(_reloadAddressBook:)
                                                 name: @"iTermReloadAddressBook"
                                               object: nil];	
    
    return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

- (void)showWindow
{
	// load nib if we haven't already
	if ([self window] == nil)
        [self initWithWindowNibName: @"Bookmarks"];

    [bookmarksView setDoubleAction: @selector(editBookmark:)];	
    
    [[self window] setDelegate: self]; // also forces window to load
	[self outlineViewSelectionDidChange:nil];
    [self showWindow: self];
}

- (IBAction)closeWindow:(id)sender
{
	[[self window] close];
}


// NSOutlineView delegate methods
- (void)outlineViewSelectionDidChange: (NSNotification *) aNotification
{
	int selectedRow;
	id selectedItem;
		
	selectedRow = [bookmarksView selectedRow];
	
	if (selectedRow == -1)
	{
		[bookmarkDeleteButton setEnabled: NO];
		[bookmarkEditButton setEnabled: NO];
		[defaultSessionButton setEnabled: NO];
        [launchButton setEnabled: NO];
	}
	else
	{
		selectedItem = [bookmarksView itemAtRow: selectedRow];
		
		if ([[ITAddressBookMgr sharedInstance] mayDeleteBookmarkNode: selectedItem])
			[bookmarkDeleteButton setEnabled: YES];
		else
			[bookmarkDeleteButton setEnabled: NO];
		
		// check for default bookmark
		if ([[ITAddressBookMgr sharedInstance] defaultBookmark] == selectedItem)
		{
			[defaultSessionButton setState: NSOnState];
			[defaultSessionButton setEnabled: NO];
			[bookmarkEditButton setEnabled: YES];
            [launchButton setEnabled: YES];
		}
		// check for folder
		else if ([[ITAddressBookMgr sharedInstance] isExpandable: selectedItem])
		{
			[bookmarkEditButton setEnabled: NO];
			[defaultSessionButton setEnabled: NO];
            [launchButton setEnabled: NO];
        }		
		else
		{
			[defaultSessionButton setState: NSOffState];
			[defaultSessionButton setEnabled: YES];
			[bookmarkEditButton setEnabled: YES];
            [launchButton setEnabled: YES];
		}
				
	}
}

// NSOutlineView data source methods
// required
- (id)outlineView:(NSOutlineView *)ov child:(NSInteger)index ofItem:(id)item
{
    //NSLog(@"%s", __PRETTY_FUNCTION__);
    return [[ITAddressBookMgr sharedInstance] child:index ofItem: item];
}

- (BOOL)outlineView:(NSOutlineView *)ov isItemExpandable:(id)item
{
    //NSLog(@"%s", __PRETTY_FUNCTION__);
    return [[ITAddressBookMgr sharedInstance] isExpandable: item];
}

- (NSInteger)outlineView:(NSOutlineView *)ov numberOfChildrenOfItem:(id)item
{
    //NSLog(@"%s: ov = 0x%x; item = 0x%x; numChildren: %d", __PRETTY_FUNCTION__, ov, item,
	//	  [[ITAddressBookMgr sharedInstance] numberOfChildrenOfItem: item]);
    return [[ITAddressBookMgr sharedInstance] numberOfChildrenOfItem: item];
}

- (id)outlineView:(NSOutlineView *)ov objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{
    //NSLog(@"%s: outlineView = 0x%x; item = %@; column= %@", __PRETTY_FUNCTION__, ov, item, [tableColumn identifier]);
	// item should be a tree node witha dictionary data object
    return [[ITAddressBookMgr sharedInstance] objectForKey:[tableColumn identifier] inItem: item];
}

// Optional method: needed to allow editing.
- (void)outlineView:(NSOutlineView *)olv setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn byItem:(id)item  
{
	[[ITAddressBookMgr sharedInstance] setObjectValue: object forKey:[tableColumn identifier] inItem: item];	
}

// ================================================================
//  NSOutlineView data source methods. (dragging related)
// ================================================================

- (BOOL)outlineView:(NSOutlineView *)olv writeItems:(NSArray*)items toPasteboard:(NSPasteboard*)pboard 
{
    draggedNodes = items; // Don't retain since this is just holding temporaral drag information, and it is only used during a drag!  We could put this in the pboard actually.
    
    // Provide data for our custom type, and simple NSStrings.
    [pboard declareTypes:[NSArray arrayWithObjects: iTermOutlineViewPboardType, nil] owner:self];
    
    // the actual data doesn't matter since DragDropSimplePboardType drags aren't recognized by anyone but us!.
    [pboard setData:[NSData data] forType:iTermOutlineViewPboardType]; 
    	
    return YES;
}

- (NSDragOperation)outlineView:(NSOutlineView*)olv validateDrop:(id <NSDraggingInfo>)info proposedItem:(id)item proposedChildIndex:(NSInteger)childIndex 
{
    // This method validates whether or not the proposal is a valid one. Returns NO if the drop should not be allowed.
    TreeNode *targetNode = item;
    BOOL targetNodeIsValid = YES;
		
	// Refuse if: dropping "on" the view itself unless we have no data in the view.
	if (targetNode==nil && childIndex==NSOutlineViewDropOnItemIndex && [[ITAddressBookMgr sharedInstance] numberOfChildrenOfItem: nil]!=0) 
		targetNodeIsValid = NO;
	
	if ([targetNode isLeaf])
		targetNodeIsValid = NO;
		
	// Check to make sure we don't allow a node to be inserted into one of its descendants!
	if (targetNodeIsValid && ([info draggingSource]==bookmarksView) && [[info draggingPasteboard] availableTypeFromArray:[NSArray arrayWithObject: iTermOutlineViewPboardType]] != nil) 
	{
		NSArray *theDraggedNodes = [(iTermBookmarkController*)[[info draggingSource] dataSource] _draggedNodes];
		targetNodeIsValid = ![targetNode isDescendantOfNodeInArray: theDraggedNodes];
	}
    
    // Set the item and child index in case we computed a retargeted one.
    [bookmarksView setDropItem:targetNode dropChildIndex:childIndex];
    
    return targetNodeIsValid ? NSDragOperationGeneric : NSDragOperationNone;
}

- (BOOL)outlineView:(NSOutlineView*)olv acceptDrop:(id <NSDraggingInfo>)info item:(id)targetItem childIndex:(NSInteger)childIndex 
{
	TreeNode *parentNode;
	
	parentNode = targetItem;
	if (parentNode == nil)
		parentNode = [[ITAddressBookMgr sharedInstance] rootNode];

	childIndex = (childIndex==NSOutlineViewDropOnItemIndex?0:childIndex);
    
    [self _performDropOperation:info onNode:parentNode atIndex:childIndex];
	
    return YES;
}


// Bookmark actions
- (IBAction)addBookmarkFolder:(id)sender
{
	[NSApp beginSheet: addBookmarkFolderPanel
	   modalForWindow: [self window]
		modalDelegate: self
	   didEndSelector: @selector(_addBookmarkFolderSheetDidEnd:returnCode:contextInfo:)
		  contextInfo: nil];        
}

- (IBAction)addBookmarkFolderConfirm:(id)sender
{
	//NSLog(@"%s", __PRETTY_FUNCTION__);
	[NSApp endSheet:addBookmarkFolderPanel returnCode:NSOKButton];
}

- (IBAction)addBookmarkFolderCancel:(id)sender
{
	//NSLog(@"%s", __PRETTY_FUNCTION__);
	[NSApp endSheet:addBookmarkFolderPanel returnCode:NSCancelButton];
}

- (IBAction)addBookmark:(id)sender
{
	
	editingBookmark = NO;
	
	// load our profiles
	[self _loadProfiles];
	
	[NSApp beginSheet: editBookmarkPanel
	   modalForWindow: [self window]
		modalDelegate: self
	   didEndSelector: @selector(_editBookmarkSheetDidEnd:returnCode:contextInfo:)
		  contextInfo: nil];        
}

- (IBAction)addBookmarkConfirm:(id)sender
{
	[NSApp endSheet:editBookmarkPanel returnCode:NSOKButton];
}

- (IBAction)addBookmarkCancel:(id)sender
{
	[NSApp endSheet:editBookmarkPanel returnCode:NSCancelButton];
}

- (IBAction)deleteBookmark:(id)sender
{
    NSBeginAlertSheet(NTLocalizedStringFromTableInBundle(@"Delete Bookmark",@"iTerm", [NSBundle bundleForClass: [self class]], @"Bookmarks"),
                      NTLocalizedStringFromTableInBundle(@"Delete",@"iTerm", [NSBundle bundleForClass: [self class]], @"Bookmarks"),
                      NTLocalizedStringFromTableInBundle(@"Cancel",@"iTerm", [NSBundle bundleForClass: [self class]], @"Bookmarks"),
                      nil, [self window], self, 
                      @selector(_deleteBookmarkSheetDidEnd:returnCode:contextInfo:), 
                      NULL, NULL, 
                      [NSString stringWithFormat:NTLocalizedStringFromTableInBundle(@"Are you sure that you want to delete %@? There is no way to undo this action.",@"iTerm", [NSBundle bundleForClass: [self class]], @"Profiles"),
                          [[ITAddressBookMgr sharedInstance] objectForKey:@"Name" inItem: [bookmarksView itemAtRow: [bookmarksView selectedRow]]] ]);
/*	[NSApp beginSheet: deleteBookmarkPanel
	   modalForWindow: [self window]
		modalDelegate: self
	   didEndSelector: @selector(_deleteBookmarkSheetDidEnd:returnCode:contextInfo:)
		  contextInfo: nil];   */     
}

- (IBAction)editBookmark:(id)sender
{
	id selectedItem;
	NSString *terminalProfile, *keyboardProfile, *displayProfile, *shortcut;
	
	editingBookmark = YES;
	
	// load our profiles
	[self _loadProfiles];
	
	selectedItem = [bookmarksView itemAtRow: [bookmarksView selectedRow]];
	[bookmarkName setStringValue: [[ITAddressBookMgr sharedInstance] objectForKey: KEY_NAME inItem: selectedItem]];
	[bookmarkCommand setStringValue: [[ITAddressBookMgr sharedInstance] objectForKey: KEY_COMMAND inItem: selectedItem]];
	[bookmarkWorkingDirectory setStringValue: [[ITAddressBookMgr sharedInstance] objectForKey: KEY_WORKING_DIRECTORY inItem: selectedItem]];
	
	terminalProfile = [[ITAddressBookMgr sharedInstance] objectForKey: KEY_TERMINAL_PROFILE inItem: selectedItem];
	keyboardProfile = [[ITAddressBookMgr sharedInstance] objectForKey: KEY_KEYBOARD_PROFILE inItem: selectedItem];
	displayProfile = [[ITAddressBookMgr sharedInstance] objectForKey: KEY_DISPLAY_PROFILE inItem: selectedItem];
	
	if ([bookmarkTerminalProfile indexOfItemWithTitle: terminalProfile] < 0)
		terminalProfile = NTLocalizedStringFromTableInBundle(@"Default",@"iTerm", [NSBundle bundleForClass: [self class]], @"Terminal Profiles");
	[bookmarkTerminalProfile selectItemWithTitle: terminalProfile];
	
	if ([bookmarkKeyboardProfile indexOfItemWithTitle: keyboardProfile] < 0)
		keyboardProfile = NTLocalizedStringFromTableInBundle(@"Global",@"iTerm", [NSBundle bundleForClass: [self class]], @"Key Binding Profiles");
	[bookmarkKeyboardProfile selectItemWithTitle: keyboardProfile];
	
	if ([bookmarkDisplayProfile indexOfItemWithTitle: displayProfile] < 0)
		displayProfile = NTLocalizedStringFromTableInBundle(@"Default",@"iTerm", [NSBundle bundleForClass: [self class]], @"Display Profiles");
	[bookmarkDisplayProfile selectItemWithTitle: displayProfile];
	
	shortcut = [[ITAddressBookMgr sharedInstance] objectForKey: KEY_SHORTCUT inItem: selectedItem];
	shortcut = [shortcut uppercaseString];
	if ([shortcut length] <= 0)
		shortcut = @"";
	[bookmarkShortcut selectItemWithTitle: shortcut];

	
	[NSApp beginSheet: editBookmarkPanel
	   modalForWindow: [self window]
		modalDelegate: self
	   didEndSelector: @selector(_editBookmarkSheetDidEnd:returnCode:contextInfo:)
		  contextInfo: nil];        
}

- (IBAction)setDefaultSession:(id)sender
{
	id selectedItem;
	
	selectedItem = [bookmarksView itemAtRow: [bookmarksView selectedRow]];
	
	[[ITAddressBookMgr sharedInstance] setDefaultBookmark: selectedItem];
	[self outlineViewSelectionDidChange: nil];
	
}


// NSWindow delegate
- (void)windowWillLoad
{
    // We finally set our autosave window frame name and restore the one from the user's defaults.
    [self setWindowFrameAutosaveName: @"Bookmarks"];
}

- (void)windowDidLoad
{
	[NTLocalizedString localizeWindow:[self window] table:@"terminal"];

	// Register to get our custom type!
    [bookmarksView registerForDraggedTypes:[NSArray arrayWithObjects: iTermOutlineViewPboardType, nil]];

}

- (void)windowDidBecomeKey:(NSNotification *)aNotification
{
	// make sure buttons are properly enabled/disabled
	[bookmarksView reloadData];
	[self outlineViewSelectionDidChange: nil];
}

- (void)windowWillClose:(NSNotification *)aNotification
{
	[_prefs setObject: [[ITAddressBookMgr sharedInstance] bookmarks] forKey: @"Bookmarks"];
	[_prefs synchronize];

    [[NSNotificationCenter defaultCenter] postNotificationName: @"iTermRefreshTerminal" object: nil userInfo: nil];    
}

- (IBAction)launchSession:(id)sender
{
    int selectedRow = [bookmarksView selectedRow];
	TreeNode *selectedItem;
	
	//NSLog(@"selected: %d", [sender selectedSegment]);
	if (selectedRow < 0)
		return;
	

	selectedItem = [bookmarksView itemAtRow: selectedRow];
	if (selectedItem != nil && [selectedItem isLeaf])
	{
		[[iTermController sharedInstance] launchBookmark: [selectedItem nodeData] inTerminal: [sender selectedSegment] ? nil :[[iTermController sharedInstance] currentTerminal]];
	}
}

@end

@implementation iTermBookmarkController (Private)

- (void)_addBookmarkFolderSheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
	TreeNode *parentNode;
	int selectedRow;
	
	selectedRow = [bookmarksView selectedRow];
	
	// if no row is selected, new node is child of root
	if (selectedRow == -1)
		parentNode = nil;
	else
		parentNode = [bookmarksView itemAtRow: selectedRow];
	
	// If a leaf node is selected, make new node its sibling
	if ([bookmarksView isExpandable: parentNode] == NO)
		parentNode = [parentNode nodeParent];
	
	if (returnCode == NSOKButton && [[bookmarkFolderName stringValue] length] > 0)
	{		
		[[ITAddressBookMgr sharedInstance] addFolder: [bookmarkFolderName stringValue] toNode: parentNode];
	}
    
    id prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject: [[ITAddressBookMgr sharedInstance] bookmarks] forKey: @"Bookmarks"];
    [prefs synchronize];
    
	[addBookmarkFolderPanel close];
}

- (void)_deleteBookmarkSheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
	
	if (returnCode == NSAlertDefaultReturn)
	{		
		[[ITAddressBookMgr sharedInstance] deleteBookmarkNode: [bookmarksView itemAtRow: [bookmarksView selectedRow]]];
        id prefs = [NSUserDefaults standardUserDefaults];
        [prefs setObject: [[ITAddressBookMgr sharedInstance] bookmarks] forKey: @"Bookmarks"];
        [prefs synchronize];
	}
    
	[sheet close];
}

- (void)_editBookmarkSheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
	NSMutableDictionary *aDict;
	TreeNode *targetNode;
	int selectedRow;
	NSString *aName, *aCmd, *shortcut;
	
	if (returnCode == NSOKButton)
	{
		aName = [bookmarkName stringValue];
		aCmd = [bookmarkCommand stringValue];
		
		if ([aName length] <= 0)
		{
			NSBeep();
			[editBookmarkPanel close];
			return;
		}
		if ([aCmd length] <= 0)
		{
			NSBeep();
			[editBookmarkPanel close];
			return;
		}

		aDict = [[NSMutableDictionary alloc] init];
		
		[aDict setObject: [bookmarkName stringValue] forKey: KEY_NAME];
		[aDict setObject: [bookmarkCommand stringValue] forKey: KEY_DESCRIPTION];
		[aDict setObject: [bookmarkCommand stringValue] forKey: KEY_COMMAND];
		[aDict setObject: [bookmarkWorkingDirectory stringValue] forKey: KEY_WORKING_DIRECTORY];
		[aDict setObject: [bookmarkTerminalProfile titleOfSelectedItem] forKey: KEY_TERMINAL_PROFILE];
		[aDict setObject: [bookmarkKeyboardProfile titleOfSelectedItem] forKey: KEY_KEYBOARD_PROFILE];
		[aDict setObject: [bookmarkDisplayProfile titleOfSelectedItem] forKey: KEY_DISPLAY_PROFILE];
		shortcut = [bookmarkShortcut titleOfSelectedItem];
		if ([shortcut length] <= 0)
			shortcut = @"";
		[aDict setObject: shortcut forKey: KEY_SHORTCUT];
		
		selectedRow = [bookmarksView selectedRow];
		
		// if no row is selected, new node is child of root
		if (selectedRow == -1)
			targetNode = nil;
		else
			targetNode = [bookmarksView itemAtRow: selectedRow];
		
		// If a leaf node is selected, make new node its sibling
		if ([bookmarksView isExpandable: targetNode] == NO && !editingBookmark)
			targetNode = [targetNode nodeParent];
		
		if (editingBookmark == NO)
			[[ITAddressBookMgr sharedInstance] addBookmarkWithData: aDict toNode: targetNode];
		else
		{
			[aDict setObject: [[ITAddressBookMgr sharedInstance] objectForKey: KEY_DESCRIPTION inItem: targetNode] forKey: KEY_DESCRIPTION];
			[[ITAddressBookMgr sharedInstance] setBookmarkWithData: aDict forNode: targetNode];
		}
        
		[aDict release];
	}
	
    id prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject: [[ITAddressBookMgr sharedInstance] bookmarks] forKey: @"Bookmarks"];
    [prefs synchronize];
    
	[editBookmarkPanel close];
}

- (NSArray *) _selectedNodes 
{ 
    NSMutableArray *items = [NSMutableArray array];
    NSIndexSet* indexes = [bookmarksView selectedRowIndexes];
	NSUInteger index;
	
	index = [indexes firstIndex];
    while (index != NSNotFound) 
	{
        if ([bookmarksView itemAtRow:index]) 
            [items addObject: [bookmarksView itemAtRow:index]];
		
		index = [indexes indexGreaterThanIndex:index];
    }
    return items;
}


- (NSArray*) _draggedNodes   
{ 
	return draggedNodes; 
}

- (void)_performDropOperation:(id <NSDraggingInfo>)info onNode:(TreeNode*)parentNode atIndex:(int)childIndex 
{
    // Helper method to insert dropped data into the model. 
    NSPasteboard * pboard = [info draggingPasteboard];
    
    // Do the appropriate thing depending on wether the data is DragDropSimplePboardType or NSStringPboardType.
    if ([pboard availableTypeFromArray:[NSArray arrayWithObjects:iTermOutlineViewPboardType, nil]] != nil) {
        iTermBookmarkController *dragDataSource = (iTermBookmarkController*) [[info draggingSource] dataSource];
        NSArray *theDraggedNodes = [TreeNode minimumNodeCoverFromNodesInArray: [dragDataSource _draggedNodes]];
        NSEnumerator *draggedNodesEnum = [theDraggedNodes objectEnumerator];
        TreeNode *_draggedNode = nil, *_draggedNodeParent = nil;
        		
        while ((_draggedNode = [draggedNodesEnum nextObject])) {
            _draggedNodeParent = [_draggedNode nodeParent];
            if (parentNode==_draggedNodeParent && [parentNode indexOfChild: _draggedNode]<childIndex) childIndex--;
            [_draggedNodeParent removeChild: _draggedNode];
        }
        [parentNode insertChildren: theDraggedNodes atIndex: childIndex];
    } 
	
	[bookmarksView reloadData];
	
    id prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject: [[ITAddressBookMgr sharedInstance] bookmarks] forKey: @"Bookmarks"];
    [prefs synchronize];
    
	// Post a notification for all listeners that bookmarks have changed
	[[NSNotificationCenter defaultCenter] postNotificationName: @"iTermReloadAddressBook" object: nil userInfo: nil];    		
    
}

- (void)_reloadAddressBook: (NSNotification *) aNotification
{
	[bookmarksView reloadData];
}

- (void)_loadProfiles
{
	NSArray *profileArray;
	
	profileArray = [[[iTermTerminalProfileMgr singleInstance] profiles] allKeys];
	[bookmarkTerminalProfile removeAllItems];
	[bookmarkTerminalProfile addItemsWithTitles: profileArray];
	[bookmarkTerminalProfile selectItemWithTitle: [[iTermTerminalProfileMgr singleInstance] defaultProfileName]];
	
	profileArray = [[[iTermKeyBindingMgr singleInstance] profiles] allKeys];
	[bookmarkKeyboardProfile removeAllItems];
	[bookmarkKeyboardProfile addItemsWithTitles: profileArray];
	[bookmarkKeyboardProfile selectItemWithTitle: [[iTermKeyBindingMgr singleInstance] globalProfileName]];
	
	profileArray = [[[iTermDisplayProfileMgr singleInstance] profiles] allKeys];
	[bookmarkDisplayProfile removeAllItems];
	[bookmarkDisplayProfile addItemsWithTitles: profileArray];
	[bookmarkDisplayProfile selectItemWithTitle: [[iTermDisplayProfileMgr singleInstance] defaultProfileName]];
	
	[bookmarkShortcut selectItemWithTitle: @""];
}


@end
