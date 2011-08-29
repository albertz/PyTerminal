//
//  NTBaseContainer.h
//  CocoatechCore
//
//  Created by Steve Gehrman on 3/31/09.
//  Copyright 2009 Cocoatech. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NTBaseContainer : NSObject {
	UInt8* indexMap;
	UInt8 indexMapLength;
	UInt8 dataLength;
	UInt8 memoryLength;
}

- (id)initWithMapCap:(UInt8)mapCapacity;

- (void)resizeIndexMap:(UInt8)length;
- (UInt8)updateMappedIndex:(UInt8)theIndex;
- (UInt8)mappedIndex:(UInt8)theIndex;

@end
