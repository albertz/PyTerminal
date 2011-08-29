//
//  NSButton-Extensions.h
//  CocoatechStrings
//
//  Created by Steve Gehrman on Thu Mar 27 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSButton (Extensions)
- (BOOL)isSwitchButton;
@end

@interface NSButtonCell (Extensions)
- (BOOL)isSwitchButtonCell;
@end