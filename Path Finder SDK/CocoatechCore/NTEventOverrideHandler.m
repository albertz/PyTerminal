//
//  NTEventOverrideHandler.m
//  CocoatechCore
//
//  Created by Steve Gehrman on 6/4/08.
//  Copyright 2008 Cocoatech. All rights reserved.
//

#import "NTEventOverrideHandler.h"
#import "NSDictionary-NTExtensions.h"

@implementation NTEventOverrideHandler

+ (NTEventOverrideHandler*)handler;
{
	NTEventOverrideHandler* result = [[NTEventOverrideHandler alloc] init];
	
	return [result autorelease];
}

- (BOOL)eventHandled:(NSEvent*)theEvent;
{
	BOOL handled = NO;
	
	if (([theEvent type] == NSKeyDown) || ([theEvent type] == NSKeyUp))
	{
		// make sure this isn't in japanese marked text mode
		NSTextView* editor = (NSTextView*) [[theEvent window] fieldEditor:NO forObject:nil];
		if (!editor || ![editor hasMarkedText])
		{			
			NSMutableDictionary *resultDict = [NSMutableDictionary dictionary];
			NSDictionary* userInfo = [NSDictionary dictionaryWithObjectsAndKeys:theEvent, @"event", resultDict, @"result", nil];
						
			// send notification to listening views in this window, check result if view handled key event
			[[NSNotificationCenter defaultCenter] postNotificationName:kNTEventOverrideHandlerNotification object:[theEvent window] userInfo:userInfo];
			
			// did reciever modify the client dict?
			handled = [resultDict boolForKey:@"handled"];
		}
	}
	
	return handled;
}

@end

