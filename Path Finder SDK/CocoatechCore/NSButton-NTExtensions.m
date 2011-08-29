//
//  NSButton-NTExtensions.m
//  CocoatechCore
//
//  Created by Steve Gehrman on Thu Mar 27 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import "NSButton-NTExtensions.h"

@interface NSObject (UndocumentedNSButtonCellStuff)
- (NSButtonType)_buttonType;
@end

@implementation NSButton (NTExtensions)

- (BOOL)isSwitchButton;  // I have no idea why this is not public already
{
    NSButtonCell* cell = [self cell];
	
    if ([cell respondsToSelector:@selector(_buttonType)])
        return ([cell _buttonType] == NSSwitchButton);
	
    return NO;
}

@end

@implementation NSButtonCell (NTExtensions)

- (BOOL)isSwitchButtonCell;  // I have no idea why this is not public already
{	
    if ([self respondsToSelector:@selector(_buttonType)])
        return ([self _buttonType] == NSSwitchButton);
	
    return NO;
}

@end
