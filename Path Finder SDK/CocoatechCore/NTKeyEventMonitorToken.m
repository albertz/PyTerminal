//
//  NTKeyEventMonitorToken.m
//  CocoatechCore
//
//  Created by Steve Gehrman on 9/29/09.
//  Copyright 2009 Cocoatech. All rights reserved.
//

#import "NTKeyEventMonitorToken.h"

@implementation NTKeyEventMonitorToken

@synthesize hotKey;
@synthesize identifier;
@synthesize modifierFlags;

+ (NTKeyEventMonitorToken*)token:(unichar)hotKey
					  identifier:(NSInteger)identifier
				   modifierFlags:(NSUInteger)modifierFlags;
{
	NTKeyEventMonitorToken* result = [[NTKeyEventMonitorToken alloc] init];
	
	result.hotKey = hotKey;
	result.identifier = identifier;
	result.modifierFlags = modifierFlags;
	
	return [result autorelease];
}

- (BOOL)isEqual:(NTKeyEventMonitorToken*)rightObject;
{
	return ((self.hotKey == rightObject.hotKey) && 
			(self.identifier == rightObject.identifier) &&
			(self.modifierFlags == rightObject.modifierFlags));
}

@end

