//
//  PyTerminalDemoAppDelegate.m
//  PyTerminalDemo
//
//  Created by Albert Zeyer on 29.08.11.
//  Copyright 2011 Albert Zeyer. All rights reserved.
//

#import "PyTerminalDemoAppDelegate.h"
#import <iTerm/iTerm.h>
#import <iTerm/PTYSession.h>
#import <iTerm/PTYTask.h>
#import <iTerm/VT100Screen.h>
#import <iTerm/iTermTerminalProfileMgr.h>

#include <util.h> // openpty
#include <sys/ioctl.h>

@interface PyTerminalView : ITTerminalView
{
	int TTY_SLAVE;
}
- (void)addNewSession:(NSDictionary *)addressbookEntry
		  withCommand:(NSString *)command
			  withURL:(NSString*)url;
@end

@implementation PyTerminalView
// overwrite
- (void)addNewSession:(NSDictionary *)addressbookEntry
		  withCommand:(NSString *)command
			  withURL:(NSString*)url
{
    PTYSession *aSession;
	
    // Initialize a new session
    aSession = [[PTYSession alloc] init];
	[[aSession SCREEN] setScrollback:[[iTermTerminalProfileMgr singleInstance] scrollbackLinesForProfile: [addressbookEntry objectForKey: KEY_TERMINAL_PROFILE]]];
	
	// set our preferences
    [aSession setAddressBookEntry: addressbookEntry];
	
    // Add this session to our term and make it current
    [self appendSession: aSession];
	
	NSString *pwd;
	pwd = [addressbookEntry objectForKey: KEY_WORKING_DIRECTORY];
	if ([pwd length] <= 0)
		pwd = NSHomeDirectory();
    NSDictionary *env=[NSDictionary dictionaryWithObject: pwd forKey:@"PWD"];
    
    [self setCurrentSessionName:[addressbookEntry objectForKey: KEY_NAME]];	
    
	PTYSession* curSession = [self currentSession];
	PTYTask* shell = [curSession SHELL];
	VT100Screen* screen = [curSession SCREEN];
	
	// see shell.launchWithPath for reference.
	if(0)
    [shell launchWithPath:nil
				arguments:nil
			  environment:env
					width:[screen width]
				   height:[screen height]];
	
	struct termios term;
    struct winsize win;
    char ttyname[PATH_MAX];
	
    setup_tty_param(&term, &win, [screen width], [screen height]);
    int ret = openpty(&shell->FILDES, &TTY_SLAVE, ttyname, &term, &win);
	NSParameterAssert(ret == 0);

    int one = 1;
	int sts = ioctl(shell->FILDES, TIOCPKT, &one);
    NSParameterAssert(sts >= 0);
	
    shell->TTY = [[NSString stringWithUTF8String:ttyname] retain];
    NSParameterAssert(shell->TTY != nil);
	
	// spawn a thread to do the read task
    [NSThread detachNewThreadSelector:@selector(_processReadThread:)
            	             toTarget:[PTYTask class]
						   withObject:shell];

    [aSession release];
}
@end

@implementation PyTerminalDemoAppDelegate

@synthesize window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
/*	// make sure this is initialized (yes goofy, I know)
 	[iTermController sharedInstance];
	
	NSDictionary* dict = [[ITAddressBookMgr sharedInstance] defaultBookmarkData];
	ITTerminalView* term = [ITTerminalView view:dict];
	
	[term setFrame:[[window contentView] bounds]];
	
	[[window contentView] addSubview:term];
	[term addNewSession:dict withCommand:nil withURL:nil];
	
	// goofy hack to show window, ignore
	[self performSelector:@selector(showWindow) withObject:nil afterDelay:0];
*/

	[iTermController sharedInstance];

	ITTerminalView* v = [PyTerminalView alloc];
	[v initWithFrame: NSMakeRect(0, 0, 100, 100)];
	[v setupView:nil];

    [v setAutoresizingMask: NSViewWidthSizable|NSViewHeightSizable];
	[v setFrame:[[window contentView] bounds]];
//	[v viewWillDraw];
	[[window contentView] addSubview:v];

//	[self performSelector:@selector(showWindow) withObject:nil afterDelay:0];

	[v addNewSession:nil withCommand:@"/bin/zsh" withURL:nil];
	//[v runCommand:@"/bin/bash"];
}

@end
