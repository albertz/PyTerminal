//
//  NTMessageProxy.m
//  CocoatechCore
//
//  Created by Steve Gehrman on 2/18/10.
//  Copyright 2010 Cocoatech. All rights reserved.
//

#import "NTMessageProxy.h"
#import "NTProxy.h"

@interface NTMessageProxy ()
@property (nonatomic, retain) NTProxy *targetProxy;
@end

@implementation NTMessageProxy

@synthesize targetProxy;

//---------------------------------------------------------- 
// dealloc
//---------------------------------------------------------- 
- (void)dealloc
{	
	if (self.targetProxy)
		[NSException raise:@"must call invalidate" format:@"%@", NSStringFromClass([self class])];
	
    [super dealloc];
}

+ (NTMessageProxy*)proxy:(id<NTMessageProxyProtocol>)target;
{
	NTMessageProxy* result = [[self alloc] init];
	
	result.targetProxy = [NTProxy proxyWithObject:target];

	return [result autorelease];
}

- (void)notify:(id)theMessage; // nil is fine
{	
	@synchronized(self) {
		if (self.targetProxy)
			[self.targetProxy.object messageProxy:self message:theMessage];
	}
}

- (void)invalidate;
{
	@synchronized(self) {
		self.targetProxy.object = nil;
		self.targetProxy = nil;
	}
}

@end
