//
//  NTKeyEventMonitor.h
//  CocoatechCore
//
//  Created by Steve Gehrman on 9/29/09.
//  Copyright 2009 Cocoatech. All rights reserved.
//

#import "NTSingletonObject.h"

// "identifier" key has hotKey id in userInfo
#define kNTKeyEventMonitorNotification @"NTKeyEventMonitorNotification"

#define KEMR (NTKeyEventMonitor*)[NTKeyEventMonitor sharedInstance]

@interface NTKeyEventMonitor : NTSingletonObject
{
	NSMutableDictionary* hotKeyMap;
	id eventMonitor;
}

- (id)setHotKey:(unichar)hotKey identifier:(NSInteger)identifier modifierFlags:(NSUInteger)modifierFlags;
- (void)removeHotKey:(id)keyToken;

@end
