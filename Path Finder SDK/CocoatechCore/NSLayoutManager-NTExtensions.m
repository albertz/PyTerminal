//
//  NSLayoutManager-NTExtensions.m
//  CocoatechCore
//
//  Created by Steve Gehrman on 11/24/08.
//  Copyright 2008 Cocoatech. All rights reserved.
//

#import "NSLayoutManager-NTExtensions.h"

@implementation NSLayoutManager (NTExtensions)

+ (CGFloat)defaultLineHeightForFont:(NSFont *)theFont;
{
	static NSLayoutManager* shared = nil;
	
	if (!shared)
		shared = [[NSLayoutManager alloc] init];
	
	return [shared defaultLineHeightForFont:theFont];
}

@end
