//
//  NTPointerObject.h
//  CocoatechCore
//
//  Created by Steve Gehrman on 9/23/08.
//  Copyright 2008 Cocoatech. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NTPointerObject : NSObject {
	void* pointer;
}

+ (NTPointerObject*)object:(void*)pointer;

@property (assign) void* pointer;

@end
