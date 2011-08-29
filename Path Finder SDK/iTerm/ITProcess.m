
#import "ITProcess.h"
#import <Foundation/Foundation.h>
#include <mach/mach_host.h>
#include <mach/mach_port.h>
#include <mach/mach_traps.h>
#include <mach/task.h>
#include <mach/thread_act.h>
#include <mach/vm_map.h>
#include <sys/param.h>
#include <sys/sysctl.h>
#include <sys/types.h>
#include <signal.h>
#include <unistd.h>

static int argument_buffer_size;
static int major_version;
static int minor_version;
static int update_version;

// call this before any of the ITGetMach... functions
// sets the correct split library segment for running kernel
// should work at least through Darwin 6.6 (Mac OS X 10.2.6)
static kern_return_t
ITMachStatsInit() {
	int mib[2];
	size_t len = 256;
	char rel[len];
	
	// get the OS version and set the correct split library segment for the kernel
	mib[0] = CTL_KERN;
	mib[1] = KERN_OSRELEASE;

	if (sysctl(mib, 2, &rel, &len, NULL, 0) < 0)
		return KERN_FAILURE;
	
	major_version = 0;
	minor_version = 0;
	update_version = 0;
	sscanf(rel, "%d.%d.%d", &major_version, &minor_version, &update_version);
	//NSLog(@"ITProcess: ITMacStatsInit: major_version = %d, minor_version = %d, update_version = %d", major_version, minor_version, update_version);
		
	// get the buffer size that will be large enough to hold the maximum arguments
	size_t	size = sizeof(argument_buffer_size);
	
	mib[0] = CTL_KERN;
	mib[1] = KERN_ARGMAX;

	if (sysctl(mib, 2, &argument_buffer_size, &size, NULL, 0) == -1) {
		//NSLog(@"ITProcess: ITMachStatsInit: using default for argument_buffer_size");
		argument_buffer_size = 4096; // kernel failed to provide the maximum size, use a default of 4K
	}
	if (major_version < 7) // kernel version < 7.0 (Mac OS X 10.3 - Panther)
	{
		if (argument_buffer_size > 8192) {
			//NSLog(@"ITProcess: ITMachStatsInit: adjusting argument_buffer_size = %d", argument_buffer_size);
			argument_buffer_size = 8192; // avoid a kernel bug and use a maximum of 8K
		}
	}
	
	//NSLog(@"ITProcess: ITMachStatsInit: argument_buffer_size = %d", argument_buffer_size);

	return KERN_SUCCESS;
}

static kern_return_t
ITGetMachThreadCPUUsage(thread_t thread, double *user_time, double *system_time, double *percent) {
	kern_return_t error;
	struct thread_basic_info th_info;
	mach_msg_type_number_t th_info_count = THREAD_BASIC_INFO_COUNT;
	
	if ((error = thread_info(thread, THREAD_BASIC_INFO, (thread_info_t)&th_info, &th_info_count)) != KERN_SUCCESS)
		return error;
	
	if (user_time != NULL) *user_time = th_info.user_time.seconds + th_info.user_time.microseconds / 1e6;
	if (system_time != NULL) *system_time = th_info.system_time.seconds + th_info.system_time.microseconds / 1e6;
	if (percent != NULL) *percent = (double)th_info.cpu_usage / TH_USAGE_SCALE;
	
	return error;
}

