//
//  NTKVObserverProxy.m
//  SourceViewModulePlugin
//
//  Created by Steve Gehrman on 2/22/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "NTKVObserverProxy.h"

@implementation NTKVObserverProxy

@synthesize delegate;

+ (NTKVObserverProxy*)proxy:(id<NTKVObserverProxyDelegateProtocol>)theDelegate;
{
	NTKVObserverProxy* result = [[NTKVObserverProxy alloc] init];
	
	result.delegate = theDelegate;
	
	return [result autorelease];
}

- (void)dealloc;
{
	if (self.delegate)
		[NSException raise:@"must call xx.delegate=nil before releasing" format:@"%@", NSStringFromClass([self class])];

	[super dealloc];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context;
{
	[self.delegate observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

@end
