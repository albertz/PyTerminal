//
//  NTQuitDisabler.h
//  CocoaTechBase
//
//  Created by Steve Gehrman on Fri Dec 21 2001.
//  Copyright (c) 2001 CocoaTech. All rights reserved.
//

#import "NTSingletonObject.h"

@interface NTQuitDisabler : NTSingletonObject
{
    NSInteger count; // when 0 it's OK to quit
}

// caller must balance the two calls or the program will never quit
- (void)dontQuit;
- (void)allowQuit;

- (BOOL)canQuit;

@end
