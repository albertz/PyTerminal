//
//  CATransaction-NTExtensions.m
//  CocoatechCore
//
//  Created by Steve Gehrman on 6/15/08.
//  Copyright 2008 Cocoatech. All rights reserved.
//

#import "CATransaction-NTExtensions.h"


@implementation CATransaction (NTExtensions)

+ (void)beginDisabled;
{
	[CATransaction flush];
	[CATransaction begin];
	[CATransaction setValue:(id)kCFBooleanTrue
					 forKey:kCATransactionDisableActions];
}

@end
