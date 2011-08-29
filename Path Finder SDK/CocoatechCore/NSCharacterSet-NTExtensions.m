//
//  NSCharacterSet-NTExtensions.m
//  CocoatechCore
//
//  Created by Steve Gehrman on 4/6/09.
//  Copyright 2009 Cocoatech. All rights reserved.
//

#import "NSCharacterSet-NTExtensions.h"

@implementation NSCharacterSet (NTExtensions)

+ (BOOL)isAlphaNum:(unichar)theCharacter;
{
	static NSCharacterSet* shared=nil;
	if (!shared)
		shared = [[NSCharacterSet alphanumericCharacterSet] retain];
	
    return [shared characterIsMember:theCharacter];
}

+ (BOOL)isAlpha:(unichar)theCharacter;
{
	static NSCharacterSet* shared=nil;
	if (!shared)
		shared = [[NSCharacterSet letterCharacterSet] retain];
	
    return [shared characterIsMember:theCharacter];
}

+ (BOOL)isDigit:(unichar)theCharacter;
{
	static NSCharacterSet* shared=nil;
	if (!shared)
		shared = [[NSCharacterSet decimalDigitCharacterSet] retain];
	
    return [shared characterIsMember:theCharacter];
}

+ (BOOL)isPrint:(unichar)theCharacter;
{
	static NSMutableCharacterSet* shared=nil;
	if (!shared)
	{
		// alphanumeric set
		shared = [NSMutableCharacterSet alphanumericCharacterSet];
	
		// add punctuation
		[shared formUnionWithCharacterSet:[NSCharacterSet punctuationCharacterSet]];

		// add space
		[shared addCharactersInString:@" "];

		shared = [shared retain];
	}
    return [shared characterIsMember:theCharacter];
}

@end