static kern_return_t
ITGetMachTaskCPUUsage(task_t task, double *user_time, double *system_time, double *percent) {
	kern_return_t error;
	struct task_basic_info t_info;
	thread_array_t th_array;
	mach_msg_type_number_t t_info_count = TASK_BASIC_INFO_COUNT, th_count;
	mach_msg_type_number_t i;
	double my_user_time = 0, my_system_time = 0, my_percent = 0;
	
	if ((error = task_info(task, TASK_BASIC_INFO, (task_info_t)&t_info, &t_info_count)) != KERN_SUCCESS)
		return error;
	if ((error = task_threads(task, &th_array, &th_count)) != KERN_SUCCESS)
		return error;
	
	// sum time for live threads
	for (i = 0; i < th_count; i++) {
		double th_user_time, th_system_time, th_percent;
		if ((error = ITGetMachThreadCPUUsage(th_array[i], &th_user_time, &th_system_time, &th_percent)) != KERN_SUCCESS)
			break;
		my_user_time += th_user_time;
		my_system_time += th_system_time;
		my_percent += th_percent;
	}
	
	// destroy thread array
	for (i = 0; i < th_count; i++)
		mach_port_deallocate(mach_task_self(), th_array[i]);
	vm_deallocate(mach_task_self(), (vm_address_t)th_array, sizeof(thread_t) * th_count);
	
	// check last error
	if (error != KERN_SUCCESS)
		return error;
	
	// add time for dead threads
	my_user_time += t_info.user_time.seconds + t_info.user_time.microseconds / 1e6;
	my_system_time += t_info.system_time.seconds + t_info.system_time.microseconds / 1e6;
	
	if (user_time != NULL) *user_time = my_user_time;
	if (system_time != NULL) *system_time = my_system_time;
	if (percent != NULL) *percent = my_percent;
		
	return error;
}

static kern_return_t
ITGetMachThreadPriority(thread_t thread, int *current_priority, int *base_priority) {
	kern_return_t error;
	struct thread_basic_info th_info;
	mach_msg_type_number_t th_info_count = THREAD_BASIC_INFO_COUNT;
	int my_current_priority = 0;
	int my_base_priority = 0;
	
	if ((error = thread_info(thread, THREAD_BASIC_INFO, (thread_info_t)&th_info, &th_info_count)) != KERN_SUCCESS)
		return error;
	
	switch (th_info.policy) {
	case POLICY_TIMESHARE: {
		struct policy_timeshare_info pol_info;
		mach_msg_type_number_t pol_info_count = POLICY_TIMESHARE_INFO_COUNT;
		
		if ((error = thread_info(thread, THREAD_SCHED_TIMESHARE_INFO, (thread_info_t)&pol_info, &pol_info_count)) != KERN_SUCCESS)
			return error;
		my_current_priority = pol_info.cur_priority;
		my_base_priority = pol_info.base_priority;
		break;
	} case POLICY_RR: {
		struct policy_rr_info pol_info;
		mach_msg_type_number_t pol_info_count = POLICY_RR_INFO_COUNT;
		
		if ((error = thread_info(thread, THREAD_SCHED_RR_INFO, (thread_info_t)&pol_info, &pol_info_count)) != KERN_SUCCESS)
			return error;
		my_current_priority = my_base_priority = pol_info.base_priority;
		break;
	} case POLICY_FIFO: {
		struct policy_fifo_info pol_info;
		mach_msg_type_number_t pol_info_count = POLICY_FIFO_INFO_COUNT;
		
		if ((error = thread_info(thread, THREAD_SCHED_FIFO_INFO, (thread_info_t)&pol_info, &pol_info_count)) != KERN_SUCCESS)
			return error;
		my_current_priority = my_base_priority = pol_info.base_priority;
		break;
	}
	}
	
	if (current_priority != NULL) *current_priority = my_current_priority;
	if (base_priority != NULL) *base_priority = my_base_priority;
		
	return error;
}

static kern_return_t
ITGetMachTaskPriority(task_t task, int *current_priority, int *base_priority) {
	kern_return_t error;
	thread_array_t th_array;
	mach_msg_type_number_t th_count;
	mach_msg_type_number_t i;
	int my_current_priority = 0, my_base_priority = 0;
	
	if ((error = task_threads(task, &th_array, &th_count)) != KERN_SUCCESS)
		return error;
	
	for (i = 0; i < th_count; i++) {
		int th_current_priority, th_base_priority;
		if ((error = ITGetMachThreadPriority(th_array[i], &th_current_priority, &th_base_priority)) != KERN_SUCCESS)
			break;
		if (th_current_priority > my_current_priority)
			my_current_priority = th_current_priority;
		if (th_base_priority > my_base_priority)
			my_base_priority = th_base_priority;
	}
	
	// destroy thread array
	for (i = 0; i < th_count; i++)
		mach_port_deallocate(mach_task_self(), th_array[i]);
	vm_deallocate(mach_task_self(), (vm_address_t)th_array, sizeof(thread_t) * th_count);
	
	// check last error
	if (error != KERN_SUCCESS)
		return error;
	
	if (current_priority != NULL) *current_priority = my_current_priority;
	if (base_priority != NULL) *base_priority = my_base_priority;
	
	return error;
}

