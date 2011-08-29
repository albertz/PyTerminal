//
//  NSMenu-NTExtensions.m
//  CocoatechCore
//
//  Created by Steve Gehrman on Sun Feb 29 2004.
//  Copyright (c) 2004 __MyCompanyName__. All rights reserved.
//

#import "NSMenu-NTExtensions.h"
#import "NSMenuItem-NTExtensions.h"
#import "NTImageMaker.h"
#import "NTGeometry.h"
#import "NTUtilities.h"

@interface NSMenu (NTExtensions_Private)
- (void)doPopupMenuBelowRect:(NSRect)rect inView:(NSView*)controlView centerMenu:(BOOL)centerMenu;
+ (void)recursiveHelper:(NSMenu*)menu dictionary:(NSMutableDictionary*)resultDictionary includeSubmenus:(BOOL)includeSubmenus;
+ (void)recursiveHelper:(NSMenu*)menu
			matchingTag:(NSInteger)tag
				  array:(NSMutableArray*)resultArray;

- (void)disableCMPlugins;
- (void)enableCMPlugins;
@end

@interface NSMenu (UndocumentedContextualMenuAdditions)
- (void)_setContextMenuPluginAEDesc:(const struct AEDesc *)arg1;
- (const struct AEDesc *)_contextMenuPluginAEDesc;

// 1 is Services, 2 is CMs, 3 is both (or -1) which is all bits
- (void)_setMenuPluginTypes:(unsigned long long)arg1;
- (unsigned long long)_menuPluginTypes;
@end

@implementation NSMenu (NTExtensions)

// set indentation level of all items in the menu
- (void)setIndentationLevel:(NSInteger)indentationLevel;
{
	NSEnumerator *enumerator = [[self itemArray] objectEnumerator];
	NSMenuItem* menuItem;
	
	while (menuItem = [enumerator nextObject])
		[menuItem setIndentationLevel:indentationLevel];
}

- (void)appendMenu:(NSMenu*)menu;
{	
	for (NSMenuItem *menuItem in [menu itemArray])
	{
		NSMenuItem* newItem = [[menuItem copy] autorelease];
				
		[self addItem:newItem];
	}
}

- (void)cleanSeparators;  // remove unnecessary separators
{
	NSEnumerator *enumerator = [[self itemArray] reverseObjectEnumerator];
	NSMenuItem *menuItem;
	BOOL previousWasSeparator=NO;
	
	while (menuItem = [enumerator nextObject])
	{
		if ([menuItem isSeparatorItem])
		{
			if (previousWasSeparator)
				[self removeItem:menuItem];
			
			previousWasSeparator = YES;
		}
		else
			previousWasSeparator = NO;
	}
	
	// is first item a separator?
	if ([[self itemArray] count])
	{
		menuItem = [[self itemArray] objectAtIndex:0];
		if ([menuItem isSeparatorItem])
			[self removeItem:menuItem];
	}
	
	// is last item a separator?
	if ([[self itemArray] count])
	{
		menuItem = [[self itemArray] objectAtIndex:[[self itemArray] count]-1];
		if ([menuItem isSeparatorItem])
			[self removeItem:menuItem];
	}
}

- (void)appendMenu:(NSMenu*)menu fontSize:(NSInteger)fontSize;
{
	NSEnumerator *enumerator = [[menu itemArray] objectEnumerator];
	NSMenuItem* newItem, *menuItem;
	
	while (menuItem = [enumerator nextObject])
	{
		newItem = [[menuItem copy] autorelease];
		
		[newItem setFontSize:fontSize color:nil];

		[self addItem:newItem];
	}
}

- (void)setFontSize:(NSInteger)fontSize color:(NSColor*)color;
{
	NSEnumerator *enumerator = [[self itemArray] objectEnumerator];
	NSMenuItem *menuItem;
	
	while (menuItem = [enumerator nextObject])
	{		
		[menuItem setFontSize:fontSize color:color];
		
		if ([menuItem submenu])
			[[menuItem submenu] setFontSize:fontSize color:color]; // recursive
	}
}

- (void)removeItemsInRange:(NSRange)range;
{
	NSInteger numItems = [self numberOfItems];
	NSInteger index, cnt = MIN(numItems, NSMaxRange(range));
	NSInteger firstIndex = range.location;
	
	if (cnt)
	{
		for (index=cnt-1; index >= firstIndex; index--)
			[self removeItemAtIndex:index];
	}
}

- (void)popUpContextMenu:(NSEvent*)event forView:(NSView*)view;
{
	[self popUpContextMenu:event forView:view withFont:nil];
}

