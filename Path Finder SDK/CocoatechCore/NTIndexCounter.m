//
//  NTIndexCounter.m
//  CocoatechCore
//
//  Created by Steve Gehrman on 7/14/09.
//  Copyright 2009 Cocoatech. All rights reserved.
//

#import "NTIndexCounter.h"

@interface NTIndexCounter ()
@property (nonatomic, assign) NSUInteger count;
@property (nonatomic, assign) NSUInteger index;
@end

@implementation NTIndexCounter

@synthesize count;
@synthesize index;

+ (NTIndexCounter*)counter:(NSUInteger)count;
{
	NTIndexCounter* result = [[NTIndexCounter alloc] init];
	
	[result setCount:count];
	
	return [result autorelease];
}

- (void)increment; 
{
	[self setIndex:self.index + 1];
}

- (BOOL)done;
{
	return ![self remaining];
}

- (NSUInteger)remaining; // used to enable the "Apply to All" checkbox
{
	return self.count - self.index;
}

@end

@implementation NTIndexCounter (Private)

- (NSString*)description;
{
	NSMutableString *result = [NSMutableString stringWithString:[super description]];
	
	[result appendFormat:@"\ncount: %ld\n", self.count];
	[result appendFormat:@"remaining: %ld\n", [self remaining]];
	[result appendFormat:@"done: %@\n", [self done] ? @"YES":@"NO"];
	
	return result;
}

@end

