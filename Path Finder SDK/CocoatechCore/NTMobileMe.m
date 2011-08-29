//
//  NTMobileMe.m
//  CocoatechCore
//
//  Created by Steve Gehrman on 2/13/10.
//  Copyright 2010 Cocoatech. All rights reserved.
//

#import "NTMobileMe.h"
#import "NTKeyChainUtils.h"

@implementation NTMobileMe

+ (NSString*)accountName;
{
    NSString* result=nil;
	
    NSDictionary *globalDomain = [[NSUserDefaults standardUserDefaults] persistentDomainForName:NSGlobalDomain];
	
    result = [globalDomain objectForKey:@"iToolsMember"];
	
	if ([result isKindOfClass:[NSString class]])
	{
		if (result && [result length])
			return result;
	}
	
    return nil;
}

+ (NSString*)accountPassword;
{
    NSString* result=nil;
    NSString* accoutName = [self accountName];
	
    if (accoutName)
        result = [NTKeyChainUtils passwordForService:@"iTools" accountName:accoutName];
	
	if ([result isKindOfClass:[NSString class]])
	{
		if (result && [result length])
			return result;
	}
	
    return result;
}

@end