- (void)popUpContextMenu:(NSEvent*)event forView:(NSView*)view withFont:(NSFont*)withFont;
{
	[self popUpContextMenu:event forView:view withFont:withFont contextualMenuSelectionSet:NO];
}

- (void)popUpContextMenu:(NSEvent*)event forView:(NSView*)view withFont:(NSFont*)withFont contextualMenuSelectionSet:(BOOL)contextualMenuSelectionSet;
{	
	if (![NSApp isActive])
	{
		[NSApp activateIgnoringOtherApps:YES];
		
		// post event again so it happens after the activate of the window
		[NSApp postEvent:event atStart:NO];
	}
	else
	{
		if (!contextualMenuSelectionSet)
			[self disableCMPlugins];
		else
			[self enableCMPlugins];

		[NSMenu popUpContextMenu:self withEvent:event forView:view withFont:withFont];
	}
}

- (void)popupMenuBelowRect:(NSRect)rect inView:(NSView*)controlView;
{
    [self popupMenuBelowRect:rect inView:controlView centerMenu:NO];
}

- (void)popupMenuBelowRect:(NSRect)rect inView:(NSView*)controlView centerMenu:(BOOL)centerMenu;
{
	[self doPopupMenuBelowRect:rect inView:controlView centerMenu:centerMenu];
}

+ (void)copyMenuItemsFrom:(NSMenu*)newMenu toMenu:(NSMenu*)menu;
{
	MENU_DISABLE(menu);
	{	
		[menu removeAllItems];
		
		NSEnumerator *enumerator = [[newMenu itemArray] objectEnumerator];
		NSMenuItem* menuItem;
		
		while (menuItem = [enumerator nextObject])
			[menu addItem:[[menuItem copy] autorelease]];
	}
	MENU_ENABLE(menu);
}

+ (NSMenuItem*)itemWithAction:(SEL)action menu:(NSMenu*)menu;
{
    NSArray* itemArray = [menu itemArray];
    NSMenu* submenu;
    NSMenuItem* result=nil;
    
    for (NSMenuItem *item in itemArray)
    {
        
        submenu = [item submenu];
        if (submenu)
        {
            if (submenu != [NSApp servicesMenu])
                result = [self itemWithAction:action menu:submenu];
        }
        else
        {
            if ([item action] == action)
                result = item;
        }
        
        if (result)
            break;
    }
    
    return result;
}

+ (NSMenuItem*)itemWithKeyEquivalent:(NSString*)key modifiersMask:(NSUInteger)modifiersMask menu:(NSMenu*)menu;
{
	NSArray* itemArray = [menu itemArray];
    NSMenu* submenu;
    NSMenuItem* result=nil;
    
    for (NSMenuItem *item in itemArray)
    {
        
        submenu = [item submenu];
        if (submenu)
        {
            if (submenu != [NSApp servicesMenu])
                result = [self itemWithKeyEquivalent:key modifiersMask:modifiersMask menu:submenu];
        }
        else
        {				
			if (([item keyEquivalentModifierMask] == modifiersMask)
				&& ([[item keyEquivalent] isEqualToString:key]))
				result = item;
        }
        
        if (result)
            break;
    }
    
    return result;	
}

+ (NSMenuItem*)itemWithSubmenu:(NSMenu*)inMenu menu:(NSMenu*)menu;
{
    NSArray* itemArray = [menu itemArray];
    NSMenu* submenu;
    NSMenuItem* result=nil;
    
    for (NSMenuItem *item in itemArray)
    {
        submenu = [item submenu];
        if (submenu)
        {
            if (submenu != [NSApp servicesMenu])
            {
                if (submenu == inMenu)
                    result = item;
                else
                    result = [self itemWithSubmenu:inMenu menu:submenu];
            }
        }
        
        if (result)
            break;
    }
    
    return result;    
}

// returns every menuitem, except those with a submenu
// keys are the paths to a menu, and object is array of NSMenuItem objects
+ (NSDictionary*)menuDictionary:(NSMenu*)menu;
{
	return [self menuDictionary:menu includeSubmenus:YES];
}

+ (NSDictionary*)menuDictionary:(NSMenu*)menu includeSubmenus:(BOOL)includeSubmenus
{
    NSMutableDictionary* result = [NSMutableDictionary dictionary];
    
    [self recursiveHelper:menu dictionary:result includeSubmenus:includeSubmenus];
	
    return result;
}

+ (NSArray*)everyItemInMenu:(NSMenu*)menu;
{
	NSMutableArray* result = [NSMutableArray array];
	
	NSDictionary* dict = [self menuDictionary:menu];
	for (NSArray* items in [dict allValues])
		[result addObjectsFromArray:items];
	
	return result;
}

