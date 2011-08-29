// ITProcess.h
//
// Copyright (c) 2002 Aram Greenman. All rights reserved.
//
// Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
//
// 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
// 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
// 3. The name of the author may not be used to endorse or promote products derived from this software without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE AUTHOR "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#import <Foundation/NSObject.h>
#include <mach/mach_types.h>

/*!
@constant ITProcessValueUnknown
Indicates that the value of a statistic couldn't be determined. */
enum {
	ITProcessValueUnknown = 0xffffffff
};

/*!
@enum ITProcessState
Possible return values for -[ITProcess state].
@constant ITProcessStateUnknown			The state couldn't be determined.
@constant ITProcessStateRunnable		The process is runnable.
@constant ITProcessStateUninterruptible The process is in disk or other uninterruptible wait.
@constant ITProcessStateSleeping		The process has been sleeping for 20 seconds or less.
@constant ITProcessStateIdle			The process has been sleeping for more than 20 seconds.
@constant ITProcessStateSuspended		The process is suspended.
@constant ITProcessStateZombie			The process has exited but the parent has not yet waited for it.
@constant ITProcessStateExited			The process has exited.
*/
typedef enum _AGProcessState {
	ITProcessStateUnknown,
	ITProcessStateRunnable,
	ITProcessStateUninterruptible,
	ITProcessStateSleeping,
	ITProcessStateIdle,
	ITProcessStateSuspended,
	ITProcessStateZombie,
	ITProcessStateExited
} ITProcessState;

@class NSString, NSArray, NSDictionary;

/*!
@class ITProcess
@abstract A class for reporting Unix process statistics.
@discussion ITProcess is a class for reporting Unix process statistics. It is similar to NSProcessInfo except that it provides more information, and can represent any process, not just the current process. Additionally it provides methods for sending signals to processes. 

Instances are created with -initWithProcessIdentifier: or +processForProcessIdentifier:, but several convenience methods exist for obtaining instances based on other information, the most useful being +currentProcess, +allProcesses, and +userProcess.

The level of information an ITProcess can return depends on the user's permission. In general, a user can obtain general information like the arguments or process ID for any process, but can only obtain CPU and memory usage statistics for their own processes, unless they are root. Also, no information is available after the process has exited except the process ID and the state (ITProcessStateZombie or ITProcessStateExited). Methods which return a numerical value will return ITProcessValueUnknown if the statistic can't be obtained. 
*/
@interface ITProcess : NSObject {
	int process;
	task_t task;
	NSString *command;
	NSString *annotation;
	NSArray *arguments;
	NSDictionary *environment;
}

/*!
@method initWithProcessIdentifier:
Initializes the receiver with the given process identifier. Returns nil if no such process exists. */
- (id)initWithProcessIdentifier:(int)pid;

- (task_t)task;

/*!
@method currentProcess
Returns the current process. */
+ (ITProcess *)currentProcess;

/*!
@method allProcesses
Returns an array of all processes. */
+ (NSArray *)allProcesses;

/*!
@method userProcesses
Returns an array of all processes running for the current user. */
+ (NSArray *)userProcesses;

/*!
@method processForProcessIdentifier:
Returns the process for the given process identifier, or nil if no such process exists. */
+ (ITProcess *)processForProcessIdentifier:(int)pid;

/*!
@method processesForProcessGroup:
Returns an array of all processes in the given process group. */
+ (NSArray *)processesForProcessGroup:(int)pgid;

/*!
@method processesForTerminal:
Returns an array of all processes running on the given terminal. Takes a terminal device number. */
+ (NSArray *)processesForTerminal:(int)tdev;

/*!
@method processesForUser:
Returns an array of all processes for the given user. */
+ (NSArray *)processesForUser:(int)uid;

/*!
@method processesForRealUser:
Returns an array of all processes for the given real user. */
+ (NSArray *)processesForRealUser:(int)ruid;

/*!
@method processForCommand:
Returns the process for the given command, or nil if no such process exists. If there is more than one process with the same command, there is no guarantee which will be returned. */
+ (ITProcess *)processForCommand:(NSString *)comm;

