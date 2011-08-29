//
//  NSButton-Extensions.m
//  CocoatechStrings
//
//  Created by Steve Gehrman on Thu Mar 27 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import "NSButton-Extensions.h"

@interface NSObject (UndocumentedStuff)
- (NSButtonType)_buttonType;
@end

@implementation NSButton (Extensions)

- (BOOL)isSwitchButton;  // I have no idea why this is not public already
{
    NSButtonCell* cell = [self cell];
	
    if ([cell respondsToSelector:@selector(_buttonType)])
        return ([cell _buttonType] == NSSwitchButton);
	
    return NO;
}

@end

@implementation NSButtonCell (Extensions)

- (BOOL)isSwitchButtonCell;  // I have no idea why this is not public already
{	
    if ([self respondsToSelector:@selector(_buttonType)])
        return ([self _buttonType] == NSSwitchButton);
	
    return NO;
}

@end
