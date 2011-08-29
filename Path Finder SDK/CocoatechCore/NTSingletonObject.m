//
//  NTSingletonObject.m
//  CocoatechCore
//
//  Created by Steve Gehrman on 6/28/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "NTSingletonObject.h"

@interface NTSingletonObject ()
@property (nonatomic, assign) BOOL activeSingleton;
@end

@implementation NTSingletonObject

@synthesize activeSingleton;

// subclasses must implement to provide static storage
+ (id*)staticStorageVariable;
{
	[NSException raise:@"class must implement staticStorageVariable" format:@"%@", NSStringFromClass([self class])];
	return nil;
}

+ (id)sharedInstance;
{
	id result;

    @synchronized(self) {
		id *storageRef = [self staticStorageVariable];
		
        if ((*storageRef) == nil) {
			NTSingletonObject* theSingleton = [[self alloc] init];
			theSingleton.activeSingleton = YES;
			
			*storageRef = theSingleton;
        }
		
		result = *storageRef;
    }
	
    return result;
}

+ (void)releaseSharedInstance;
{
	@synchronized(self) {
		NTSingletonObject* theSingleton = *[self staticStorageVariable];
		
        if (theSingleton != nil) {
			theSingleton.activeSingleton = NO;  // allows us to be released
			[theSingleton release];
			
			// set back to nil;
			theSingleton = nil;
        }
	}
}

- (oneway void)release;
{
	if ([self retainCount] == 1)
	{
		if (self.activeSingleton)
		{
			NSLog(@"%@ : I'm a singleton damnit!", NSStringFromClass([self class]));
			return;
		}
	}
	
	[super release];
}

@end

