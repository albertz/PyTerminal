//
//  NTSynchronousTaskRunner.h
//  CocoatechCore
//
//  Created by Steve Gehrman on 8/31/09.
//  Copyright 2009 Cocoatech. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class NTSynchronousTaskRunner;

@protocol NTSynchronousTaskRunnerDelegateProtocol <NSObject>
- (void)task_handleTask:(NTSynchronousTaskRunner*)task output:(NSData*)output;
- (void)task_handleTask:(NTSynchronousTaskRunner*)task errors:(NSData*)output;
- (void)task_handleTask:(NTSynchronousTaskRunner*)task finished:(NSNumber*)result;
@end

@interface NTSynchronousTaskRunner : NSObject
{
	id<NTSynchronousTaskRunnerDelegateProtocol> delegate;
	
	NSString* toolPath;
	NSString* currentDirectory;
	NSArray* args; 
	NSData* input;
	
	NSData* resultOutput;
	NSData* resultErrors;
	NSNumber* result;
	BOOL finished;
}

+ (NTSynchronousTaskRunner*)taskRunner:(id<NTSynchronousTaskRunnerDelegateProtocol>)theDelegate;

- (void)runTask:(NSString*)toolPath 
	  directory:(NSString*)currentDirectory 
	   withArgs:(NSArray*)args 
		  input:(NSData*)input;

- (void)clearDelegate;

- (BOOL)isRunning;
@end