/*!
@method processesForCommand:
Returns an array of all processes for the given command. */
+ (NSArray *)processesForCommand:(NSString *)comm;

/*!
@method processIdentifier
Returns the process identifier. */
- (int)processIdentifier;

/*!
@method parentProcessIdentifier
Returns the parent process identifier. */
- (int)parentProcessIdentifier;

/*!
@method processGroup
Returns the process group. */
- (int)processGroup;

/*!
@method terminal
Returns the terminal device number. */
- (int)terminal;

/*!
@method terminalProcessGroup
Returns the terminal process group. */
- (int)terminalProcessGroup;

/*!
@method userIdentifier
Returns the user identifier. */
- (int)userIdentifier;

/*!
@method realUserIdentifier
Returns the real user identifier. */
- (int)realUserIdentifier;

/*!
@method percentCPUUsage
Returns the current CPU usage in the range 0.0 - 1.0. */
- (double)percentCPUUsage;

/*!
@method totalCPUTime
Returns the accumulated CPU time in seconds. */
- (double)totalCPUTime;

/*!
@method userCPUTime
Returns the accumulated user CPU time in seconds. */
- (double)userCPUTime;

/*!
@method systemCPUTime
Returns the accumulated system CPU time in seconds. */
- (double)systemCPUTime;

/*!
@method state
Returns the current state. Possible values are defined by ITProcessState. */
- (ITProcessState)state;

/*!
@method priority
Returns the current priority. */
- (int)priority;

/*!
@method basePriority
Returns the base priority. */
- (int)basePriority;

/*!
@method threadCount
Returns the number of threads. */
- (int)threadCount;

/*!
@method command
Attempts to return the command that was called to execute the process. If that fails, attempts to return the accounting name. If that fails, returns an empty string. */
- (NSString *)command;

/*!
@method annotation
Returns an annotation that can be used to distinguish multiple instances of a process name. The current implementation does this by examining the command line arguments for "DashboardClient" and "java" processes. If there is no annotation, the method returns nil. */
- (NSString *)annotation;

/*!
@method annotatedCommand
Returns a composite string consisting of the command name and its annotation */
- (NSString *)annotatedCommand;

/*!
@method arguments
Returns an array containing the command line arguments called to execute the process. This method is not perfectly reliable. */
- (NSArray *)arguments;

/*!
@method environment
Returns a dictionary containing the environment variables of the process. This method is not perfectly reliable. */
- (NSDictionary *)environment;

/*!
@method parent
Returns the parent process. */
- (ITProcess *)parent;

/*!
@method children
Returns an array containing the process's children, if any. */
- (NSArray *)children;

/*!
@method siblings
Returns an array containing the process's siblings, if any. */
- (NSArray *)siblings;

@end

@interface ITProcess (Signals)

/*!
@method suspend
Sends SIGSTOP. */
- (BOOL)suspend;

/*!
@method resume
Sends SIGCONT. */
- (BOOL)resume;

/*!
@method interrupt
Sends SIGINT. */
- (BOOL)interrupt;

/*!
@method terminate
Sends SIGTERM. */
- (BOOL)terminate;

/*
@method kill:
Sends the given signal, see man 3 signal for possible values. Returns NO if the signal couldn't be sent. */
- (BOOL)kill:(int)signal;

@end

@interface ITProcess (MachTaskEvents)

/*!
@method faults
Returns the number of page faults. */
- (int)faults;

/*!
@method pageins
Returns the number of pageins. */
- (int)pageins;

/*!
@method copyOnWriteFaults
Returns the number of copy on write faults. */
- (int)copyOnWriteFaults;

/*!
@method messagesSent
Returns the number of Mach messages sent. */
- (int)messagesSent;

/*!
@method messagesReceived
Returns the number of Mach messages received. */
- (int)messagesReceived;

/*!
@method machSystemCalls
Returns the number of Mach system calls. */
- (int)machSystemCalls;

/*!
@method unixSystemCalls
Returns the number of Unix system calls. */
- (int)unixSystemCalls;

/*!
@method contextSwitches
Returns the number of context switches. */
- (int)contextSwitches;

@end
