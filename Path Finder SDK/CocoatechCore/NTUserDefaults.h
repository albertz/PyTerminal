//
//  NTUserDefaults.h
//  CocoaTechBase
//
//  Created by Steve Gehrman on 9/14/04.
//  Copyright 2004 __MyCompanyName__. All rights reserved.
//

#import "NTSingletonObject.h"

// this is like the NSUserDefaults except that it sends out NTPrefNotifications

@interface NTUserDefaults : NTSingletonObject
{	
	NSMutableArray* keysObserving;
}

// will send notifications when default changes automatically
- (void)notifyForDefault:(NSString*)theDefaultName;

// these send notifications when called
// this is obsolete, need to remove soon
- (void)setBool:(BOOL)set forKey:key;
- (void)setString:(NSString*)set forKey:key;
- (void)setFloat:(float)value forKey:(NSString *)key;
- (void)setInt:(NSInteger)integer forKey:key;
- (void)setUnsigned:(NSUInteger)value forKey:key;
- (void)setObject:(id)obj forKey:key;
	
@end
