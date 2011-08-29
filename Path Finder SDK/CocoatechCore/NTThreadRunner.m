//
//  NTThreadRunner.m
//  CocoatechCore
//
//  Created by Steve Gehrman on 8/28/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "NTThreadRunner.h"
#import "NTThreadHelper.h"
#import "NSThread-NTExtensions.h"

@interface NTThreadRunnerParam (Private)
- (void)setRunner:(NTThreadRunner *)theRunner;
@end

@interface NTThreadRunner (Private)
- (id<NTThreadRunnerDelegateProtocol>)delegate;
- (void)setDelegate:(id<NTThreadRunnerDelegateProtocol>)theDelegate;

- (NTThreadHelper *)threadHelper;
- (void)setThreadHelper:(NTThreadHelper *)theThreadHelper;

- (CGFloat)priority;
- (void)setPriority:(CGFloat)thePriority;

- (void)setParam:(NTThreadRunnerParam *)theParam;

@end

@implementation NTThreadRunner

- (void)dealloc;
{
	if ([self delegate])
		[NSException raise:@"must call clearDelegate" format:@"%@", NSStringFromClass([self class])];
	
	[self setThreadHelper:nil];
	[self setParam:nil];

	[super dealloc];
}

- (void)clearDelegate; // also kills the thread
{
	if (![[self threadHelper] complete])
		[mv_threadHelper setKilled:YES];
	
	[self setDelegate:nil];
	
	// resume incase the thread is paused
	[[self threadHelper] resume];
}

- (NTThreadHelper*)threadHelper;
{
	return mv_threadHelper;
}

+ (NTThreadRunner*)thread:(NTThreadRunnerParam*)param
				 priority:(CGFloat)priority
				 delegate:(id<NTThreadRunnerDelegateProtocol>)delegate;
{
	NTThreadRunner* result = [[NTThreadRunner alloc] init];
	
	[result setDelegate:delegate];
	[result setPriority:priority];
	[result setThreadHelper:[NTThreadHelper threadHelper]];
	[result setParam:param];
		
	[NSThread detachNewThreadSelector:@selector(threadProc:) toTarget:result withObject:param];
	
	return [result autorelease];
}

//---------------------------------------------------------- 
//  param 
//---------------------------------------------------------- 
- (NTThreadRunnerParam *)param
{
    return mv_param; 
}

@end

@implementation NTThreadRunner (Thread)

- (void)threadProc:(NTThreadRunnerParam*)param;
{
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	
	[NSThread setThreadPriority:[self priority]];
	
	if ([param doThreadProc])
		[self performSelectorOnMainThread:@selector(mainThreadCallback) withObject:nil];
	
	[[self threadHelper] setComplete:YES];

	[pool release];
}

- (void)mainThreadCallback;
{
	[[self delegate] threadRunner_complete:self];
}

@end

@implementation NTThreadRunner (Private)

- (void)setParam:(NTThreadRunnerParam *)theParam
{
    if (mv_param != theParam) {
		[mv_param setRunner:nil];
		
        [mv_param release];
        mv_param = [theParam retain];
		
		[mv_param setRunner:self];
    }
}

//---------------------------------------------------------- 
//  delegate 
//---------------------------------------------------------- 
- (id<NTThreadRunnerDelegateProtocol>)delegate
{
    return mv_delegate; 
}

- (void)setDelegate:(id<NTThreadRunnerDelegateProtocol>)theDelegate
{
    if (mv_delegate != theDelegate) {
        mv_delegate = theDelegate;
    }
}

//---------------------------------------------------------- 
//  threadHelper 
//---------------------------------------------------------- 
- (NTThreadHelper *)threadHelper
{
    return mv_threadHelper; 
}

- (void)setThreadHelper:(NTThreadHelper *)theThreadHelper
{
    if (mv_threadHelper != theThreadHelper) {
        [mv_threadHelper release];
        mv_threadHelper = [theThreadHelper retain];
    }
}

//---------------------------------------------------------- 
//  priority 
//---------------------------------------------------------- 
- (CGFloat)priority
{
    return mv_priority;
}

- (void)setPriority:(CGFloat)thePriority
{
    mv_priority = thePriority;
}

@end

// ------------------------------------------------------------------------------------
// ------------------------------------------------------------------------------------

@implementation NTThreadRunnerParam 

- (void)dealloc;
{
	// threadRunner is cleared by the owning thread runner, it's not retained
	// [self setThreadRunner:nil];
	
	[super dealloc];
}

//---------------------------------------------------------- 
//  threadRunner 
//---------------------------------------------------------- 
- (NTThreadRunner *)runner
{
    return mv_runner; 
}

//---------------------------------------------------------- 
//  threadRunner 
//---------------------------------------------------------- 
- (NTThreadHelper *)helper
{
    return [[self runner] threadHelper]; 
}

- (id<NTThreadRunnerDelegateProtocol>)delegate;
{
	return [[self runner] delegate];
}

// must subclass to do work
- (BOOL)doThreadProc;
{
	return NO;
}

@end

@implementation NTThreadRunnerParam (Private)

- (void)setRunner:(NTThreadRunner *)theRunner
{
    if (mv_runner != theRunner) {
        mv_runner = theRunner;  // not retained, runner owns us
    }
}

@end
