//
//  NSURL-NTExtensions.m
//  CocoatechCore
//
//  Created by Steve Gehrman on 11/4/09.
//  Copyright 2009 Cocoatech. All rights reserved.
//

#import "NSURL-NTExtensions.h"

@implementation NSURL (NTExtensions)

- (id)resourceForKey:(NSString*)resourceKey;
{
	NSError *error=nil;
	id result = [self resourceForKey:resourceKey error:&error];
	
	//	if (error)
	//		NSLog(@"-[%@ %@] error:%@ url:%@ resource:%@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), error, self, resourceKey);
	
	return result;
}

- (id)resourceForKey:(NSString*)resourceKey error:(NSError**)outError;
{
	id result=nil;
	[self getResourceValue:&result forKey:resourceKey error:outError];
	
	return result;
}

@end