static kern_return_t
ITGetMachThreadState(thread_t thread, int *state) {
	kern_return_t error;
	struct thread_basic_info th_info;
	mach_msg_type_number_t th_info_count = THREAD_BASIC_INFO_COUNT;
	int my_state;
	
	if ((error = thread_info(thread, THREAD_BASIC_INFO, (thread_info_t)&th_info, &th_info_count)) != KERN_SUCCESS)
		return error;
		
	switch (th_info.run_state) {
	case TH_STATE_RUNNING:
		my_state = ITProcessStateRunnable;
		break;
	case TH_STATE_UNINTERRUPTIBLE:
		my_state = ITProcessStateUninterruptible;
		break;
	case TH_STATE_WAITING:
		my_state = th_info.sleep_time > 20 ? ITProcessStateIdle : ITProcessStateSleeping;
		break;
	case TH_STATE_STOPPED:
		my_state = ITProcessStateSuspended;
		break;
	case TH_STATE_HALTED:
		my_state = ITProcessStateZombie;
		break;
	default:
		my_state = ITProcessStateUnknown;
	}
	
	if (state != NULL) *state = my_state;
	
	return error;
}

static kern_return_t
ITGetMachTaskState(task_t task, int *state) {
	kern_return_t error;
	thread_array_t th_array;
	mach_msg_type_number_t th_count;
	mach_msg_type_number_t i;
	int my_state = INT_MAX;
	
	if ((error = task_threads(task, &th_array, &th_count)) != KERN_SUCCESS)
		return error;
	
	for (i = 0; i < th_count; i++) {
		int th_state;
		if ((error = ITGetMachThreadState(th_array[i], &th_state)) != KERN_SUCCESS)
			break;
		// most active state takes precedence
		if (th_state < my_state)
			my_state = th_state;
	}
	
	// destroy thread array
	for (i = 0; i < th_count; i++)
		mach_port_deallocate(mach_task_self(), th_array[i]);
	vm_deallocate(mach_task_self(), (vm_address_t)th_array, sizeof(thread_t) * th_count);
	
	// check last error
	if (error != KERN_SUCCESS)
		return error;
		
	if (state != NULL) *state = my_state;
	
	return error;
}

static kern_return_t
ITGetMachTaskThreadCount(task_t task, int *count) {
	kern_return_t error;
	thread_array_t th_array;
	mach_msg_type_number_t th_count;
	mach_msg_type_number_t i;
	
	if ((error = task_threads(task, &th_array, &th_count)) != KERN_SUCCESS)
		return error;
	
	for (i = 0; i < th_count; i++)
		mach_port_deallocate(mach_task_self(), th_array[i]);
	vm_deallocate(mach_task_self(), (vm_address_t)th_array, sizeof(thread_t) * th_count);
	
	if (count != NULL) *count = th_count;
	
	return error;
}

static kern_return_t
ITGetMachTaskEvents(task_t task, int *faults, int *pageins, int *cow_faults, int *messages_sent, int *messages_received, int *syscalls_mach, int *syscalls_unix, int *csw) {
	kern_return_t error;
	task_events_info_data_t t_events_info;
	mach_msg_type_number_t t_events_info_count = TASK_EVENTS_INFO_COUNT;
	
	if ((error = task_info(task, TASK_EVENTS_INFO, (task_info_t)&t_events_info, &t_events_info_count)) != KERN_SUCCESS)
		return error;

	if (faults != NULL) *faults = t_events_info.faults;
	if (pageins != NULL) *pageins = t_events_info.pageins;
	if (cow_faults != NULL) *cow_faults = t_events_info.cow_faults;
	if (messages_sent != NULL) *messages_sent = t_events_info.messages_sent;
	if (messages_received != NULL) *messages_received = t_events_info.messages_received;
	if (syscalls_mach != NULL) *syscalls_mach = t_events_info.syscalls_mach;
	if (syscalls_unix != NULL) *syscalls_unix = t_events_info.syscalls_unix;
	if (csw != NULL) *csw = t_events_info.csw;
	
	return error;
}

