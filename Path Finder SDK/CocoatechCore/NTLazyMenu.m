//
//  NTLazyMenu.m
//  CocoatechCore
//
//  Created by Steve Gehrman on 12/20/04.
//  Copyright 2004 __MyCompanyName__. All rights reserved.
//

#import "NTLazyMenu.h"
#import "NSMenuItem-NTExtensions.h"

@implementation NTLazyMenu

@synthesize target;
@synthesize action;
@synthesize buildID;
@synthesize fontSize;
@synthesize iconSize;

+ (NTLazyMenu*)lazyMenu:(NSString*)title target:(id)target action:(SEL)action;
{
	NTLazyMenu *result = [[self alloc] initWithTitle:title ? title : @""];  // don't pass nil to initWithTitle
	
	[result setDelegate:result];
	[result setTarget:target];
	[result setAction:action];
	[result setAutoenablesItems:NO];
	[result setFontSize:kDefaultMenuFontSize];
	[result setIconSize:kDefaultMenuIconSize];

	return [result autorelease];
}

- (void)dealloc;
{
	[self setDelegate:nil];
	
	[super dealloc];	
}

- (id)copyWithZone:(NSZone *)zone;
{
	NTLazyMenu *copy = [super copyWithZone:zone];
	
	// must set delegate to self
	[copy setDelegate:copy];

	[copy setTarget:[self target]];
	[copy setAction:[self action]];
	[copy setBuildID:[self buildID]];
	[copy setFontSize:[self fontSize]];
	[copy setIconSize:[self iconSize]];

	return copy;
}

@end

@implementation NTLazyMenu (Protocols)

- (void)menuNeedsUpdate:(NSMenu*)menu;
{
	// subclass
}

@end

