//
//  PyTerminalView.m
//  PyTerminal
//
//  Created by Albert Zeyer on 31.08.11.
//  Copyright 2011 Albert Zeyer. All rights reserved.
//

#import "PyTerminalView.h"

#import <iTerm/iTerm.h>
#import <iTerm/PTYSession.h>
#import <iTerm/PTYTask.h>
#import <iTerm/VT100Screen.h>
#import <iTerm/iTermTerminalProfileMgr.h>

#include <util.h> // openpty
#include <sys/ioctl.h>
#include <sys/socket.h> // socketpair

#import <Python/Python.h>
#include "py_raw_input.h"

#undef HAVE_CONFIG_H /* Else readline/chardefs.h includes strings.h */
#define READLINE_LIBRARY /* Hack: we are linking statically */
#include <readline.h>
#include <rlprivate.h>

@interface PyTerminalTask : NSObject
{
	@public int TTY_SLAVE;	
}
@end

@interface PyTerminalView : ITTerminalView
- (void)addNewSession:(NSDictionary *)addressbookEntry
		  withCommand:(NSString *)command
			  withURL:(NSString*)url;
- (void)_runPython:(PyTerminalTask *)task;
@end

// from Python/sysmodule.c
static int _check_and_flush (FILE *stream)
{
	int prev_fail = ferror (stream);
	return fflush (stream) || prev_fail ? EOF : 0;
}

@implementation PyTerminalTask
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
	_rl_set_screen_size(25, 80);
    int ret = openpty(&shell->FILDES, &task->TTY_SLAVE, ttyname, &term, &win);
	if(ret != 0) {
		fprintf(stderr, "PyTerminal: openpty failed: %s\n", strerror(errno));
		int fildes[2] = {-1,-1};
		ret = socketpair(AF_UNIX, SOCK_STREAM, 0, fildes);
		if(ret != 0) {
			fprintf(stderr, "PyTerminal: socketpair failed: %s\n", strerror(errno));
			return;
		}
		shell->FILDES = fildes[0];
		task->TTY_SLAVE = fildes[1];
	}
	
    int one = 1;
	int sts = ioctl(shell->FILDES, TIOCPKT, &one);
    if(sts < 0)
		fprintf(stderr, "PyTerminal: ioctl TIOCPKT failed: %s\n", strerror(errno));
	
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

static int32_t usedPythonInterpreterNum = 0;

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
	
	BOOL createdNewInterp = NO;
	PyThreadState* tstate = NULL;
	PyInterpreterState* interp = NULL;
	if(OSAtomicIncrement32(&usedPythonInterpreterNum) == 1) {
		interp = PyInterpreterState_Head();
		tstate = PyThreadState_New(interp);
		PyEval_AcquireThread(tstate);
	}
	else {
		PyEval_AcquireLock();
		createdNewInterp = YES;
		tstate = Py_NewInterpreter();
		interp = tstate->interp;
	}
	
    PyObject *sysin, *sysout, *syserr;
	sysin = PyFile_FromFile(fp_in, "<stdin>", "r", NULL);
    sysout = PyFile_FromFile(fp_out, "<stdout>", "w", _check_and_flush);
    syserr = PyFile_FromFile(fp_err, "<stderr>", "w", _check_and_flush);
    NSParameterAssert(!PyErr_Occurred());
	
	PySys_SetObject("stdin", sysin);
	PySys_SetObject("stdout", sysout);
	PySys_SetObject("stderr", syserr);
	
	overwritePyRawInput(interp->builtins);
	
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
	
	if(createdNewInterp) {
		Py_EndInterpreter(tstate);
		PyEval_ReleaseLock();
	}
	else
		PyEval_ReleaseThread(tstate);
	
	OSAtomicDecrement32(&usedPythonInterpreterNum);
	
	[pool release];
	[NSThread exit];
}

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
		initPython();
		
		// make sure this is initialized (yes goofy, I know)
		[iTermController sharedInstance];
		
		NSDictionary* dict = [[ITAddressBookMgr sharedInstance] defaultBookmarkData];

		[self setupView:dict];				
		[self addNewSession:dict withCommand:nil withURL:nil];
		
		// goofy hack to show window, ignore
		//[[self window] performSelector:@selector(showWindow) withObject:nil afterDelay:0];
	}
    
    return self;
}

@end

static BOOL _initedPython = NO;
void initPython() {
	if(_initedPython) return;
	if(!Py_IsInitialized()) {
		fprintf(stderr, "Python not initialized, initializing...\n");
		Py_InitializeEx(0);
		PyEval_InitThreads();
		PyEval_ReleaseThread(PyThreadState_Get()); // the main thread doesn't use Python; we would recreate it
	}
	else
		OSAtomicIncrement32(&usedPythonInterpreterNum); // it might be more but that doesn't matter
	_initedPython = YES;
}

NSView* allocPyTermialView() {
	return [PyTerminalView alloc];
}

