//
//  NSObject-NTExtensions.h
//  CocoatechCore
//
//  Created by Steve Gehrman on Wed Oct 30 2002.
//  Copyright (c) 2002 CocoaTech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (NTExtensions)
- (BOOL)tryToPerform:(SEL)selector outResult:(id*)outResult;

- (NSString*)formattedDescription;
- (NSString*)formattedDescription:(NSInteger)prependTabs;

	// surrounds cancelPreviousPerformRequestsWithTarget with retain, autorelease since
	// the object retained by the call could be your self, and any calls after this would crash
- (void)safeCancelPreviousPerformRequests;

	// surrounds cancelPreviousPerformRequestsWithTarget with retain, autorelease since
	// the object retained by the call could be your self, and any calls after this would crash
- (void)safeCancelPreviousPerformRequestsWithSelector:(SEL)aSelector object:(id)anArgument;


+ (NSBundle *)bundle;
- (NSBundle *)bundle;

// make == [[[self alloc] init] autorelease];
+ (id)make;

@end
