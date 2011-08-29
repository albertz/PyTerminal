// -*- mode:objc -*-
// $Id: iTermApplication.m,v 1.10 2006/11/07 08:03:08 yfabian Exp $
//
/*
 **  iTermApplication.m
 **
 **  Copyright (c) 2002-2004
 **
 **  Author: Ujwal S. Setlur
 **
 **  Project: iTerm
 **
 **  Description: overrides sendEvent: so that key mappings with command mask  
 **				  are handled properly.
 **
 */

#import "iTermApplication.h"
#import "iTermController.h"
#import "PTYWindow.h"
#import "ITTerminalView.h"
#import "PTYSession.h"

@implementation iTermApplication

// override to catch key mappings
- (void)sendEvent:(NSEvent *)anEvent
{
	id aWindow;
	ITTerminalView *currentTerminal;
	PTYSession *currentSession;
	
		
	if ([anEvent type] == NSKeyDown)
	{
		
		aWindow = [self keyWindow];
		
		if ([aWindow isKindOfClass: [PTYWindow class]])
		{
						
			currentTerminal = [[iTermController sharedInstance] currentTerminal];
			currentSession = [currentTerminal currentSession];
			
			if ([currentSession hasKeyMappingForEvent: anEvent highPriority: YES])
				[currentSession keyDown: anEvent];
			else
				[super sendEvent: anEvent];
		}
		else
		   [super sendEvent: anEvent];

	}
	else
		[super sendEvent: anEvent];
}

@end
