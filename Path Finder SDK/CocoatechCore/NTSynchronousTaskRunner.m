//
//  NTSynchronousTaskRunner.m
//  CocoatechCore
//
//  Created by Steve Gehrman on 8/31/09.
//  Copyright 2009 Cocoatech. All rights reserved.
//

#import "NTSynchronousTaskRunner.h"
#import "NTSynchronousTask.h"
#import "NSThread-NTExtensions.h"

@interface NTSynchronousTaskRunner ()
@property (nonatomic, assign) id<NTSynchronousTaskRunnerDelegateProtocol> delegate;
@property (nonatomic, retain) NSString *toolPath;
@property (nonatomic, retain) NSString *currentDirectory;
@property (nonatomic, retain) NSArray *args;
@property (nonatomic, retain) NSData *input;
@property (nonatomic, retain) NSData *resultOutput;
@property (nonatomic, retain) NSData *resultErrors;
@property (nonatomic, retain) NSNumber *result;
@property (nonatomic, assign) BOOL finished;
@end

@implementation NTSynchronousTaskRunner

@synthesize delegate;
@synthesize toolPath;
@synthesize currentDirectory;
@synthesize args;
@synthesize input;
@synthesize resultOutput;
@synthesize resultErrors;
@synthesize result, finished;

+ (NTSynchronousTaskRunner*)taskRunner:(id<NTSynchronousTaskRunnerDelegateProtocol>)theDelegate;
{
	NTSynchronousTaskRunner* result = [[NTSynchronousTaskRunner alloc] init];
	
	result.delegate = theDelegate;
	
	return [result autorelease];
}

//---------------------------------------------------------- 
// dealloc
//---------------------------------------------------------- 
- (void) dealloc
{
	if ([self delegate])
		[NSException raise:@"must call clearDelegate" format:@"%@", NSStringFromClass([self class])];

    self.toolPath = nil;
    self.currentDirectory = nil;
    self.args = nil;
    self.input = nil;
	
	self.resultOutput = nil;
    self.resultErrors = nil;
	self.result = nil;
	
    [super dealloc];
}

- (void)runTask:(NSString*)theToolPath 
	  directory:(NSString*)theCurrentDirectory 
	   withArgs:(NSArray*)theArgs 
		  input:(NSData*)theInput;
{
	self.toolPath = theToolPath;
    self.currentDirectory = theCurrentDirectory;
    self.args = theArgs;
    self.input = theInput;	
	
	[NSThread detachNewThreadSelector:@selector(threadProc) toTarget:self withObject:nil];
}	

- (void)clearDelegate;
{
	self.delegate = nil;
}

- (BOOL)isRunning;
{
	return !self.finished;
}

- (void)threadDoneOnMainTask;
{
	self.finished = YES;
	
	if ([self.resultOutput length])
		[self.delegate task_handleTask:self output:self.resultOutput];
	
	if ([self.resultErrors length])
		[self.delegate task_handleTask:self errors:self.resultErrors];
	
	[self.delegate task_handleTask:self finished:self.result];
}	

@end

@implementation NTSynchronousTaskRunner (Thread)

- (void)threadProc;
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	{
		NSDictionary* dict = [NTSynchronousTask runTask:self.toolPath directory:self.currentDirectory withArgs:self.args input:self.input];
		
		self.resultOutput = [dict objectForKey:@"output"];
		self.resultErrors = [dict objectForKey:@"errors"];
		self.result = [dict objectForKey:@"result"];
		
		[self performSelectorOnMainThread:@selector(threadDoneOnMainTask) withObject:nil];
	}
	[pool release];
	pool = nil;
}

@end