@interface ITProcess (Private)
+ (NSArray *)processesForThirdLevelName:(int)name value:(int)value;
- (void)doProcargs;
@end

@implementation ITProcess (Private)
	
+ (NSArray *)processesForThirdLevelName:(int)name value:(int)value {
	ITProcess *proc;
	NSMutableArray *processes = [NSMutableArray array];
	int mib[4] = { CTL_KERN, KERN_PROC, name, value };
	struct kinfo_proc *info;
	size_t length;
	int level, count, i;
	
	// KERN_PROC_ALL has 3 elements, all others have 4
	level = name == KERN_PROC_ALL ? 3 : 4;
	
	if (sysctl(mib, level, NULL, &length, NULL, 0) < 0)
		return processes;
	if (!(info = NSZoneMalloc(NULL, length)))
		return processes;
	if (sysctl(mib, level, info, &length, NULL, 0) < 0) {
		NSZoneFree(NULL, info);
		return processes;
	}
	
	// number of processes
	count = length / sizeof(struct kinfo_proc);
		
	for (i = 0; i < count; i++) {
		if (proc = [[self alloc] initWithProcessIdentifier:info[i].kp_proc.p_pid])
		[processes addObject:proc];
		[proc release];
	}
	
	NSZoneFree(NULL, info);
	return processes;
}

