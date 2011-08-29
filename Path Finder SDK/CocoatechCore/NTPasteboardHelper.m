//
//  NTPasteboardHelper.m
//  CocoatechCore
//
//  Created by Steve Gehrman on 11/10/08.
//  Copyright 2008 Cocoatech. All rights reserved.
//

#import "NTPasteboardHelper.h"
#import "NSMutableDictionary-NTExtensions.h"

@interface NTPasteboardHelper (Private)
- (void)absolvePasteboardResponsibility;
@end

@implementation NTPasteboardHelper

@synthesize typeToOwner;
@synthesize responsible;
@synthesize pasteboard;
@synthesize notificationName;

//---------------------------------------------------------- 
// dealloc
//---------------------------------------------------------- 
- (void)dealloc
{
	[self absolvePasteboardResponsibility];
    self.typeToOwner = nil;
    self.pasteboard = nil;
	self.notificationName = nil;
    [super dealloc];
}

+ (NTPasteboardHelper *)helperWithPasteboard:(NSPasteboard *)newPasteboard;
{
    NTPasteboardHelper* result = [[self alloc] init];
	
	result.pasteboard = newPasteboard;
    result.typeToOwner = [NSMutableDictionary dictionary];

	return [result autorelease];
}

- (void)addTypes:(NSArray *)someTypes owner:(id<NTPasteboardHelperOwnerProtocol>)anOwner;
{
    if ([self.typeToOwner count] == 0) 
	{
        [self.pasteboard declareTypes:someTypes owner:self];
        if (self.responsible == 0)
            [self retain]; // We must stay around until no longer responsible
		
		self.responsible += 1;
    }
	else
		[self.pasteboard addTypes:someTypes owner:self];
	
    [self.typeToOwner setObject:anOwner forKeys:someTypes];
}

- (void)declareTypes:(NSArray *)someTypes owner:(id<NTPasteboardHelperOwnerProtocol>)anOwner;
{
    [self absolvePasteboardResponsibility];
    [self addTypes:someTypes owner:anOwner];
}

- (void)pasteboard:(NSPasteboard *)aPasteboard provideDataForType:(NSString *)type;
{
    id<NTPasteboardHelperOwnerProtocol> realOwner;
	
    realOwner = [self.typeToOwner objectForKey:type];
    [realOwner pasteboard:aPasteboard provideDataForType:type];
}

- (void)pasteboardChangedOwner:(NSPasteboard *)aPasteboard;
{
	self.responsible -= 1;
    if (self.responsible == 0)
	{
		[self absolvePasteboardResponsibility];
		
		if (self.notificationName)
			[[NSNotificationCenter defaultCenter] postNotificationName:self.notificationName object:nil];
		
        [self release]; // No longer responsible, so dump the extra retain we added in -addTypes:owner:
    }
}

@end

@implementation NTPasteboardHelper (Private)

- (void)absolvePasteboardResponsibility;
{
    [self.typeToOwner removeAllObjects];
}

@end

