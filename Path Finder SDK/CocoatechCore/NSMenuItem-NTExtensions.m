//
//  NSMenuItem-NTExtensions.m
//  CocoatechCore
//
//  Created by Steve Gehrman on Fri Jun 11 2004.
//  Copyright (c) 2004 __MyCompanyName__. All rights reserved.
//

#import "NSMenuItem-NTExtensions.h"

@implementation NSMenuItem (NTExtensions)

- (void)resetFontToDefault;
{
	[self setAttributedTitle:nil];
}

- (void)setFontSize:(NSInteger)fontSize color:(NSColor*)color;
{
	// this adds an attributed title to the menuItem.  One side effect is that controls that will set the menuSize based on it's controlSize will not use the correct size
	// there was some reason I decided to add the attributed title to every item rather that testing if the color and size where not defaults, can't remember at the moment why
	NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
	
	if (fontSize > 0)
		[attributes setObject:[NSFont menuFontOfSize:fontSize] forKey:NSFontAttributeName];
	else
		[attributes setObject:[[self class] defaultMenuItemFont] forKey:NSFontAttributeName];
		
	// shapeshifter fix.  May not be needed in future versions of SS
	if (!color)
		color = [NSColor controlTextColor];

	// don't set unless it's custom.  If we set to black, we don't get the disabled gray state color
	if (color)
		[attributes setObject:color forKey:NSForegroundColorAttributeName];

	[self setAttributedTitle:[[[NSAttributedString alloc] initWithString:[self title] attributes:attributes] autorelease]];
}

+ (NSFont*)defaultMenuItemFont;
{
	static NSFont *shared = nil;
	
	// [NSFont menuFontOfSize:0] used for popups, need to use that in that case
	if (!shared)
		shared = [[NSFont menuBarFontOfSize:0] retain]; // zero is default, but doesn't work, should be 14
	
	return shared;
}

- (BOOL)inMenuBar;
{
	NSMenu* theMenu = [self menu];
    
    while (theMenu)
    {
		if (theMenu == [NSApp mainMenu])
			return YES;
		
		theMenu = [theMenu supermenu];
    }	
	
	return NO;
}

- (NSString*)path;
{
    NSMutableArray* components = [NSMutableArray array];
    NSMenuItem* parentItem=self;
    
    while (parentItem)
    {
        NSString *title = [parentItem title];
        
        if (![title length])
            title = @"/";
        
        [components insertObject:title atIndex:0];
        
        parentItem = [parentItem parentItem];
    }
    
    return [NSString pathWithComponents:components];
}

+ (NSInteger)menuFontSize;
{
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"NTUseSmallFontForContextualMenuPrefKey"])
		return kSmallMenuFontSize;
	
	return kDefaultMenuFontSize;
}

- (NSComparisonResult)compareTitle:(NSMenuItem*)rightItem;
{
	NSString* left = [self title];
	NSString* right = [rightItem title];
	
	if (!left)
		left = [[self attributedTitle] string];
	if (!right)
		right = [[rightItem attributedTitle] string];	
	
	return [left compare:right options:NSCaseInsensitiveSearch];
}

@end
