//
//  NTUInt64Container.h
//  CocoatechCore
//
//  Created by Steve Gehrman on 3/31/09.
//  Copyright 2009 Cocoatech. All rights reserved.
//

#import "NTBaseContainer.h"

@interface NTUInt64Container : NTBaseContainer
{
	UInt64* ints;
}

- (id)initWithCap:(UInt8)capacity mapCap:(UInt8)mapCapacity;

- (UInt64)intAtIndex:(UInt8)theIndex;
- (void)setInt:(UInt64)theInt atIndex:(UInt8)theIndex;

@end