- (NSArray*)itemsWithTag:(NSInteger)tag;
{
	NSMutableArray* result = [NSMutableArray arrayWithCapacity:50];
    
    [NSMenu recursiveHelper:self matchingTag:tag array:result];
    return result;	
}

+ (void)removeAllItemsBelowTag:(NSInteger)tag
{
    NSMenuItem* rootItem = [self itemWithTag:tag menu:[NSApp mainMenu]];
    NSMenu* itemsMenu = [rootItem menu];
    
    [itemsMenu removeAllItemsBelowTag:tag];
}

- (void)removeAllItemsBelowTag:(NSInteger)tag
{
    NSMenuItem* rootItem = [self itemWithTag:tag];
    
    if (rootItem)
		[self removeAllItemsBelowItem:rootItem];
}

- (void)removeAllItemsBelowItem:(NSMenuItem*)item;
{
	[self removeAllItemsAfterIndex:[self indexOfItem:item]];
}

- (void)removeAllItemsAfterIndex:(NSUInteger)index;
{
	NSInteger i, cnt = [self numberOfItems];
	
	for (i=cnt-1;i>index;i--)
		[self removeItemAtIndex:i];
}

// called recursively on all submenus, start with itemWithTag:[NSApp mainMenu] tag:
+ (NSMenuItem*)itemWithTag:(NSInteger)tag menu:(NSMenu*)menu;
{
    NSMenuItem* result = [menu itemWithTag:tag];
    
    // if not found, search in submenus
    if (!result)
    {
        NSArray* itemArray = [menu itemArray];
        NSMenu* submenu;
        
        for (NSMenuItem *item in itemArray)
        {
            
            submenu = [item submenu];
            if (submenu && (submenu != [NSApp servicesMenu]))
                result = [self itemWithTag:tag menu:submenu];
            
            if (result)
                break;
        }
    }
    
    return result;
}

// update doesn't update submenus, so we created updateAll
- (void)updateAll;
{
	[self update];
	
	NSEnumerator *enumerator = [[self itemArray] objectEnumerator];
	NSMenu* submenu;
	NSMenuItem* menuItem;

	while (menuItem = [enumerator nextObject])
	{		
		submenu = [menuItem submenu];
		if (submenu)
			[submenu updateAll];
	}
}

+ (NSImage*)menuColorImage:(NSColor*)color;
{
	NTImageMaker* maker = [NTImageMaker maker:NSMakeSize(16,12)];

	[maker lockFocus];
	[color set];
	[NSBezierPath fillRect:NSMakeRect(0, 0, 16, 12)];
	[[NSColor grayColor] set];
	NSFrameRect(NSMakeRect(0, 0, 16, 12));
	return [maker unlockFocus];
}

- (void)selectItemWithTag:(NSInteger)tag;
{
	NSMenuItem* selectedItem = [self itemWithTag:tag];
	
	NSEnumerator *enumerator = [[self itemArray] objectEnumerator];
	NSMenuItem* menuItem;
	
	while (menuItem = [enumerator nextObject])
		[menuItem setState:(selectedItem == menuItem) ? NSOnState : NSOffState];
}

+ (NSDictionary*)infoAttributes:(CGFloat)fontSize;
{
	static NSDictionary* sharedDictionary = nil;
	static CGFloat sharedSize = 0;
	
	if (fontSize != sharedSize)
	{
		[sharedDictionary release];
		sharedDictionary = nil;
		
		sharedSize = fontSize;
	}
	
	if (!sharedDictionary)
	{
		NSMutableDictionary* attributes = [NSMutableDictionary dictionary];
		
		[attributes setObject:[NSFont menuFontOfSize:sharedSize] forKey:NSFontAttributeName];
		[attributes setObject:[NSColor grayColor] forKey:NSForegroundColorAttributeName];
		
		sharedDictionary = [[NSDictionary alloc] initWithDictionary:attributes];
	}
	
	return sharedDictionary;
}

- (NSMenuItem*)parentItem;
{
    NSMenu* supermenu = [self supermenu];
    
    if (supermenu)
    {
        NSInteger itemIndex = [supermenu indexOfItemWithSubmenu:self];
		
		if (itemIndex != NSNotFound)
			return (NSMenuItem*)[supermenu itemAtIndex:itemIndex];
    }
    
    return nil;
}

- (NSString*)path;
{
    return [[self parentItem] path];
}