- (void)doProcargs
{       
	id args = [NSMutableArray array];
	id env = [NSMutableDictionary dictionary];
	int mib[3];

	// make sure this is only executed once for an instance
	if (command)
		return;
	
	if (major_version >= 8) { // kernel version >= 8.0 (Mac OS X 10.4 - Tiger)
		// a newer sysctl selector is available -- it includes the number of arguments as an integer at the beginning of the buffer
		mib[0] = CTL_KERN;
		mib[1] = KERN_PROCARGS2;
		mib[2] = process;
	} else {
		// use the older sysctl selector -- the argument/environment boundary will be determined heuristically
		mib[0] = CTL_KERN;
		mib[1] = KERN_PROCARGS;
		mib[2] = process;
	}
	
	size_t length = argument_buffer_size;
	char *buffer = (char *)malloc(length);;
	
	BOOL parserFailure = NO;
	if (sysctl(mib, 3, buffer, &length, NULL, 0) == 0) {  
		char *cp;
		BOOL isFirstArgument = YES;
		BOOL createAnnotation = NO;
		
		int argumentCount;
		if (major_version >= 8) { // kernel version >= 8.0 (Mac OS X 10.4 - Tiger)
			memcpy(&argumentCount, buffer, sizeof(argumentCount));
			cp = buffer + sizeof(argumentCount);
		} else {
			cp = buffer;
			argumentCount = -1;
		}

		// skip the exec_path
		BOOL execPathFound = NO;
		for (; cp < buffer + length; cp++) {
			if (*cp == '\0') {
				execPathFound = YES;
				break;
			}
		}
		if (execPathFound) {
			// skip trailing '\0' characters
			BOOL argumentStartFound = NO;
			for (; cp < buffer + length; cp++) {
				if (*cp != '\0') {
					// beginning of first argument reached
					argumentStartFound = YES;
					break;
				}
			}
			if (argumentStartFound) {
				char *currentItem = cp;
				
				// get all arguments
				for (; cp < buffer + length; cp++) {
					if (*cp == '\0') {
						if (strlen(currentItem) > 0) {
							NSString *itemString = [NSString stringWithUTF8String:currentItem];
							if (itemString) {
								//NSLog(@"ITProcess: doProcArgs: itemString = %@", itemString);

								NSString *lastPathComponent = [itemString lastPathComponent];

								if (! [lastPathComponent isEqualToString:@"LaunchCFMApp"]) {
									if (isFirstArgument) {
										// save command
										command = lastPathComponent;
										isFirstArgument = NO;
										
										// these are the commands we will annotate
										if ([command isEqualToString:@"DashboardClient"]) {
											createAnnotation = YES;
										} else if ([command isEqualTo:@"java"]) {
											createAnnotation = YES;
										}
									} else {
										// the command argument is sometimes duplicated, ignore the duplicates (unless it
										//	is part of the bash shell's "_" environment variable)
										if ([itemString hasPrefix:@"_="] || (! [lastPathComponent isEqualToString:command])) {
											// add to the argument list
											[args addObject:itemString];
										}
										else
										{
											argumentCount--;
										}
										
										// check if we need to annotate
										if (createAnnotation && (! annotation)) {
											NSString *pathExtension = [itemString pathExtension];
											
											if ([pathExtension isEqualTo:@"wdgt"]) { // for DashboardClient
												annotation = [lastPathComponent stringByDeletingPathExtension];
											} else if ([pathExtension isEqualTo:@"jar"]) { // for java
												annotation = lastPathComponent;
											}
										}
									}
								} else {
									argumentCount--;
								}
							} else {
								//NSLog(@"ITProcess: doProcArgs: couldn't convert 0x%08x (0x%08x) [%d of %d] = '%s' (%d) to NSString", currentItem, buffer, currentItem - buffer, length, currentItem, currentItem);
							}
						}
							
						currentItem = cp + 1;
					}
				}
			} else {
				//NSLog(@"ITProcess: doProcArgs: start of argument list not found for pid = %d", process);
				parserFailure = YES;
			}
		} else {
			//NSLog(@"ITProcess: doProcArgs: exec_path not found for pid = %d", process);
			parserFailure = YES;
		}

		// extract environment variables from the argument list
		int index;
		if (argumentCount >= 0) {
			// we're using the newer sysctl selector, so use the argument count (less one for the command argument)
			int i;
			for (i = [args count] - 1; i >= (argumentCount - 1); i--) {
				NSString *string = [args objectAtIndex:i];
				index = [string rangeOfString:@"="].location;
				if (index != NSNotFound)
					[env setObject:[string substringFromIndex:index + 1] forKey:[string substringToIndex:index]];
			}
			args = [args subarrayWithRange:NSMakeRange(0, i + 1)];
		} else {
			// we're using the older sysctl selector, so we just guess by looking for an '=' in the argument
			int i;
			for (i = [args count] - 1; i >= 0; i--) {
				NSString *string = [args objectAtIndex:i];
				index = [string rangeOfString:@"="].location;
				if (index == NSNotFound)
					break;
				[env setObject:[string substringFromIndex:index + 1] forKey:[string substringToIndex:index]];
			}
			args = [args subarrayWithRange:NSMakeRange(0, i + 1)];
		}
	} else {
		parserFailure = YES;
	}
	
	if (parserFailure) {
		// probably caused by a zombie or exited process, but could also be bad data in the process arguments buffer
		// try to get the accounting name to partially recover from the error
		struct kinfo_proc info;
		length = sizeof(struct kinfo_proc);
		int mib4[4] = { CTL_KERN, KERN_PROC, KERN_PROC_PID, process };
		
		if (sysctl(mib4, 4, &info, &length, NULL, 0) < 0) {
			command = [[[NSString alloc] init] autorelease];
			//NSLog(@"ITProcess: doProcArgs: no command");
		} else {
			command = [[[NSString alloc] initWithCString:info.kp_proc.p_comm] autorelease];
			//NSLog(@"ITProcess: doProcArgs: info.kp_proc.p_comm = %s", info.kp_proc.p_comm);
		}
	}

	//NSLog(@"ITProcess: doProcArgs: command = '%@', annotation = '%@', args = %@, env = %@", command, annotation, [args description], [env description]);
	
	[command retain];
	[annotation retain];
		
	free(buffer);
	
	arguments = [args retain];
	environment = [env retain];
}    

