//
//  NSMenu-NTExtensions.h
//  CocoatechCore
//
//  Created by Steve Gehrman on Sun Feb 29 2004.
//  Copyright (c) 2004 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMenu (NTExtensions)
- (void)popupMenuBelowRect:(NSRect)rect inView:(NSView*)controlView;
- (void)popupMenuBelowRect:(NSRect)rect inView:(NSView*)controlView centerMenu:(BOOL)centerMenu;
- (void)popUpContextMenu:(NSEvent*)event forView:(NSView*)view;
- (void)popUpContextMenu:(NSEvent*)event forView:(NSView*)view withFont:(NSFont*)withFont;
- (void)popUpContextMenu:(NSEvent*)event forView:(NSView*)view withFont:(NSFont*)withFont contextualMenuSelectionSet:(BOOL)contextualMenuSelectionSet;
- (void)setCMPluginAEDesc:(const struct AEDesc *)theDesc;

- (void)setIndentationLevel:(NSInteger)indentationLevel;
- (void)appendMenu:(NSMenu*)menu;
- (void)appendMenu:(NSMenu*)menu fontSize:(NSInteger)fontSize;

// recursively set all menuItems to size and color
- (void)setFontSize:(NSInteger)fontSize color:(NSColor*)color;

- (void)cleanSeparators;  // remove unnecessary separators

- (void)removeItemsInRange:(NSRange)range;

+ (void)copyMenuItemsFrom:(NSMenu*)newMenu toMenu:(NSMenu*)menu;

// keys are the paths to a menu, and object is array of NSMenuItem objects
+ (NSDictionary*)menuDictionary:(NSMenu*)menu;  // includeSubmenus:YES
+ (NSDictionary*)menuDictionary:(NSMenu*)menu includeSubmenus:(BOOL)includeSubmenus;

+ (NSArray*)everyItemInMenu:(NSMenu*)menu;  // uses above, but just strips out the items in a big array

- (NSArray*)itemsWithTag:(NSInteger)tag;

+ (NSMenuItem*)itemWithTag:(NSInteger)tag menu:(NSMenu*)menu;
+ (NSMenuItem*)itemWithAction:(SEL)action menu:(NSMenu*)menu;
+ (NSMenuItem*)itemWithKeyEquivalent:(NSString*)key modifiersMask:(NSUInteger)modifiersMask menu:(NSMenu*)menu;
+ (NSMenuItem*)itemWithSubmenu:(NSMenu*)inMenu menu:(NSMenu*)menu;
+ (NSMenuItem*)itemWithPath:(NSString*)path;

+ (void)removeAllItemsBelowTag:(NSInteger)tag;
- (void)removeAllItemsBelowTag:(NSInteger)tag;
- (void)removeAllItemsBelowItem:(NSMenuItem*)item;
- (void)removeAllItemsAfterIndex:(NSUInteger)index;

- (void)setRepresentedObjectForItems:(id)theRepresentedObject;

// returns a 16,12 image with the color passed in
+ (NSImage*)menuColorImage:(NSColor*)color;

	// update doesn't update submenus, so we created updateAll
- (void)updateAll;

- (void)selectItemWithTag:(NSInteger)tag;

+ (NSDictionary*)infoAttributes:(CGFloat)fontSize;

- (NSMenuItem*)parentItem;
- (NSString*)path;

- (void)addItems:(NSArray*)items;
- (void)insertItems:(NSArray*)items atIndex:(NSInteger)index;
@end

// ---------------------------------------------------------------------------------

// MENU_DISABLE(menu);
// {
// }
// MENU_ENABLE(menu);

#define MENU_DISABLE(menu) \
BOOL restoreBuildMenu = NO; \
if ([menu menuChangedMessagesEnabled]) { \
restoreBuildMenu = YES; [menu setMenuChangedMessagesEnabled:NO]; \
}

#define MENU_ENABLE(menu) \
if (restoreBuildMenu) \
[menu setMenuChangedMessagesEnabled:YES];




