//
//  NTSimpleTimer.h
//  CocoatechCore
//
//  Created by sgehrman on Fri Jun 22 2001.
//  Copyright (c) 2001 CocoaTech. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <sys/time.h>

// ------------------------------------------------------

@protocol NTSimpleTimerProtocol
- (void)delegate_simpleTimerNotification:(NSString*)message;
@end

@interface NTSimpleTimer : NSObject
{
    id <NTSimpleTimerProtocol> mDelegate;

    NSTimer* mTimer;
    NSTimeInterval mInterval;
    NSString* mMessage;
    BOOL mRepeats;
}

+ (NTSimpleTimer*)timer:(NSTimeInterval)interval
				message:(NSString*)message 
			   delegate:(id<NTSimpleTimerProtocol>)delegate 
				repeats:(BOOL)repeats;

- (void)clearDelegate; // also stops since without a delegate, it's useless

- (void)start; // start does all modes
- (void)start:(BOOL)defaultModeOnly;

- (void)stop;

- (BOOL)isRunning;

@end