@end

@implementation ITProcess

+ (void)initialize {
	ITMachStatsInit();
	[super initialize];
}

- (id)initWithProcessIdentifier:(int)pid {
	if (self = [super init]) {
		process = pid;
		if (task_for_pid(mach_task_self(), process, &task) != KERN_SUCCESS)
			task = MACH_PORT_NULL;
		if ([self state] == ITProcessStateExited) {
			[self release];
			return nil;
		}
	}
	return self;
}

+ (ITProcess *)currentProcess {
	return [self processForProcessIdentifier:getpid()];
}

+ (NSArray *)allProcesses {
	return [self processesForThirdLevelName:KERN_PROC_ALL value:0];
}

+ (NSArray *)userProcesses {
	return [self processesForUser:geteuid()];
}

+ (ITProcess *)processForProcessIdentifier:(int)pid {
	return [[[self alloc] initWithProcessIdentifier:pid] autorelease];
}
	
+ (NSArray *)processesForProcessGroup:(int)pgid {
	return [self processesForThirdLevelName:KERN_PROC_PGRP value:pgid];
}
	
+ (NSArray *)processesForTerminal:(int)tty {
	return [self processesForThirdLevelName:KERN_PROC_TTY value:tty];
}
	
+ (NSArray *)processesForUser:(int)uid {
	return [self processesForThirdLevelName:KERN_PROC_UID value:uid];
}
	
+ (NSArray *)processesForRealUser:(int)ruid {
	return [self processesForThirdLevelName:KERN_PROC_RUID value:ruid];
}
	
+ (NSArray *)processesForCommand:(NSString *)comm {
	NSArray *all = [self allProcesses];
	NSMutableArray *result = [NSMutableArray array];
	int i, count = [all count];
	for (i = 0; i < count; i++)
		if ([[[all objectAtIndex:i] command] isEqualToString:comm])
			[result addObject:[all objectAtIndex:i]];
	return result;
}
	
+ (ITProcess *)processForCommand:(NSString *)comm {
	NSArray *processes = [self processesForCommand:comm];
	if ([processes count])
		return [processes objectAtIndex:0];
	return nil;
}
	
- (int)processIdentifier {
	return process;
}

- (task_t)task;
{
	return task;
}

- (int)parentProcessIdentifier {
	struct kinfo_proc info;
	size_t length = sizeof(struct kinfo_proc);
	int mib[4] = { CTL_KERN, KERN_PROC, KERN_PROC_PID, process };
	if (sysctl(mib, 4, &info, &length, NULL, 0) < 0)
		return ITProcessValueUnknown;
	if (length == 0)
		return ITProcessValueUnknown;
	return info.kp_eproc.e_ppid;
}
	
- (int)processGroup {
	struct kinfo_proc info;
	size_t length = sizeof(struct kinfo_proc);
	int mib[4] = { CTL_KERN, KERN_PROC, KERN_PROC_PID, process };
	if (sysctl(mib, 4, &info, &length, NULL, 0) < 0)
		return ITProcessValueUnknown;
	if (length == 0)
		return ITProcessValueUnknown;
	return info.kp_eproc.e_pgid;
}
	
- (int)terminal {
	struct kinfo_proc info;
	size_t length = sizeof(struct kinfo_proc);
	int mib[4] = { CTL_KERN, KERN_PROC, KERN_PROC_PID, process };
	if (sysctl(mib, 4, &info, &length, NULL, 0) < 0)
		return ITProcessValueUnknown;
	if (length == 0 || info.kp_eproc.e_tdev == 0)
		return ITProcessValueUnknown;
	return info.kp_eproc.e_tdev;
}
	
- (int)terminalProcessGroup {
	struct kinfo_proc info;
	size_t length = sizeof(struct kinfo_proc);
	int mib[4] = { CTL_KERN, KERN_PROC, KERN_PROC_PID, process };
	if (sysctl(mib, 4, &info, &length, NULL, 0) < 0)
		return ITProcessValueUnknown;
	if (length == 0 || info.kp_eproc.e_tpgid == 0)
		return ITProcessValueUnknown;
	return info.kp_eproc.e_tpgid;
}

