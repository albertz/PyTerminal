//
//  NTMailDelivery.m
//  CocoatechCore
//
//  Created by Steve Gehrman on 2/12/10.
//  Copyright 2010 Cocoatech. All rights reserved.
//

#import "NTMailDelivery.h"


@implementation NTMailDelivery

+ (BOOL)deliverMessage:(NSString*)message subject:(NSString*)subject to:(NSString*)to;
{
	NSString* mailtoLink = [NSString
							stringWithFormat:@"mailto:%@?subject=%@&body=%@",to, subject, message];
	
	NSURL *url = [NSURL URLWithString:[mailtoLink stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	
	return [[NSWorkspace sharedWorkspace] openURL:url];
}

@end
