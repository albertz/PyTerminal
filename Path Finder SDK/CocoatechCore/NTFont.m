//
//  NTFont.m
//  CocoatechCore
//
//  Created by Steve Gehrman on Fri Dec 28 2001.
//  Copyright (c) 2001 CocoaTech. All rights reserved.
//

#import "NTFont.h"

@implementation NTFont

@synthesize normal;
@synthesize bold;
@synthesize italic;
@synthesize boldItalic;

+ (id)fontWithFont:(NSFont*)font;
{
    NTFont* result = [[NTFont alloc] init];

	[result setNormal:font];

    return [result autorelease];
}

- (void)encodeWithCoder:(NSCoder *)aCoder;
{
    [aCoder encodeObject:[self normal] forKey:@"Font"];
}

- (id)initWithCoder:(NSCoder *)aDecoder;
{
	if (self = [super init])
	{	
		id value = [aDecoder decodeObjectForKey:@"Font"];
		if (value)
			[self setNormal:value];
	}
	
	return self;
}

//---------------------------------------------------------- 
// dealloc
//---------------------------------------------------------- 
- (void) dealloc
{
    self.normal = nil;
    self.bold = nil;
    self.italic = nil;
    self.boldItalic = nil;
    [super dealloc];
}

// override to build lazily
- (NSFont*)bold;
{
    if (bold == nil)
        bold = [[[NSFontManager sharedFontManager] convertFont:[self normal] toHaveTrait:NSBoldFontMask] retain];

    return bold;
}

// override to build lazily
- (NSFont*)italic;
{
    if (italic == nil)
        italic = [[[NSFontManager sharedFontManager] convertFont:[self normal] toHaveTrait:NSItalicFontMask] retain];

    return italic;
}

// override to build lazily
- (NSFont*)boldItalic;
{
    if (boldItalic == nil)
        boldItalic = [[[NSFontManager sharedFontManager] convertFont:[self italic] toHaveTrait:NSBoldFontMask] retain];

    return boldItalic;
}

- (NSString*)displayString;
{
    NSString* result = [[self normal] displayName];

    result = [result stringByAppendingString:[NSString stringWithFormat:@" - %.1lf", [[self normal] pointSize]]];

    return result;
}

- (NSString*)description;
{
	return [self displayString];
}

@end
