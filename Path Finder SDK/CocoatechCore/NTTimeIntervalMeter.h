//
//  NTTimeIntervalMeter.h
//  CocoatechCore
//
//  Created by Steve Gehrman on 1/23/09.
//  Copyright 2009 Cocoatech. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NTTimeIntervalMeter : NSObject {
	NSUInteger successiveCount;
	
	// private
	NSTimeInterval successiveInterval;
	NSTimeInterval lastTime;
}

@property (assign) NSUInteger successiveCount;  // how many successive events within successiveInterval

+ (NTTimeIntervalMeter*)meter:(NSTimeInterval)successiveInterval;

- (NSTimeInterval)update;
@end
