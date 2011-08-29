//
//  CATextLayer-NTExtensions.m
//  CocoatechCore
//
//  Created by Steve Gehrman on 5/15/08.
//  Copyright 2008 Cocoatech. All rights reserved.
//

#import "CATextLayer-NTExtensions.h"


@implementation CATextLayer (NTExtensions)

+ (CATextLayer *)layerWithText:(NSString *)string
{
	return [self layerWithText:string fontSize:13];
}

+ (CATextLayer *)layerWithText:(NSString *)string fontSize:(CGFloat)size
{
	CATextLayer *result = [self layer];
	[result setString:string];

	result.font = [NSFont boldSystemFontOfSize:size];
	[result setFontSize:size];
	
	return result;
}

@end
