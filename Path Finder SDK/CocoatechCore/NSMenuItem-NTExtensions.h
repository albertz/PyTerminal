//
//  NSMenuItem-NTExtensions.h
//  CocoatechCore
//
//  Created by Steve Gehrman on Fri Jun 11 2004.
//  Copyright (c) 2004 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

// menu font size
#define kDefaultMenuFontSize 0 // doesn't set the size, just keeps default
#define kSmallMenuFontSize 12
#define kMiniMenuFontSize 9

#define kDefaultMenuIconSize 16
#define kSmallMenuIconSize 13
@interface NSMenuItem (NTExtensions)

- (void)setFontSize:(NSInteger)fontSize color:(NSColor*)color;
- (void)resetFontToDefault;

+ (NSFont*)defaultMenuItemFont;

- (BOOL)inMenuBar;
- (NSString*)path;

+ (NSInteger)menuFontSize;

- (NSComparisonResult)compareTitle:(NSMenuItem*)right;
@end
