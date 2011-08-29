//
//  NTPrefNotification.m
//  CocoaTechBase
//
//  Created by Steve Gehrman on Fri Aug 30 2002.
//  Copyright (c) 2002 CocoaTech. All rights reserved.
//

#import "NTPrefNotification.h"

@interface NTPrefNotification ()
@property (nonatomic, retain) NSMutableSet *nameSet;
@end

@implementation NTPrefNotification

@synthesize nameSet;

- (id)init;
{
    self = [super init];

    self.nameSet = [NSMutableSet set];

    return self;
}

- (void)dealloc;
{
    self.nameSet = nil;
    [super dealloc];
}

- (void)sendNotification;
{
    [self sendNotificationWithDocument:nil];
}

- (void)sendNotificationWithDocument:(id)object;   // used for document preferences (message only sent to objects registerted with object)
{
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];

    [dict setObject:self forKey:@"NTPrefNotification"];
    
    if (object)
        [[NSNotificationCenter defaultCenter] postNotificationName:kNTObjectPreferencesModifiedNotification object:object userInfo:dict];    
    else
        [[NSNotificationCenter defaultCenter] postNotificationName:kNTPreferencesModifiedNotification object:nil userInfo:dict];    
}

+ (NTPrefNotification*)notification;
{
    NTPrefNotification *result = [[NTPrefNotification alloc] init];

    return [result autorelease];
}

+ (NTPrefNotification*)notificationWithPreference:(NSString*)preference;
{
    NTPrefNotification *result = [[NTPrefNotification alloc] init];

    [result addPreference:preference];

    return [result autorelease];
}

+ (NTPrefNotification*)notificationWithPreferences:(NSArray*)preferences;
{
    NTPrefNotification *result = [[NTPrefNotification alloc] init];

    [result addPreferences:preferences];

    return [result autorelease];
}

+ (NTPrefNotification*)extractFromNotification:(NSNotification*)notification;
{
    NSDictionary* dict = [notification userInfo];
    NTPrefNotification* result = [dict objectForKey:@"NTPrefNotification"];

    return result;
}

- (BOOL)isPreferenceChanged:(NSString*)preference;
{
    return [self.nameSet containsObject:preference];
}

- (BOOL)isAnyPreferenceChanged:(NSArray*)preferences;
{

    for (id loopItem in preferences)
    {
        if ([self isPreferenceChanged:loopItem])
            return YES;
    }

    return NO;
}

- (void)addPreference:(NSString*)preference;
{
    [self.nameSet addObject:preference];
}

- (void)addPreferences:(NSArray*)preferences;
{

    for (id loopItem in preferences)
        [self addPreference:loopItem];
}

- (NSInteger)numPreferences;
{
    return [self.nameSet count];
}

@end
