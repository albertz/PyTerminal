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
#include "py_raw_input.h"

// from Python/sysmodule.c
static int _check_and_flush (FILE *stream)
{
	int prev_fail = ferror (stream);
	return fflush (stream) || prev_fail ? EOF : 0;
}

@interface PyTerminalTask : NSObject
{
	@public int TTY_SLAVE;	
}
@end

@implementation PyTerminalTask
@end

@interface PyTerminalView : ITTerminalView
- (void)addNewSession:(NSDictionary *)addressbookEntry
		  withCommand:(NSString *)command
			  withURL:(NSString*)url;
- (void)_runPython:(PyTerminalTask *)task;
@end

@implementation PyTerminalView
// overwrite
- (void)addNewSession:(NSDictionary *)addressbookEntry
		  withCommand:(NSString *)command
			  withURL:(NSString*)url
{
    // Initialize a new session
    PTYSession* aSession = [[PTYSession alloc] init];
	[[aSession SCREEN] setScrollback:[[iTermTerminalProfileMgr singleInstance] scrollbackLinesForProfile: [addressbookEntry objectForKey: KEY_TERMINAL_PROFILE]]];
	
	// set our preferences
    [aSession setAddressBookEntry: addressbookEntry];
	
    // Add this session to our term and make it current
    [self appendSession: aSession];
	    
    [self setCurrentSessionName:[addressbookEntry objectForKey: KEY_NAME]];	
    
	PTYTask* shell = [aSession SHELL];
	VT100Screen* screen = [aSession SCREEN];
	
	// see shell.launchWithPath for reference.
	
	struct termios term;
    struct winsize win;
    char ttyname[PATH_MAX];
	
	PyTerminalTask* task = [[PyTerminalTask alloc] init];
    setup_tty_param(&term, &win, [screen width], [screen height]);
    int ret = openpty(&shell->FILDES, &task->TTY_SLAVE, ttyname, &term, &win);
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
            	             toTarget:self
						   withObject:task];
	
    [aSession release];
}

- (void)_runPython:(PyTerminalTask *)task
{
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	[[NSThread currentThread] setName:@"runPython"];

	FILE* fp_in = fdopen(task->TTY_SLAVE, "r");
	FILE* fp_out = fdopen(task->TTY_SLAVE, "w");
	FILE* fp_err = fdopen(task->TTY_SLAVE, "w");
	setbuf(fp_in,  (char *)NULL);
	setbuf(fp_out, (char *)NULL);
	setbuf(fp_err, (char *)NULL);

	PyEval_AcquireLock();
	PyThreadState* tstate = Py_NewInterpreter();
	//PyThreadState* saved_tstate = PyThreadState_Swap(tstate);
	
    PyObject *sysin, *sysout, *syserr;
	sysin = PyFile_FromFile(fp_in, "<stdin>", "r", NULL);
    sysout = PyFile_FromFile(fp_out, "<stdout>", "w", _check_and_flush);
    syserr = PyFile_FromFile(fp_err, "<stderr>", "w", _check_and_flush);
    NSParameterAssert(!PyErr_Occurred());
	
	PySys_SetObject("stdin", sysin);
	PySys_SetObject("stdout", sysout);
	PySys_SetObject("stderr", syserr);
	
	overwritePyRawInput(tstate->interp->builtins);
	
	PyRun_SimpleString(
		"import sys\n"
		"sys.argv = []\n"
		"from IPython.Shell import IPShellEmbed,IPShell\n"
		"ipshell = IPShell(argv=[])\n"
		"ipshell.mainloop()\n"
	);
    
	PyCompilerFlags cf;
	cf.cf_flags = 0;

	// We cannot use PyRun_InteractiveLoopFlags because in Python/Parser/tokenizer.c,
	// there is `PyOS_Readline(stdin, stdout, tok->prompt)` hardcoded, so it ignores our fp_in.
	//PyRun_InteractiveLoopFlags(fp_in, "<stdin>", &cf);
	
	Py_EndInterpreter(tstate);
	[pool release];
	[NSThread exit];
}

@end

@implementation PyTerminalDemoAppDelegate

@synthesize window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	Py_InitializeEx(0);
	PyEval_InitThreads();
	PyEval_ReleaseLock(); // the main thread doesn't use Python
	
	// make sure this is initialized (yes goofy, I know)
	[iTermController sharedInstance];

	NSDictionary* dict = [[ITAddressBookMgr sharedInstance] defaultBookmarkData];
	//ITTerminalView* v = [ITTerminalView view:dict];

	ITTerminalView* v = [PyTerminalView alloc];
	[v init];
	[v setupView:dict];

    [v setAutoresizingMask: NSViewWidthSizable|NSViewHeightSizable];
	[v setFrame:[[window contentView] bounds]];
	[[window contentView] addSubview:v];

	[v addNewSession:dict withCommand:nil withURL:nil];

	// goofy hack to show window, ignore
	[self performSelector:@selector(showWindow) withObject:nil afterDelay:0];
}

- (void)applicationWillTerminate:(NSNotification *)notification
{
	//PyEval_AcquireLock();
	//Py_Finalize();
}

@end
