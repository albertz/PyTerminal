//
//  NTSingletonObject.h
//  CocoatechCore
//
//  Created by Steve Gehrman on 6/28/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

// subclasses must put this in their implementation to provide static storage for their shared variable
// NTSINGLETON_INITIALIZE;
// NTSINGLETONOBJECT_STORAGE;

#define NTSINGLETONOBJECT_STORAGE + (id*)staticStorageVariable { static id storage = nil; return &storage; }

#define NTSINGLETON_INITIALIZE + (void)initialize { NTINITIALIZE; [self sharedInstance]; }

@interface NTSingletonObject : NSObject 
{
	BOOL activeSingleton;
}

+ (id)sharedInstance;
+ (void)releaseSharedInstance;

@end

