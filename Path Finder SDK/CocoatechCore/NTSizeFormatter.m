//
//  NTSizeFormatter.m
//  CocoatechCore
//
//  Created by Steve Gehrman on Thu Feb 27 2003.
//  Copyright (c) 2003 CocoaTech. All rights reserved.
//

#import "NTSizeFormatter.h"
#import "NTUserDefaults.h"
#import "NTPrefNotification.h"

@interface NTSizeFormatter ()
@property (nonatomic, retain) NSString *byteUnit;
@property (nonatomic, retain) NSString *kiloUnit;
@property (nonatomic, retain) NSString *megaUnit;
@property (nonatomic, retain) NSString *gigaUnit;
@property (nonatomic, retain) NSNumberFormatter *numFormatter;
@end

@interface NTSizeFormatter (Private)
- (void)updateMathConstants;
@end

// constants change depending on pref set
static UInt64 kOneK;
static UInt64 kOneMegabyte;
static UInt64 kOneGigabyte;

@implementation NTSizeFormatter

NTSINGLETON_INITIALIZE;
NTSINGLETONOBJECT_STORAGE;

@synthesize byteUnit;
@synthesize kiloUnit;
@synthesize megaUnit;
@synthesize gigaUnit;
@synthesize numFormatter;

- (id)init
{	
    self = [super init];
	
	[self updateMathConstants];
	
	NSNumberFormatter* formatter = [[[NSNumberFormatter alloc] init] autorelease];
	[formatter setFormat:@"#,##0.##"];
	[self setNumFormatter:formatter];		
		
	[[NTUserDefaults sharedInstance] notifyForDefault:@"useBase2MathForSizes"];
	
	// must be notified when the prefs change
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(preferencesModified:)
												 name:kNTPreferencesModifiedNotification
											   object:nil];
	
	[self setByteUnit:[NTLocalizedString localize:@"bytes" table:@"CocoaTechBase"]];
    [self setKiloUnit:@"KB"];
    [self setMegaUnit:@"MB"];
    [self setGigaUnit:@"GB"];	
	
    return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];

    self.numFormatter = nil;
    self.byteUnit = nil;
    self.kiloUnit = nil;
    self.megaUnit = nil;
    self.gigaUnit = nil;
	
    [super dealloc];
}

- (NSString *)fileSize:(UInt64)numBytes;
{
	return [self fileSize:numBytes allowBytes:YES];
}

- (NSString *)fileSize:(UInt64)numBytes
			allowBytes:(BOOL)allowBytes; // allowBytes == NO means 512 bytes will be .5 KB
{
	NTSizeUnit unit;
    NSString* result = [self fileSize:numBytes outUnit:&unit allowBytes:allowBytes];

	// append unit
    result = [result stringByAppendingFormat:@" %@", [self stringForUnit:unit]];

    return result;
}

- (NSString*)fileSizeInBytes:(UInt64)numBytes;
{
    NSString* result = [self numberString:numBytes];
	
	result = [result stringByAppendingFormat:@" %@", [self stringForUnit:kByteUnit]];
	
	return result;
}

- (NSString*)numberString:(UInt64)number;
{
    NSString* result = [[self numFormatter] stringForObjectValue:[NSNumber numberWithUnsignedLongLong:number]];
		
	return result;
}

- (NSString*)sizeString:(NSSize)size;
{
	return [NSString stringWithFormat:@"%@ x %@", [[self numFormatter] stringForObjectValue:[NSNumber numberWithDouble:size.width]], [[self numFormatter] stringForObjectValue:[NSNumber numberWithDouble:size.height]]];
}

- (NSString *)fileSize:(UInt64)numBytes
			   outUnit:(NTSizeUnit*)outUnit 
			allowBytes:(BOOL)allowBytes; // use can append the unit themselves
{
    NSString* result;
    CGFloat fraction=0.0;
    UInt64 bytes;
    NTSizeUnit unit;
	
    // need to return bytes if less than a megabyte
    if ((numBytes < kOneK) && allowBytes)
	{
        unit = kByteUnit;
		bytes = numBytes;
	}
    else if (numBytes < kOneMegabyte)  // kilo bytes
    {
        bytes = numBytes/kOneK;		
		fraction = U64Mod(numBytes,kOneK);
		fraction = fraction / kOneK;
		
		unit = kKiloBytesUnit;
    }
    else if (numBytes < kOneGigabyte)  // mega bytes
    {
        bytes = numBytes/kOneMegabyte;
		fraction = U64Mod(numBytes,kOneMegabyte);
		fraction = fraction / kOneMegabyte;

        unit = kMegaBytesUnit;
    }
    else // giga bytes
    {
        bytes = numBytes/kOneGigabyte;
		fraction = U64Mod(numBytes,kOneGigabyte);
		fraction = fraction / kOneGigabyte;

        unit = kGigaBytesUnit;
    }
	
    result = [[NSNumber numberWithUnsignedLong:bytes] stringValue];
	
	NSInteger fract = (fraction*10);
	if (fract != 0)
		result = [result stringByAppendingFormat:@".%ld",fract];
		
	if (outUnit)
		*outUnit = unit;
	
    return result;
}

- (NSString *)stringForUnit:(NTSizeUnit)unit;
{
	switch (unit)
	{
		case kByteUnit:
			return [self byteUnit];
		case kKiloBytesUnit:
			return [self kiloUnit];
		case kMegaBytesUnit:
			return [self megaUnit];
		case kGigaBytesUnit:
			return [self gigaUnit];
	}
	
	return @"";
}

@end

@implementation NTSizeFormatter (Private)

- (void)updateMathConstants;
{
	kOneK = 1000;
	kOneMegabyte = 1000 * 1000;
	kOneGigabyte = 1000 * 1000 * 1000;
	
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"useBase2MathForSizes"])
	{
		kOneK = 1024;
		kOneMegabyte = 1024 * 1024;
		kOneGigabyte = 1024 * 1024 * 1024;
	}
}

- (void)preferencesModified:(NSNotification*)notification;
{
    NTPrefNotification *pcn = [NTPrefNotification extractFromNotification:notification];
	
	if ([pcn isAnyPreferenceChanged:[NSArray arrayWithObject:@"useBase2MathForSizes"]])
		[self updateMathConstants];
}

@end

