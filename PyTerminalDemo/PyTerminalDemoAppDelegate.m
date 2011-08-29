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

#import <Python/Python.h>

// from Python/sysmodule.c
static int _check_and_flush (FILE *stream)
{
	int prev_fail = ferror (stream);
	return fflush (stream) || prev_fail ? EOF : 0;
}

@interface PyTerminalView : ITTerminalView
{
	int TTY_SLAVE;
}
- (void)addNewSession:(NSDictionary *)addressbookEntry
		  withCommand:(NSString *)command
			  withURL:(NSString*)url;
+ (void)_runPython:(PyTerminalView *)boss;
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

	// spawn a thread for Python
    [NSThread detachNewThreadSelector:@selector(_runPython:)
            	             toTarget:[PyTerminalView class]
						   withObject:self];
	
    [aSession release];
}

+ (void)_runPython:(PyTerminalView *)boss
{
	FILE* fp_in = fdopen(boss->TTY_SLAVE, "r");
	FILE* fp_out = fdopen(boss->TTY_SLAVE, "w");
	FILE* fp_err = fdopen(boss->TTY_SLAVE, "w");

    PyObject *sysin, *sysout, *syserr;
	sysin = PyFile_FromFile(fp_in, "<stdin>", "r", NULL);
    sysout = PyFile_FromFile(fp_out, "<stdout>", "w", _check_and_flush);
    syserr = PyFile_FromFile(fp_err, "<stderr>", "w", _check_and_flush);
    NSParameterAssert(!PyErr_Occurred());
	
	PySys_SetObject("stdin", sysin);
	PySys_SetObject("stdout", sysout);
	PySys_SetObject("stderr", syserr);
	
	PyRun_SimpleString("from time import time,ctime\n"
					   "print 'Today is',ctime(time())\n");

	{
		PyObject *v;
		v = PyImport_ImportModule("readline");
		if (v == NULL)
			PyErr_Clear();
		else
			Py_DECREF(v);
	}
	
    PyCompilerFlags cf;
	cf.cf_flags = 0;

	PyRun_AnyFileExFlags(fp_in, "<stdin>", 0, &cf);

	
	/*
	NSAutoreleasePool *arPool = [[NSAutoreleasePool alloc] init];;
    BOOL exitf = NO;
    int sts;
	int iterationCount = 0;
	char readbuf[4096];
	fd_set rfds,efds;
	
	iterationCount = 0; 
    while (exitf == NO) 
	{
		
		// periodically refresh our autorelease pool
		iterationCount++;			
		
		FD_ZERO(&rfds);
		FD_ZERO(&efds);
		
		FD_SET(boss->TTY_SLAVE, &rfds);
		FD_SET(boss->TTY_SLAVE, &efds);
		
		sts = select(boss->TTY_SLAVE + 1, &rfds, NULL, &efds, NULL);
		
		if (sts < 0) {
			break;
		}
		else if (FD_ISSET(boss->TTY_SLAVE, &efds)) {
			sts = read(boss->TTY_SLAVE, readbuf, 1);
			if (sts == 0) {
				// session close
				exitf = YES;
			}
		}
		else if (FD_ISSET(boss->TTY_SLAVE, &rfds)) {
			sts = read(boss->TTY_SLAVE, readbuf, sizeof(readbuf));
			
            if (sts == 0) 
			{
				exitf = YES;
            }
			
            if (sts > 1) {
                [boss setHasOutput: YES];
				[boss readTask:readbuf+1 length:sts-1];
            }
            else
                [boss setHasOutput: NO];
			
		}
		
		// periodically refresh our autorelease pool
		if ((iterationCount % 50) == 0)
		{
			[arPool release];
			arPool = [[NSAutoreleasePool alloc] init];
			iterationCount = 0;
		}
		
    }
	
	if (sts >= 0) 
        [boss brokenPipe];
	
	[arPool release];
	*/
 //   MPSignalSemaphore(boss->threadEndSemaphore);
	
	[NSThread exit];
}

@end

@implementation PyTerminalDemoAppDelegate

@synthesize window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	Py_Initialize();

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

- (void)applicationWillTerminate:(NSNotification *)notification
{
	Py_Finalize();
}

@end
