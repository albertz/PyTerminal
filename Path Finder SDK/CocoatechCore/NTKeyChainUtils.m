//
//  NTKeyChainUtils.m
//  CocoatechCore
//
//  Created by Steve Gehrman on Tue May 14 2002.
//  Copyright (c) 2002 CocoaTech. All rights reserved.
//

#import "NTKeyChainUtils.h"
#import "NSString-Utilities.h"

@implementation NTKeyChainUtils

+ (NSString*)passwordForService:(NSString*)service accountName:(NSString*)accountName;
{	
	void *passwordData = nil;
	UInt32 passwordLength = 0;
	NSString* result=nil;
	SecKeychainItemRef itemRef = nil;

	OSStatus error = SecKeychainFindGenericPassword (NULL,          
													 strlen([service UTF8String]),          
													 [service UTF8String],  
													 strlen([accountName UTF8String]),             
													 [accountName UTF8String],  
													 &passwordLength,             
													 &passwordData,     
													 &itemRef);
	
	if (error == noErr)     
	{
		result = [NSString stringWithUTF8String:passwordData length:passwordLength];
		
		SecKeychainItemFreeContent(NULL, passwordData);
		
		if (itemRef)
			CFRelease(itemRef);
	}
	else if (error != errKCItemNotFound)  // normal error
		NSLog(@"SecKeychainFindGenericPassword error: %ld", error);
	
	return result;
}

@end
