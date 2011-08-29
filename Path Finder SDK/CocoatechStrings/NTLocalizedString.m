// NTLocalizedString.m

#import "NTLocalizedString.h"
#import "NTViewLocalizer.h"

static id<NTLocalizedStringFilterProtocol> sLocalizedStringFilter = nil;

@implementation NTLocalizedString

+ (NSString*)localize:(NSString*)str;
{
    return [self localize:str table:nil];
}

+ (NSString*)localize:(NSString*)str table:(NSString*)table;
{
	return [self localize:str table:table bundle:[NSBundle bundleForClass:self]];
}

+ (NSString*)localize:(NSString*)str table:(NSString*)table bundle:(NSBundle*)bundle;
{
	NSString *result = str;
	
	if ([result length])
	{
		// if table is nil, use the default
		if (!table)
			table = @"default";
		
		result = NSLocalizedStringFromTableInBundle(result, table, bundle, @"");

		// filtering is used for the localization tools, normally off when shipping
		if (sLocalizedStringFilter)
		{
			if ([str isEqualToString:result])
				[sLocalizedStringFilter localizedStringFilter_unlocalizedString:str table:table];
		}
	}
	
	return result;
}

+ (void)localizeWindow:(NSWindow*)window;
{
    [NTViewLocalizer localizeWindow:window table:@"default" bundle:[NSBundle bundleForClass:self]];
}

+ (void)localizeWindow:(NSWindow*)window table:(NSString*)table;
{
    [NTViewLocalizer localizeWindow:window table:table bundle:[NSBundle bundleForClass:self]];
}

+ (void)localizeView:(NSView*)view;
{
    [NTViewLocalizer localizeView:view table:@"default" bundle:[NSBundle bundleForClass:self]];
}

+ (void)localizeView:(NSView*)view table:(NSString*)table;
{
    [NTViewLocalizer localizeView:view table:table bundle:[NSBundle bundleForClass:self]];
}

@end

@implementation NTLocalizedString (Filter)

+ (void)setLocalizedStringFilter:(id<NTLocalizedStringFilterProtocol>)filter;
{
	sLocalizedStringFilter = filter;

	if (sLocalizedStringFilter)
		NSLog(@"WARNING: Localization filtering On.  Make sure this is disabled before shipping!");
}

@end

@implementation NTLocalizedString (Regions)

+ (BOOL)usingEnglishLocalization;
{
	static NSInteger shared = -1;
	
	if (shared == -1)
	{
		shared = 0;
		
		NSString *region = [self region];
		
		if ([region isEqualToString:@"en"])
			shared = 1;
	}
	
	return (shared == 1);
}

+ (NSString*)colon; // ":" = english, " :" = french
{
	static NSString* shared = nil;
	
	if (!shared)
	{
		NSString *region = [self region];
		
		shared = @":";
		if ([region isEqualToString:@"fr"])
			shared = @" :";
		
		shared = [shared retain];
	}
	
	return shared;
}

+ (NSString*)region;
{
	static NSString* shared = nil;
	
	if (!shared)
	{
		NSArray* localizations = [[NSBundle mainBundle] preferredLocalizations];
		NSString *region, *result=nil;
		NSArray* regions = [self regions];
		
		if ([localizations count])
		{
			
			for (region in localizations)
			{
				region = [NSLocale canonicalLocaleIdentifierFromString:region];
				
				if ([regions containsObject:region])
				{
					result = region;
					break;
				}
			}
		}	
		
		if (!result)
			result = @"en";
		
		shared = [result retain];
	}
	
	return shared;
}

+ (NSArray*)regions;
{
	static NSArray* shared = nil;
	
	if (!shared)
	{
		NSMutableArray* regions = [NSMutableArray array];
		
		// NSBundle is not toll free bridged
		// convert to a CFBundle.
		NSBundle* nsBundle = [NSBundle bundleForClass:self];
		CFBundleRef bundle = CFBundleCreate(kCFAllocatorDefault, (CFURLRef) [NSURL fileURLWithPath:[nsBundle bundlePath]]);
		if (bundle)
		{
			NSArray* regionArray = [(NSArray*)CFBundleCopyBundleLocalizations(bundle) autorelease];
			NSString* region;
			
			for (region in regionArray)
				[regions addObject:[NSLocale canonicalLocaleIdentifierFromString:region]];  // always deal with the canonical names
			
			if (bundle)
				CFRelease(bundle);
		}
		
		[regions sortUsingSelector:@selector(compare:)];
		
		shared = [[NSArray alloc] initWithArray:regions];
	}
	
	return shared;
}

@end

