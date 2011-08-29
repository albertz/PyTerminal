/*
**  ITViewLocalizer.m
 **
 **  Copyright (c) 2002, 2003
 **
 **  Author: Fabian, Ujwal S. Setlur
 **	     Initial code by Kiichi Kusama
 **
 **  Project: iTerm
 **
 **  Description: localizes a view.
 **
 */

#import "ITViewLocalizer.h"

@interface ITViewLocalizer (Private)
- (NSString*)localizedString:(NSString*)string;
- (void)localizeWindow:(NSWindow*)window;
- (void)localizeView:(NSView*)view;
@end

@interface NSButtonCell (UndocumentedRoutine)
- (NSButtonType)_buttonType;
@end

@implementation ITViewLocalizer

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
    ITViewLocalizer* localizer = [[[ITViewLocalizer alloc] initWithTable:table bundle:bundle] autorelease];
    
    [localizer localizeWindow:window];
}

+ (void)localizeView:(NSView*)view table:(NSString*)table bundle:(NSBundle*)bundle;
{
    ITViewLocalizer* localizer = [[[ITViewLocalizer alloc] initWithTable:table bundle:bundle] autorelease];
    
    [localizer localizeView:view];    
}

@end

@implementation ITViewLocalizer (Private)

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
    NSArray *subviews = [inView subviews];
    int x, xcnt = [subviews count];
    
    for (x=0;x<xcnt;x++)
    {
        id view = [subviews objectAtIndex:x];
        NSArray* items;
        int i, cnt;
        NSTabViewItem* tabViewItem;
        
        if ([view isKindOfClass:[NSButton class]])
        {
            [view setTitle:[self localizedString:[view title]]];
            [view setAlternateTitle:[self localizedString:[view alternateTitle]]];
            
            // resize to fit if a checkbox
            {
                NSButtonCell* cell = [view cell];
                
                if ([cell respondsToSelector:@selector(_buttonType)])
                {
                    if ([cell _buttonType] == NSSwitchButton)
                        [view sizeToFit];
                }
            }
        }
        else if ([view isKindOfClass:[NSBox class]])
        {
            [view setTitle:[self localizedString:[view title]]];
        }
        else if ([view isKindOfClass:[NSMatrix class]])
        {
            NSButtonCell* cell;
            
            // localize permission matrix
            items = [view cells];
            
            cnt = [items count];
            for (i=0;i<cnt;i++)
            {
                cell = [items objectAtIndex:i];
                [cell setTitle:[self localizedString:[cell title]]];
                
                if ([cell isKindOfClass:[NSButtonCell class]])
                    [cell setAlternateTitle:[self localizedString:[cell alternateTitle]]];
            }
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
        else if ([view isKindOfClass:[NSTextField class]])
        {
            // handles NSTextFields and other non button NSControls
            [view setStringValue:[self localizedString:[view stringValue]]];
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
            [self localizeView:view];
    }
}

- (NSString*)localizedString:(NSString*)string;
{
    if ([string length])
        return NTLocalizedStringFromTableInBundle(string, _table, _bundle, @"");
    
    return string;
}

@end
