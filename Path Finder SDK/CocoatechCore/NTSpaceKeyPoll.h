//
//  NTSpaceKeyPoll.h
//  CocoatechCore
//
//  Created by Steve Gehrman on 5/18/08.
//  Copyright 2008 Cocoatech. All rights reserved.
//

#import "NTSimpleTimer.h"

@class NTSpaceKeyPoll;

@protocol NTSpaceKeyPollDelegate <NSObject>
- (void)spaceKeyDown:(NTSpaceKeyPoll*)spaceKeyPoll;
@end

@interface NTSpaceKeyPoll : NSObject 
{
	id <NTSpaceKeyPollDelegate> delegate;
	BOOL spaceDown;
	NTSimpleTimer* timer;
	NSUInteger timerCount;
	
	NSDate* startDate;  // safety, if we are running longer than x seconds, just kill us, maybe it wasn't stopped properly
}

@property (assign) id <NTSpaceKeyPollDelegate> delegate;  // not retained, must clear
@property (assign) BOOL spaceDown;
@property (assign) NSUInteger timerCount;
@property (retain) NTSimpleTimer* timer;
@property (retain) NSDate* startDate;

+ (NTSpaceKeyPoll*)poll:(id<NTSpaceKeyPollDelegate>)theDelegate;

- (void)start;
- (void)stop;

@end