- (int)userIdentifier {
	struct kinfo_proc info;
	size_t length = sizeof(struct kinfo_proc);
	int mib[4] = { CTL_KERN, KERN_PROC, KERN_PROC_PID, process };
	if (sysctl(mib, 4, &info, &length, NULL, 0) < 0)
		return ITProcessValueUnknown;
	if (length == 0)
		return ITProcessValueUnknown;
	return info.kp_eproc.e_ucred.cr_uid;
}
	
- (int)realUserIdentifier {
	struct kinfo_proc info;
	size_t length = sizeof(struct kinfo_proc);
	int mib[4] = { CTL_KERN, KERN_PROC, KERN_PROC_PID, process };
	if (sysctl(mib, 4, &info, &length, NULL, 0) < 0)
		return ITProcessValueUnknown;
	if (length == 0)
		return ITProcessValueUnknown;
	return info.kp_eproc.e_pcred.p_ruid;
}
	
- (NSString *)command {
	[self doProcargs];
	return command;
}
	
- (NSString *)annotation {
	[self doProcargs];
	return annotation;
}
	
- (NSString *)annotatedCommand {
	[self doProcargs];
	if (annotation)
		return [NSString stringWithFormat:@"%@ (%@)", command, annotation];
	else
		return command;
}
	
- (NSArray *)arguments {
	[self doProcargs];
	return arguments;
}
	
- (NSDictionary *)environment {
	[self doProcargs];
	return environment;
}
	
- (ITProcess *)parent {
	return [[self class] processForProcessIdentifier:[self parentProcessIdentifier]];
}
	
- (NSArray *)children {
	NSArray *all = [[self class] allProcesses];
	NSMutableArray *children = [NSMutableArray array];
	int i, count = [all count];
	for (i = 0; i < count; i++)
		if ([[all objectAtIndex:i] parentProcessIdentifier] == process)
			[children addObject:[all objectAtIndex:i]];
	return children;
}
	
- (NSArray *)siblings {
	NSArray *all = [[self class] allProcesses];
	NSMutableArray *siblings = [NSMutableArray array];
	int i, count = [all count], ppid = [self parentProcessIdentifier];
	for (i = 0; i < count; i++) {
        ITProcess *p = [all objectAtIndex:i];
		if ([p parentProcessIdentifier] == ppid && [p processIdentifier] != process)
			[siblings addObject:p];
    }
	return siblings;
}
	
- (double)percentCPUUsage {
	double percent;
	if (ITGetMachTaskCPUUsage(task, NULL, NULL, &percent) != KERN_SUCCESS)
		return ITProcessValueUnknown;
	return percent;
}
	
- (double)totalCPUTime {
	double user, system;
	if (ITGetMachTaskCPUUsage(task, &user, &system, NULL) != KERN_SUCCESS)
		return ITProcessValueUnknown;
	return user + system;
}

- (double)userCPUTime {
	double user;
	if (ITGetMachTaskCPUUsage(task, &user, NULL, NULL) != KERN_SUCCESS)
		return ITProcessValueUnknown;
	return user;
}
	
- (double)systemCPUTime {
	double system;
	if (ITGetMachTaskCPUUsage(task, NULL, &system, NULL) != KERN_SUCCESS)
		return ITProcessValueUnknown;
	return system;
}    
		
- (ITProcessState)state {
	int state;
	struct kinfo_proc info;
	size_t length = sizeof(struct kinfo_proc);
	int mib[4] = { CTL_KERN, KERN_PROC, KERN_PROC_PID, process };
	if (sysctl(mib, 4, &info, &length, NULL, 0) < 0)
		return ITProcessStateExited;
	if (length == 0)
		return ITProcessStateExited;
	if (info.kp_proc.p_stat == SZOMB)
		return ITProcessStateZombie;
	if (ITGetMachTaskState(task, &state) != KERN_SUCCESS)
		return ITProcessStateUnknown;
	return state;
}
	
