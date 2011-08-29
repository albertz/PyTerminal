//
//  NTSpringLoadedViewHelper.h
//  CocoatechCore
//
//  Created by Steve Gehrman on 10/15/06.
//  Copyright 2006 Cocoatech. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class NTSpringLoadedViewHelper, NTSpaceKeyPoll;

@protocol NTSpringLoadedViewHelperDelegateProtocol <NSObject>
- (void)springLoadedHelper_hasSprung:(NTSpringLoadedViewHelper*)helper;
- (NSView*)springLoadedHelper_toggleState:(NTSpringLoadedViewHelper*)helper;  // for example: [self setMouseOver:![self mouseOver]];  return your view so I can force a redraw
@end

@interface NTSpringLoadedViewHelper : NSObject {
	id<NTSpringLoadedViewHelperDelegateProtocol> mDelegate;
	
	NTSpaceKeyPoll* spaceKeyPoll;
	BOOL mSpringLoadedRunning;
}

@property (retain) NTSpaceKeyPoll* spaceKeyPoll;

+ (NTSpringLoadedViewHelper*)helper:(id<NTSpringLoadedViewHelperDelegateProtocol>)delegate;
- (void)clearDelegate;

- (void)startSpringLoadedAction;
- (void)cancelSpringLoadedAction;

@end
