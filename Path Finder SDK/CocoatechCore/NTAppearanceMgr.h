//
//  NTAppearanceMgr.h
//  CocoatechCore
//
//  Created by Steve Gehrman on 4/3/09.
//  Copyright 2009 Cocoatech. All rights reserved.
//

#import "NTSingletonObject.h"

@class NTAppearanceMgr, NTKVObserverProxy;

#define kNTAppearanceMgrNotification @"NTAppearanceMgrNotification"

#define NTAM (NTAppearanceMgr*)[NTAppearanceMgr sharedInstance]

typedef enum {
	NTAppearance_Regular,
	NTAppearance_Large,
} NTAppearanceSize;
	
@interface NTAppearanceMgr : NTSingletonObject
{
	NSUInteger buildNumber;
	
	NTAppearanceSize sizeMode;
	NSFont* buttonFont;
	CGFloat barHeight;
	
	NSFont* headerFont;
	CGFloat headerHeight;
	
	NSFont* statusFont;
	NTKVObserverProxy* observerProxy;
}

@property (nonatomic, assign) NSUInteger buildNumber;
@property (nonatomic, assign) NTAppearanceSize sizeMode;
@property (nonatomic, retain) NSFont *buttonFont;
@property (nonatomic, assign) CGFloat barHeight;

@property (nonatomic, retain) NSFont *headerFont;
@property (nonatomic, assign) CGFloat headerHeight;

@property (nonatomic, retain) NSFont *statusFont;
@property (nonatomic, retain) NTKVObserverProxy* observerProxy;
@end
