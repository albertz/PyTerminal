//
//  ITSharedActionHandler.m
//  iTerm
//
//  Created by Steve Gehrman on 2/4/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "ITSharedActionHandler.h"
#import "iTermProfileWindowController.h"
#import "PreferencePanel.h"
#import "ITConfigPanelController.h"

@implementation ITSharedActionHandler

+ (ITSharedActionHandler*)sharedInstance;
{
	static ITSharedActionHandler* shared=nil;
	
	if (!shared)
		shared = [[ITSharedActionHandler alloc] init];
	
	return shared;
}

- (IBAction)showConfigWindow:(id)sender;
{
	[ITConfigPanelController show];
}

- (void)showPreferencesAction:(id)sender;
{
	[[PreferencePanel sharedInstance] run];
}

- (void)showProfilesAction:(id)sender;
{
	[[iTermProfileWindowController sharedInstance] showProfilesWindow: nil];
}

@end

