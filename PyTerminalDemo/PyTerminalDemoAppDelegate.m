//
//  PyTerminalDemoAppDelegate.m
//  PyTerminalDemo
//
//  Created by Albert Zeyer on 29.08.11.
//  Copyright 2011 Albert Zeyer. All rights reserved.
//

#import "PyTerminalDemoAppDelegate.h"
#import "PyTerminalView.h"

@implementation PyTerminalDemoAppDelegate

@synthesize window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	PyTerminalView* v = [PyTerminalView alloc];
	[v init];
    [v setAutoresizingMask: NSViewWidthSizable|NSViewHeightSizable];
	[v setFrame:[[window contentView] bounds]];
	[[window contentView] addSubview:v];
}

- (void)applicationWillTerminate:(NSNotification *)notification
{
}

@end
