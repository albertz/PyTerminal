//
//  NSNumber-NTExtensions.m
//  CocoatechCore
//
//  Created by Steve Gehrman on Thu Mar 06 2003.
//  Copyright (c) 2003 CocoaTech. All rights reserved.
//

#import "NSNumber-NTExtensions.h"

@implementation NSNumber (NTExtensions)

+ (NSNumber*)numberWithSize:(NSSize)size;
{
    NSInteger x = size.width;

    x = x<<16;
    x += size.height;

    return [NSNumber numberWithUnsignedInteger:x];
}

- (NSSize)sizeNumber;
{
    NSSize size;
    NSInteger x = [self unsignedIntegerValue];

    size.height = x & 0x0000FFFF;
    x = x>>16;
    size.width = x;

    return size;
}

// a unique NSNumber
+ (NSNumber*)unique;
{
	static NSUInteger counter=1;  // protected for thread safety
	NSUInteger intValue;
	
	@synchronized(self) {
		intValue = counter++;
	}
	
	return [NSNumber numberWithUnsignedInteger:intValue];
}

@end
