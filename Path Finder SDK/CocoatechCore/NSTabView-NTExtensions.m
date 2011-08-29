//
//  NSTabView-NTExtensions.m
//  CocoatechCore
//
//  Created by Steve Gehrman on 7/26/04.
//  Copyright 2004 __MyCompanyName__. All rights reserved.
//

#import "NSTabView-NTExtensions.h"

@implementation NSTabView (NTExtensions)

- (NSTabViewItem*)tabViewItemWithIdentifier:(id)identifier;
{
    NSInteger index = [self indexOfTabViewItemWithIdentifier:identifier];
    
    if (index != NSNotFound)
        return (NSTabViewItem*) [self tabViewItemAtIndex:index];
    
    return nil;
}

+ (NSNumber*)uniqueTabItemIdentifier;
{
    static NSUInteger uniqueID=1;
    
    return [NSNumber numberWithUnsignedInteger:uniqueID++];
}

// NSNotFound if not found
- (NSInteger)indexOfSelectedTabViewItem;
{
    NSTabViewItem* item = [self selectedTabViewItem];
    
    if (item)
        return [self indexOfTabViewItem:item];

    return NSNotFound;
}

@end
