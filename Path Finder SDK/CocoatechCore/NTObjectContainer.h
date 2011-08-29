//
//  NTObjectContainer.h
//  CocoatechCore
//
//  Created by Steve Gehrman on 3/31/09.
//  Copyright 2009 Cocoatech. All rights reserved.
//

#import "NTBaseContainer.h"

@interface NTObjectContainer : NTBaseContainer
{
	id* objects;
}

- (id)initWithCap:(UInt8)capacity mapCap:(UInt8)mapCapacity;

- (id)objAtIndex:(UInt8)theIndex;
- (void)setObj:(id)theObject atIndex:(UInt8)theIndex;

@end
