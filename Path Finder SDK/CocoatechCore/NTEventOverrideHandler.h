//
//  NTEventOverrideHandler.h
//  CocoatechCore
//
//  Created by Steve Gehrman on 6/4/08.
//  Copyright 2008 Cocoatech. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#define kNTEventOverrideHandlerNotification @"NTEventOverrideHandlerNotification"

@interface NTEventOverrideHandler : NSObject
{
}

+ (NTEventOverrideHandler*)handler;

- (BOOL)eventHandled:(NSEvent*)theEvent;

@end
