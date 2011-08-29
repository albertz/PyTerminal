//
//  NTUInt32Container.h
//  CocoatechCore
//
//  Created by Steve Gehrman on 3/31/09.
//  Copyright 2009 Cocoatech. All rights reserved.
//

#import "NTBaseContainer.h"

@interface NTUInt32Container : NTBaseContainer
{
	UInt32* ints;
}

- (id)initWithCap:(UInt8)capacity mapCap:(UInt8)mapCapacity;

- (UInt32)intAtIndex:(UInt8)theIndex;
- (void)setInt:(UInt32)theInt atIndex:(UInt8)theIndex;

@end
