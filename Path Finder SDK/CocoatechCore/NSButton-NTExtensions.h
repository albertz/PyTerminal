//
//  NSButton-NTExtensions.h
//  CocoatechCore
//
//  Created by Steve Gehrman on Thu Mar 27 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSButton (NTExtensions)
- (BOOL)isSwitchButton;
@end

@interface NSButtonCell (NTExtensions)
- (BOOL)isSwitchButtonCell;
@end