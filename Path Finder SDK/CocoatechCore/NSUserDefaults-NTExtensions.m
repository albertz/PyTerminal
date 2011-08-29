//
//  NSUserDefaults-NTExtensions.m
//  CocoaTechBase
//
//  Created by Steve Gehrman on 11/16/04.
//  Copyright 2004 __MyCompanyName__. All rights reserved.
//

#import "NSUserDefaults-NTExtensions.h"
#import "NTFont.h"
#import "NSThread-NTExtensions.h"

@implementation NSUserDefaults (NTExtensions)

- (void)delayedSynchronize;  // synchronize after a few seconds, improve launch time?
{
	[self performDelayedSelector:@selector(synchronize) withObject:nil delay:2];
}

- (NSInteger)intForKey:(NSString*)key defaultValue:(NSInteger)defaultValue;
{
	id result = [self objectForKey:key];
	
    if (!result)
        return defaultValue;
	
    return [(NSNumber*)result integerValue];
}

- (NSUInteger)unsignedIntForKey:(NSString*)key defaultValue:(NSUInteger)defaultValue;
{
	id result = [self objectForKey:key];
	
    if (!result)
        return defaultValue;
	
    return [(NSNumber*)result unsignedIntegerValue];
}

- (float)floatForKey:(NSString*)key defaultValue:(CGFloat)defaultValue;
{
	id result = [self objectForKey:key];
	
    if (!result)
        return defaultValue;
	
    return [(NSNumber*)result doubleValue];
}

- (double)doubleForKey:(NSString*)key defaultValue:(double)defaultValue;
{
	id result = [self objectForKey:key];
	
    if (!result)
        return defaultValue;
	
    return [(NSNumber*)result doubleValue];
}

- (NSString*)stringForKey:(NSString*)key defaultValue:(NSString*)defaultValue;
{
	id result = [self objectForKey:key];
	
    if (!result)
        return defaultValue;
	
    return result;
}

- (BOOL)boolForKey:(NSString*)key defaultValue:(BOOL)defaultValue;
{
	id result = [self objectForKey:key];
	
    if (!result)
        return defaultValue;
	
    return [(NSNumber*)result boolValue];
}

- (NSNumber*)numberForKey:(NSString*)key defaultValue:(NSNumber*)defaultValue;
{
	id result = [self objectForKey:key];
	
    if (!result)
        return defaultValue;
	
    return result;
}

- (NSRect)rectForKey:(NSString*)key defaultValue:(NSRect)defaultValue;
{
	NSString* result = [self objectForKey:key];
	
    if (!result)
        return defaultValue;
	
    return NSRectFromString(result);
}

- (NTFont*)fontForKey:(NSString*)key defaultValue:(NTFont*)defaultValue;
{
	id result = [self objectForKey:key];
	
    if (result)
	{	
		// archived as an NSFont
		NSFont* font = [NSUnarchiver unarchiveObjectWithData:result];
		if (font)
			return [NTFont fontWithFont:font];
	}
	
	return defaultValue;
}

- (NSColor*)colorForKey:(NSString*)key defaultValue:(NSColor*)defaultValue;
{
    id result = [self objectForKey:key];
	
	if (result)
	{
		NSColor* color = [NSUnarchiver unarchiveObjectWithData:result];
		
		if (color)
			return color;
	}
	
	return defaultValue;
}

// ========================================================================

- (void)setInt:(NSInteger)value forKey:(NSString*)key;
{
    [self setObject:[NSNumber numberWithInteger:value] forKey:key];
}

- (void)setUnsignedInt:(NSUInteger)value forKey:(NSString*)key;
{
    [self setObject:[NSNumber numberWithUnsignedInteger:value] forKey:key];
}

- (void)setFloat:(float)value forKey:(NSString*)key;
{
    [self setObject:[NSNumber numberWithDouble:value] forKey:key];
}

- (void)setDouble:(double)value forKey:(NSString*)key;
{
    [self setObject:[NSNumber numberWithDouble:value] forKey:key];
}

- (void)setString:(NSString*)value forKey:(NSString*)key;
{
    [self setObject:value forKey:key];
}

- (void)setNumber:(NSNumber*)value forKey:(NSString*)key;
{
    [self setObject:value forKey:key];
}

- (void)setRect:(NSRect)value forKey:(NSString*)key;
{	
    [self setObject:NSStringFromRect(value) forKey:key];
}

- (void)setFont:(NTFont*)value forKey:(NSString*)key;
{
    [self setObject:[NSArchiver archivedDataWithRootObject:[value normal]] forKey:key];
}

- (void)setColor:(NSColor*)value forKey:(NSString*)key;
{
    [self setObject:[NSArchiver archivedDataWithRootObject:value] forKey:key];
}

@end

@implementation NSUserDefaults (NTExtensionsArchived)

- (NSDictionary*)archivedDictionaryForKey:(NSString*)key defaultValue:(NSDictionary*)defaultValue;
{
	NSData* data = [self objectForKey:key];
	NSDictionary *result=nil;
	
	if ([data isKindOfClass:[NSData class]])
	{
		result = [NSUnarchiver unarchiveObjectWithData:data];

		if (![result isKindOfClass:[NSDictionary class]])
			result = nil;
	}
	
    if (!result)
        return defaultValue;
	
	return result;
}

- (NSArray*)archivedArrayForKey:(NSString*)key defaultValue:(NSArray*)defaultValue;
{
	NSData* data = [self objectForKey:key];
	NSArray *result=nil;
	
	if ([data isKindOfClass:[NSData class]])
	{
		result = [NSUnarchiver unarchiveObjectWithData:data];
		
		if (![result isKindOfClass:[NSArray class]])
			result = nil;
	}
	
    if (!result)
        return defaultValue;
	
	return result;
}

- (void)setArchivedDictionary:(NSDictionary*)value forKey:(NSString*)key;
{
	[self setObject:[NSArchiver archivedDataWithRootObject:value] forKey:key];
}

- (void)setArchivedArray:(NSArray*)value forKey:(NSString*)key;
{
	[self setObject:[NSArchiver archivedDataWithRootObject:value] forKey:key];
}

@end

