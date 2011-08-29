//
//  NTViewLocalizer.m
//  CocoatechStrings
//
//  Created by Steve Gehrman on Sun Mar 09 2003.
//  Copyright (c) 2003 Cocoatech. All rights reserved.
//

#import "NTViewLocalizer.h"
#import "NSButton-Extensions.h"
#import "NTLocalizedString.h"

@interface NTViewLocalizer (Private)
- (NSString*)localizedString:(NSString*)string;
- (void)localizeWindow:(NSWindow*)window;
- (void)localizeView:(NSView*)view;
@end

@implementation NTViewLocalizer

- (id)initWithTable:(NSString*)table bundle:(NSBundle*)bundle
{
    self = [super init];

    _table = [table retain];
    _bundle = [bundle retain];
    
    return self;
}

- (void)dealloc;
{
    [_table release];
    [_bundle release];
    [super dealloc];
}

+ (void)localizeWindow:(NSWindow*)window table:(NSString*)table bundle:(NSBundle*)bundle;
{
    NTViewLocalizer* localizer = [[[NTViewLocalizer alloc] initWithTable:table bundle:bundle] autorelease];

    [localizer localizeWindow:window];
}

+ (void)localizeView:(NSView*)view table:(NSString*)table bundle:(NSBundle*)bundle;
{
    NTViewLocalizer* localizer = [[[NTViewLocalizer alloc] initWithTable:table bundle:bundle] autorelease];

    [localizer localizeView:view];    
}

@end

@implementation NTViewLocalizer (Private)

- (void)localizeWindow:(NSWindow*)window;
{
    // localize window title
    NSString *windowTitle = [self localizedString:[window title]];
    if (windowTitle)
        [window setTitle:windowTitle];

    // localize window contentView
    [self localizeView:[window contentView]];
}

- (void)localizeView:(NSView*)inView;
{
    NSArray* items;
    NSInteger i, cnt;
    NSTabViewItem* tabViewItem;
    id view = inView; // just to avoid compiler warnings
    
    if ([view isKindOfClass:[NSButton class]])
    {
        if ([view isKindOfClass:[NSPopUpButton class]])
        {
            // localize the menu items
            NSMenu *menu = [view menu];
            NSEnumerator *enumerator = [[menu itemArray] objectEnumerator];
            NSMenuItem* item;
            
            while (item = [enumerator nextObject])
                [item setTitle:[self localizedString:[item title]]];
        }
        else
        {
            [view setTitle:[self localizedString:[view title]]];
            [view setAlternateTitle:[self localizedString:[view alternateTitle]]];
            
            // resize to fit if a checkbox
            if ([view isSwitchButton])
                [view sizeToFit];
        }
    }
    else if ([view isKindOfClass:[NSBox class]])
    {
        [view setTitle:[self localizedString:[view title]]];
    }
    else if ([view isKindOfClass:[NSMatrix class]])
    {
        NSCell* cell;
        
        // localize permission matrix
        items = [view cells];
        
        cnt = [items count];
        for (i=0;i<cnt;i++)
        {
            cell = [items objectAtIndex:i];
            [cell setTitle:[self localizedString:[cell title]]];
            
			// localize place holder string
			if ([cell isKindOfClass:[NSTextFieldCell class]])
				[(NSTextFieldCell*)cell setPlaceholderString:[self localizedString:[(NSTextFieldCell*)cell placeholderString]]];

            if ([cell isKindOfClass:[NSButtonCell class]])
                [(NSButtonCell*)cell setAlternateTitle:[self localizedString:[(NSButtonCell*)cell alternateTitle]]];
        }
        
        // matrix needs to be resized when the strings are changed
        [view setValidateSize:NO];
    }
    else if ([view isKindOfClass:[NSTabView class]])
    {
        // localize the tabs
        items = [view tabViewItems];
        
        cnt = [items count];
        for (i=0;i<cnt;i++)
        {
            tabViewItem = [items objectAtIndex:i];
            [tabViewItem setLabel:[self localizedString:[tabViewItem label]]];
            
            [self localizeView:[tabViewItem view]];
        }
    }
    else if ([view isKindOfClass:[NSTextView class]])
	{
		NSString *oldString = [view string];
		if ([oldString length])
		{
			// this doesn't work for multi styled text			
			NSString* localizedString = [self localizedString:oldString];
			if (![localizedString isEqualToString:oldString])
				[view replaceCharactersInRange:NSMakeRange(0, [oldString length]) withString:localizedString];
		}
	}
	else if ([view isKindOfClass:[NSTextField class]])
    {
		// we really need a hasAttributedString call.  This always creates one even if unnecessary
		NSDictionary *attributes = nil;
		if ([[view attributedStringValue] length])
			attributes = [[view attributedStringValue] attributesAtIndex:0 effectiveRange:nil];
			
        // handles NSTextFields and other non button NSControls
		[view setStringValue:[self localizedString:[view stringValue]]];
		
        // must also set the attributedString, if it exists, we don't want to wipe out attributes
		if (attributes)
		{			
			[view setAttributedStringValue:[[[NSAttributedString alloc] initWithString:[view stringValue] // already localized above
																		 attributes:attributes] autorelease]];
		}
		
        // localize place holder string
        [[view cell] setPlaceholderString:[self localizedString:[[view cell] placeholderString]]];
    }
    else if ([view isKindOfClass:[NSTableView class]])
    {
        NSTableColumn *column;
        items = [view tableColumns];
        
        cnt = [items count];
        for (i=0;i<cnt;i++)
        {
            column = [items objectAtIndex:i];
            
            if (column)
                [[column headerCell] setStringValue:[self localizedString:[[column headerCell] stringValue]]];
        }
    }
    
    // localize any tooltip
    [view setToolTip:[self localizedString:[view toolTip]]];
    
    // if has subviews, localize them too
    if ([[view subviews] count])
    {
        NSEnumerator* enumerator = [[view subviews] objectEnumerator];
        
        while (view = [enumerator nextObject])
            [self localizeView:view];
    }
}

- (NSString*)localizedString:(NSString*)str;
{
	return [NTLocalizedString localize:str table:_table bundle:_bundle];
}

@end
