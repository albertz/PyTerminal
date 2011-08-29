//
//  NTQuitDisabler.m
//  CocoaTechBase
//
//  Created by Steve Gehrman on Fri Dec 21 2001.
//  Copyright (c) 2001 CocoaTech. All rights reserved.
//

#import "NTQuitDisabler.h"

@interface NTQuitDisabler ()
@property (nonatomic, assign) NSInteger count;
@end

@implementation NTQuitDisabler

NTSINGLETON_INITIALIZE;
NTSINGLETONOBJECT_STORAGE;

@synthesize count;

// caller must balance the two calls or the program will never quit
- (void)dontQuit;
{
	@synchronized(self) {
		self.count += 1;
		
		[[NSProcessInfo processInfo] disableSuddenTermination];
	}
}

- (void)allowQuit;
{
	@synchronized(self) {
		self.count -= 1;
		
		[[NSProcessInfo processInfo] enableSuddenTermination];
	}
}

- (BOOL)canQuit;
{
    BOOL result;
	
	@synchronized(self) {
		result = (self.count == 0);
	}
	
    return result;
}

@end
