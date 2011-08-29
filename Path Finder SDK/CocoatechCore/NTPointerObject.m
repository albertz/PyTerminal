//
//  NTPointerObject.m
//  CocoatechCore
//
//  Created by Steve Gehrman on 9/23/08.
//  Copyright 2008 Cocoatech. All rights reserved.
//

#import "NTPointerObject.h"


@implementation NTPointerObject

@synthesize pointer;

+ (NTPointerObject*)object:(void*)thePointer;
{
	NTPointerObject* result = [[NTPointerObject alloc] init];
	
	result.pointer = thePointer;
	
	return [result autorelease];
}

@end
