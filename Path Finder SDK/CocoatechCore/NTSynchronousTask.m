//
//  NTSynchronousTask.m
//  CocoatechCore
//
//  Created by Steve Gehrman on 9/29/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "NTSynchronousTask.h"

@interface NTSynchronousTask ()
@property (nonatomic, retain) NSTask *task;
@property (nonatomic, retain) NSPipe *outputPipe;
@property (nonatomic, retain) NSPipe *inputPipe;
@property (nonatomic, retain) NSPipe *errorsPipe;
@property (nonatomic, retain) NSData *output;
@property (nonatomic, retain) NSData *errors;
@property (nonatomic, assign) BOOL done;
@property (nonatomic, assign) NSInteger result;
@end

@interface NTSynchronousTask (Private)
- (void)run:(NSString*)toolPath directory:(NSString*)currentDirectory withArgs:(NSArray*)args input:(NSData*)input;
@end

@implementation NTSynchronousTask

@synthesize task;
@synthesize outputPipe;
@synthesize inputPipe;
@synthesize errorsPipe;
@synthesize output;
@synthesize errors;
@synthesize done;
@synthesize result;

- (id)init;
{
    self = [super init];
		
	[self setTask:[[[NSTask alloc] init] autorelease]];
	[self setOutputPipe:[[[NSPipe alloc] init] autorelease]];
	[self setErrorsPipe:[[[NSPipe alloc] init] autorelease]];
	[self setInputPipe:[[[NSPipe alloc] init] autorelease]];
	
    [[self task] setStandardInput:[self inputPipe]];
    [[self task] setStandardOutput:[self outputPipe]];
    [[self task] setStandardError:[self errorsPipe]];
		
    return self;
}

//---------------------------------------------------------- 
// dealloc
//---------------------------------------------------------- 
- (void) dealloc
{
    self.task = nil;
    
	self.outputPipe = nil;
    self.errorsPipe = nil;
    self.inputPipe = nil;
	
    self.output = nil;
    self.errors = nil;
	
    [super dealloc];
}

+ (NSDictionary*)runTask:(NSString*)toolPath directory:(NSString*)currentDirectory withArgs:(NSArray*)args;
{
	return [self runTask:toolPath directory:currentDirectory withArgs:args input:nil];
}

+ (NSDictionary*)runTask:(NSString*)toolPath directory:(NSString*)currentDirectory withArgs:(NSArray*)args input:(NSData*)input;
{
	// we need this wacky pool here, otherwise we run out of pipes, the pipes are internally autoreleased
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSData* output=nil;
	NSData* errors=nil;
	NSInteger result = 0;
	
	@try {
		NTSynchronousTask* syncTask = [[NTSynchronousTask alloc] init];
		
		[syncTask run:toolPath directory:currentDirectory withArgs:args input:input];
		
		if ([syncTask result] == 0)
			output = [syncTask.output retain];

		errors = [syncTask.errors retain];
		result = [syncTask result];
		
		[syncTask release];
	}
	@catch (NSException * e) {
		NSLog(@"%@ : %@", NSStringFromClass(self), e);
	}
	@finally {
	}
	
	[pool release];

	// retained above
	[errors autorelease];
	[output autorelease];
		
	NSMutableDictionary* resultDictionary = [NSMutableDictionary dictionary];
	[resultDictionary setObject:[NSNumber numberWithInteger:result] forKey:@"result"];

	if (output)
		[resultDictionary setObject:output forKey:@"output"];
	if (errors)
		[resultDictionary setObject:errors forKey:@"errors"];
	
    return resultDictionary;
}

@end

@implementation NTSynchronousTask (Private)

- (void)run:(NSString*)toolPath directory:(NSString*)currentDirectory withArgs:(NSArray*)args input:(NSData*)input;
{	
	if (currentDirectory)
		[[self task] setCurrentDirectoryPath:currentDirectory];
	
	[[self task] setLaunchPath:toolPath];
	[[self task] setArguments:args];
	
	@try {
		[[self task] launch];
		
		if (input)
		{
			// feed the running task our input
			[[[self inputPipe] fileHandleForWriting] writeData:input];
			[[[self inputPipe] fileHandleForWriting] closeFile];
		}
		
		[self setOutput:[[[self outputPipe] fileHandleForReading] readDataToEndOfFile]];
		[self setErrors:[[[self errorsPipe] fileHandleForReading] readDataToEndOfFile]];

		[[self task] waitUntilExit];
		[self setResult:[[self task] terminationStatus]];
	}
	@catch (NSException * e) {
		NSLog(@"run:%@ : %@", NSStringFromClass([self class]), e);
	}
	@finally {
	}
}

@end