+ (NSMenuItem*)itemWithPath:(NSString*)path;
{
    NSEnumerator* enumerator = [[path pathComponents] objectEnumerator];
    NSString* menuTitle;
    NSMenu* currentMenu = [NSApp mainMenu];
    NSMenuItem* menuItem=nil;
    
    while (menuTitle = [enumerator nextObject])
    {
        if (!currentMenu)
            return nil;
        
        if ([menuTitle isEqualToString:@"/"])
            menuTitle = @"";
        
        menuItem = (NSMenuItem*) [currentMenu itemWithTitle:menuTitle];
        
        if (!menuItem)
            return nil;
        else
            currentMenu = [menuItem submenu];
    }
    
    return menuItem;
}

- (void)addItems:(NSArray*)items;
{
	NSMenuItem* menuItem;
	
	MENU_DISABLE(self);
	{
		for (menuItem in items)
			[self addItem:menuItem];
	}
	MENU_ENABLE(self);
}

- (void)insertItems:(NSArray*)items atIndex:(NSInteger)index;
{
	NSEnumerator* enumerator = [items reverseObjectEnumerator];
	NSMenuItem* menuItem;
	
	MENU_DISABLE(self);
	{
		while (menuItem = [enumerator nextObject])
			[self insertItem:menuItem atIndex:index];
	}
	MENU_ENABLE(self);
}

- (void)setRepresentedObjectForItems:(id)theRepresentedObject
{
	for (NSMenuItem* menuItem in [self itemArray])
	{		
		// only set if nil
		if (![menuItem representedObject])
			[menuItem setRepresentedObject:theRepresentedObject];
		else
			NSLogNULL(@"-[%@ %@] already has representedObject: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), [menuItem title]);
		
		// submenus too
		if ([menuItem submenu])
			[[menuItem submenu] setRepresentedObjectForItems:theRepresentedObject];
	}
}

- (void)setCMPluginAEDesc:(const struct AEDesc *)theDesc;
{
	if ([self respondsToSelector:@selector(_setContextMenuPluginAEDesc:)])
		[self _setContextMenuPluginAEDesc:theDesc]; 
}

@end

@implementation NSMenu (NTExtensions_Private)

enum {
	kNTServicesPluginBitMask = 1 << 0,
	kNTCMPluginBitMask = 1 << 1,
	kNTAllPluginBitMask = -1,
};

- (void)disableCMPlugins;
{	
	if ([self respondsToSelector:@selector(_setMenuPluginTypes:)])
		[self _setMenuPluginTypes:kNTAllPluginBitMask & ~kNTCMPluginBitMask];
}

- (void)enableCMPlugins;
{	
	if ([self respondsToSelector:@selector(_setMenuPluginTypes:)])
		[self _setMenuPluginTypes:kNTAllPluginBitMask];
}

+ (void)recursiveHelper:(NSMenu*)menu dictionary:(NSMutableDictionary*)resultDictionary includeSubmenus:(BOOL)includeSubmenus
{
	NSMutableArray* resultItems = [NSMutableArray array];
	
    for (NSMenuItem *item in [menu itemArray])
    {
        NSMenu* submenu = [item submenu];
        if (submenu && includeSubmenus)
        {
            if (submenu != [NSApp servicesMenu])
                [self recursiveHelper:submenu dictionary:resultDictionary includeSubmenus:includeSubmenus];
        }
        else
            [resultItems addObject:item];
    }
	
	// don't want a nil path
	NSString* path = [menu path];
	if (!path)
		path = @"";
	
	[resultDictionary setObject:resultItems forKey:path];
}

+ (void)recursiveHelper:(NSMenu*)menu 
			matchingTag:(NSInteger)tag
				  array:(NSMutableArray*)resultArray
{
    NSEnumerator* enumerator = [[menu itemArray] objectEnumerator];
	NSMenuItem* item;
    NSMenu* submenu;
    
    while (item = [enumerator nextObject])
    {
		if ([item tag] == tag)
			[resultArray addObject:item];
		
        submenu = [item submenu];
        if (submenu)
        {
            if (submenu != [NSApp servicesMenu])
                [self recursiveHelper:submenu matchingTag:tag array:resultArray];
        }
    }
}

- (void)doPopupMenuBelowRect:(NSRect)rect inView:(NSView*)controlView centerMenu:(BOOL)centerMenu;
{
	NSPoint location = rect.origin;
	
	if ([controlView isFlipped])
		location.y += NSHeight(rect) + 4;
	
	// center the menu
	if (centerMenu)
	{
		NSSize menuSize = [self size];
		if (NSWidth(rect) > menuSize.width)
			location.x += ((NSWidth(rect)/2) - (menuSize.width/2));
	}		
	
	[self popUpMenuPositioningItem:nil atLocation:location inView:controlView];
}

@end





