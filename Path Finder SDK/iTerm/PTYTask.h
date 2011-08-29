// -*- mode:objc -*-
// $Id: PTYTask.h,v 1.10 2006/11/23 02:08:04 yfabian Exp $
/*
 **  PTYTask.h
 **
 **  Copyright (c) 2002, 2003
 **
 **  Author: Fabian, Ujwal S. Setlur
 **	     Initial code by Kiichi Kusama
 **
 **  Project: iTerm
 **
 **  Description: Implements the interface to the pty session.
 **
 */

/*
  Delegate
      readTask:
      brokenPipe
*/

#import <Foundation/Foundation.h>

@interface PTYTask : NSObject
{
    pid_t PID;
    int FILDES;
    int STATUS;
    id DELEGATEOBJECT;
    NSString *TTY;
    NSString *PATH;

    NSString *LOG_PATH;
    NSFileHandle *LOG_HANDLE;
    BOOL hasOutput;
    BOOL firstOutput;

    MPSemaphoreID threadEndSemaphore;
}

- (id)init;
- (void)dealloc;

- (void)launchWithPath:(NSString *)progpath
	     arguments:(NSArray *)args
	   environment:(NSDictionary *)env
		 width:(int)width
		height:(int)height;

- (void)setDelegate:(id)object;
- (id)delegate;

- (void)doIdleTasks;
- (void)readTask:(char *)buf length:(int)length;
- (void)writeTask:(NSData *)data;
- (void)brokenPipe;
- (void)sendSignal:(int)signo;
- (void)setWidth:(int)width height:(int)height;
- (pid_t)pid;
- (int)wait;
- (void)stop;
- (int)status;
- (NSString *)tty;
- (NSString *)path;
- (BOOL)loggingStartWithPath:(NSString *)path;
- (void)loggingStop;
- (BOOL)logging;
- (BOOL) hasOutput;
- (void)setHasOutput: (BOOL) flag;
- (BOOL) firstOutput;
- (void)setFirstOutput: (BOOL) flag;

- (NSString *)description;

@end
