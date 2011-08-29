//
//  NTSCPrefsListener.h
//  CocoatechCore
//
//  Created by Steve Gehrman on 7/15/08.
//  Copyright 2008 Cocoatech. All rights reserved.
//

#import "NTSingletonObject.h"
#import <SystemConfiguration/SystemConfiguration.h>

#define kNTComputerNamedChangedNotification @"NTComputerNamedChangedNotification"
#define kNTIPAddressChangedNotification @"NTIPAddressChangedNotification"

@interface NTSCPrefsListener : NTSingletonObject
{
	SCPreferencesRef prefsRef;
	
	NSString* computerName;
	NSString* networkState;
	UInt64 networkStateID;
}

@property (nonatomic, assign) UInt64 networkStateID;

@end

