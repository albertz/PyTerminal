//
//  NSTabView-NTExtensions.h
//  CocoatechCore
//
//  Created by Steve Gehrman on 7/26/04.
//  Copyright 2004 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSTabView (NTExtensions)

- (NSTabViewItem*)tabViewItemWithIdentifier:(id)identifier;
+ (NSNumber*)uniqueTabItemIdentifier;

    // NSNotFound if not found
- (NSInteger)indexOfSelectedTabViewItem;

@end
