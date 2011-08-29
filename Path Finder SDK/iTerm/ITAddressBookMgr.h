/*
 **  ITAddressBookMgr.h
 **
 **  Copyright (c) 2002, 2003
 **
 **  Author: Fabian, Ujwal S. Setlur
 **
 **  Project: iTerm
 **
 **  Description: keeps track of the address book data.
 **
 */

#import <Foundation/Foundation.h>

#define KEY_CHILDREN					@"Children"
#define KEY_NAME						@"Name"
#define KEY_DESCRIPTION					@"Description"
#define KEY_COMMAND						@"Command"
#define KEY_WORKING_DIRECTORY			@"Working Directory"
#define KEY_TERMINAL_PROFILE			@"Terminal Profile"
#define KEY_KEYBOARD_PROFILE			@"Keyboard Profile"
#define KEY_DISPLAY_PROFILE				@"Display Profile"
#define KEY_SHORTCUT					@"Shortcut"
#define KEY_DEFAULT_BOOKMARK			@"Default Bookmark"
#define KEY_BONJOUR_GROUP			@"Bonjour Group"
#define KEY_BONJOUR_SERVICE			@"Bonjour Service"
#define KEY_BONJOUR_SERVICE_ADDRESS  @"Bonjour Service Address"


@class TreeNode;

@interface ITAddressBookMgr : NSObject <NSNetServiceDelegate, NSNetServiceBrowserDelegate>
{
	TreeNode *bookmarks;
	NSNetServiceBrowser *sshBonjourBrowser;
	NSNetServiceBrowser *ftpBonjourBrowser;
	NSNetServiceBrowser *telnetBonjourBrowser;
	TreeNode *bonjourGroup;
	NSMutableArray *bonjourServices;
}

+ (id)sharedInstance;

- (void)setBookmarks: (NSDictionary *) aDict;
- (NSDictionary *) bookmarks;
- (void)locateBonjourServices;
- (void)migrateOldBookmarks;

// Model for NSOutlineView tree structure
- (id)child:(NSInteger)index ofItem:(id)item;
- (BOOL) isExpandable:(id)item;
- (NSInteger) numberOfChildrenOfItem:(id)item;
- (id)objectForKey:(id)key inItem:(id)item;
- (void)setObjectValue:(id)object forKey:(id)key inItem:(id)item;
- (void)addFolder: (NSString *) folderName toNode: (TreeNode *) aNode;
- (void)addBookmarkWithData: (NSDictionary *) data toNode: (TreeNode *) aNode;
- (void)setBookmarkWithData: (NSDictionary *) data forNode: (TreeNode *) aNode;
- (void)deleteBookmarkNode: (TreeNode *) aNode;
- (BOOL) mayDeleteBookmarkNode: (TreeNode *) aNode;
- (TreeNode *) rootNode;

- (TreeNode *) defaultBookmark;
- (void)setDefaultBookmark: (TreeNode *) aNode;
- (NSDictionary *) defaultBookmarkData;
- (NSDictionary *) dataForBookmarkWithName: (NSString *) bookmarkName;

- (NSInteger) indexForBookmark: (NSDictionary *)bookmark;
- (NSDictionary *) bookmarkForIndex: (NSInteger)index;

@end

@interface ITAddressBookMgr (Private)

- (BOOL) _checkForDefaultBookmark: (TreeNode *) rootNode defaultBookmark: (TreeNode **)defaultBookmark;
- (TreeNode *) _getBookmarkNodeWithName: (NSString *) aName searchFromNode: (TreeNode *) aNode;
- (TreeNode *) _getBonjourServiceTypeNode: (NSString *) aType;

@end