- (int)priority {
	int priority;
	if (ITGetMachTaskPriority(task, &priority, NULL) != KERN_SUCCESS)
		return ITProcessValueUnknown;
	return priority;
}

- (int)basePriority {
	int priority;
	if (ITGetMachTaskPriority(task, NULL, &priority) != KERN_SUCCESS)
		return ITProcessValueUnknown;
	return priority;
}
	
- (int)threadCount {
	int count;
	if (ITGetMachTaskThreadCount(task, &count) != KERN_SUCCESS)
		return ITProcessValueUnknown;
	return count;
} 
	
- (NSUInteger)hash {
	return process;
}
	
- (BOOL)isEqual:(id)object {
	if (![object isKindOfClass:[self class]])
		return NO;
	return process == [(ITProcess *)object processIdentifier];
}

- (NSString *)description {
	return [NSString stringWithFormat:@"%@ process = %d, task = %u, command = %@, arguments = %@, environment = %@", [super description], process, task, [self command], [[self arguments] description], [[self environment] description]];
}
	
- (void)dealloc {
	mach_port_deallocate(mach_task_self(), task);
	[command release];
	[arguments release];
	[environment release];
	[super dealloc];
}
	
@end

@implementation ITProcess (Signals)

- (BOOL)suspend {
	return [self kill:SIGSTOP];
}
	
- (BOOL)resume {
	return [self kill:SIGCONT];
}
	
- (BOOL)interrupt {
	return [self kill:SIGINT];
}
	
- (BOOL)terminate {
	return [self kill:SIGTERM];
}
	
- (BOOL)kill:(int)signal {
	return kill(process, signal) == 0;
}

@end

@implementation ITProcess (MachTaskEvents)

- (int)faults {
	int faults;
	if (ITGetMachTaskEvents(task, &faults, NULL, NULL, NULL, NULL, NULL, NULL, NULL) != KERN_SUCCESS)
		return ITProcessValueUnknown;
	return faults;
}

- (int)pageins {
	int pageins;
	if (ITGetMachTaskEvents(task, NULL, &pageins, NULL, NULL, NULL, NULL, NULL, NULL) != KERN_SUCCESS)
		return ITProcessValueUnknown;
	return pageins;
}

- (int)copyOnWriteFaults {
	int cow_faults;
	if (ITGetMachTaskEvents(task, NULL, NULL, &cow_faults, NULL, NULL, NULL, NULL, NULL) != KERN_SUCCESS)
		return ITProcessValueUnknown;
	return cow_faults;
}

- (int)messagesSent {
	int messages_sent;
	if (ITGetMachTaskEvents(task, NULL, NULL, NULL, &messages_sent, NULL, NULL, NULL, NULL) != KERN_SUCCESS)
		return ITProcessValueUnknown;
	return messages_sent;
}

- (int)messagesReceived {
	int messages_received;
	if (ITGetMachTaskEvents(task, NULL, NULL, NULL, NULL, &messages_received, NULL, NULL, NULL) != KERN_SUCCESS)
		return ITProcessValueUnknown;
	return messages_received;
}

- (int)machSystemCalls {
	int syscalls_mach;
	if (ITGetMachTaskEvents(task, NULL, NULL, NULL, NULL, NULL, &syscalls_mach, NULL, NULL) != KERN_SUCCESS)
		return ITProcessValueUnknown;
	return syscalls_mach;
}

- (int)unixSystemCalls {
	int syscalls_unix;
	if (ITGetMachTaskEvents(task, NULL, NULL, NULL, NULL, NULL, NULL, &syscalls_unix, NULL) != KERN_SUCCESS)
		return ITProcessValueUnknown;
	return syscalls_unix;
}

- (int)contextSwitches {
	int csw;
	if (ITGetMachTaskEvents(task, NULL, NULL, NULL, NULL, NULL, NULL, NULL, &csw) != KERN_SUCCESS)
		return ITProcessValueUnknown;
	return csw;
}
	
@end
