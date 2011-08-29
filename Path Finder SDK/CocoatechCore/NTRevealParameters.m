//
//  NTRevealParameters.m
//  CocoatechCore
//
//  Created by Steve Gehrman on 8/13/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "NTRevealParameters.h"

@interface NTRevealParameters (hidden)
- (void)setOther:(NSDictionary *)theOther;
- (void)setTreatPackagesAsFolders:(BOOL)flag;
@end

@implementation NTRevealParameters

+ (NTRevealParameters*)params:(BOOL)treatPackagesAsFolders other:(NSDictionary*)other;
{
	NTRevealParameters* result = [[NTRevealParameters alloc] init];
	
	[result setTreatPackagesAsFolders:treatPackagesAsFolders];
	[result setOther:other];
	
	return [result autorelease];
}

//---------------------------------------------------------- 
// dealloc
//---------------------------------------------------------- 
- (void)dealloc
{
    [self setOther:nil];
    [super dealloc];
}

//---------------------------------------------------------- 
//  treatPackagesAsFolders 
//---------------------------------------------------------- 
- (BOOL)treatPackagesAsFolders
{
    return mTreatPackagesAsFolders;
}

- (void)setTreatPackagesAsFolders:(BOOL)flag
{
    mTreatPackagesAsFolders = flag;
}

//---------------------------------------------------------- 
//  other 
//---------------------------------------------------------- 
- (NSDictionary *)other
{
    return mOther; 
}

- (void)setOther:(NSDictionary *)theOther
{
    if (mOther != theOther)
    {
        [mOther release];
        mOther = [theOther retain];
    }
}

- (NSString*)description;
{
	return [NSString stringWithFormat:@"packagesAsFolders:%@ other:%@", [self treatPackagesAsFolders] ? @"YES" : @"NO", [[self other] description]];
}

@end
