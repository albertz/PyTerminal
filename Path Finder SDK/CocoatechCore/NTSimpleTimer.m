//
//  NTSimpleTimer.m
//  CocoatechCore
//
//  Created by sgehrman on Fri Jun 22 2001.
//  Copyright (c) 2001 CocoaTech. All rights reserved.
//

#import "NTSimpleTimer.h"

@interface NTSimpleTimer (Private)
- (void)createNSTimer;

- (id <NTSimpleTimerProtocol>)delegate;
- (void)setDelegate:(id <NTSimpleTimerProtocol>)theDelegate;

- (NSTimer *)timer;
- (void)setTimer:(NSTimer *)theTimer;

- (NSTimeInterval)interval;
- (void)setInterval:(NSTimeInterval)theInterval;

- (NSString *)message;
- (void)setMessage:(NSString *)theMessage;

- (BOOL)repeats;
- (void)setRepeats:(BOOL)flag;
@end

@implementation NTSimpleTimer

+ (NTSimpleTimer*)timer:(NSTimeInterval)interval message:(NSString*)message delegate:(id<NTSimpleTimerProtocol>)delegate repeats:(BOOL)repeats;
{	
    NTSimpleTimer* result = [[NTSimpleTimer alloc] init];
  
	[result setDelegate:delegate];
	[result setMessage:message];
	[result setInterval:interval];
	[result setRepeats:repeats];
	    
    return [result autorelease];
}

//---------------------------------------------------------- 
// dealloc
//---------------------------------------------------------- 
- (void)dealloc
{
	if ([self delegate])
		[NSException raise:@"must call clearDelegate" format:@"%@", NSStringFromClass([self class])];

    [self setTimer:nil];
    [self setMessage:nil];
    [super dealloc];
}

- (void)clearDelegate;
{
	[self setDelegate:nil];
	[self stop];
}

- (void)stop;
{
	[self setTimer:nil];
}

- (BOOL)isRunning;
{
    return ([self timer] && [[self timer] isValid]);
}

- (void)start;
{
    [self start:NO];
}

- (void)start:(BOOL)defaultModeOnly;
{
    [self createNSTimer];
    
    [[NSRunLoop currentRunLoop] addTimer:[self timer] forMode:NSDefaultRunLoopMode];
    
    if (!defaultModeOnly)
    {
        [[NSRunLoop currentRunLoop] addTimer:[self timer] forMode:NSModalPanelRunLoopMode];
        [[NSRunLoop currentRunLoop] addTimer:[self timer] forMode:NSEventTrackingRunLoopMode];
    }
}

- (void)timerMethod:(NSTimer*)timer;
{
    [[self delegate] delegate_simpleTimerNotification:[self message]];
}

@end

@implementation NTSimpleTimer (Private)

//---------------------------------------------------------- 
//  delegate 
//---------------------------------------------------------- 
- (id <NTSimpleTimerProtocol>)delegate
{
    return mDelegate; 
}

- (void)setDelegate:(id <NTSimpleTimerProtocol>)theDelegate
{
    if (mDelegate != theDelegate) {
        mDelegate = theDelegate;
    }
}

//---------------------------------------------------------- 
//  timer 
//---------------------------------------------------------- 
- (NSTimer *)timer
{
    return mTimer; 
}

- (void)setTimer:(NSTimer *)theTimer
{
    if (mTimer != theTimer) {
		[mTimer invalidate];

        [mTimer release];
        mTimer = [theTimer retain];
    }
}

//---------------------------------------------------------- 
//  interval 
//---------------------------------------------------------- 
- (NSTimeInterval)interval
{
    return mInterval;
}

- (void)setInterval:(NSTimeInterval)theInterval
{
    mInterval = theInterval;
}

//---------------------------------------------------------- 
//  message 
//---------------------------------------------------------- 
- (NSString *)message
{
    return mMessage; 
}

- (void)setMessage:(NSString *)theMessage
{
    if (mMessage != theMessage) {
        [mMessage release];
        mMessage = [theMessage retain];
    }
}

//---------------------------------------------------------- 
//  repeats 
//---------------------------------------------------------- 
- (BOOL)repeats
{
    return mRepeats;
}

- (void)setRepeats:(BOOL)flag
{
    mRepeats = flag;
}

- (void)createNSTimer;
{
    // stop any existing timer
    if ([self timer])
        [self stop];

    [self setTimer:[NSTimer timerWithTimeInterval:[self interval]
                                      target:self
                                    selector:@selector(timerMethod:)
                                    userInfo:nil
                                     repeats:[self repeats]]];
}

@end
