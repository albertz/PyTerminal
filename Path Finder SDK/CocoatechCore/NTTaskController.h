//
//  NTTaskController.h
//  CocoatechCore
//
//  Created by sgehrman on Sun May 13 2001.
//  Copyright (c) 2001 CocoaTech. All rights reserved.
//

#import <Cocoa/Cocoa.h>

// to convert output data to a string
// NSString* outString = [[[NSString alloc] initWithData:output encoding:NSUTF8StringEncoding] autorelease];
@protocol NTTaskControllerDelegateProtocol <NSObject>
- (void)task_handleTask:(id)task output:(NSData*)output;
- (void)task_handleTask:(id)task errors:(NSData*)output;
- (void)task_handleTask:(id)task finished:(NSNumber*)result;
@end

// a tool can be run synchonously or asynchronously
@interface NTTaskController : NSObject
{
    id<NTTaskControllerDelegateProtocol> mDelegate;

    NSTask *_task;
    NSPipe *_outputPipe;
    NSPipe *_errorPipe;
    NSPipe *_inputPipe;
	NSArray* mv_modes;

    BOOL _result;
    BOOL _taskDone;
	BOOL mv_readTilEndOfFile;

    NSMutableData* outputCache;
    
    // used for tasks that generate lots of output very quickly (locate), buffer the output and send in larger chunks
    BOOL _delayedOutputProcessing;
    BOOL _bufferOutputToDelegateWithDelay;
}

@property (retain) NSMutableData *outputCache;

+ (NTTaskController*)task:(id<NTTaskControllerDelegateProtocol>)delegate;
- (id)initWithTaskDelegate:(id<NTTaskControllerDelegateProtocol>)delegate;
- (void)clearDelegate;  // must call clearDelegate

// pass nil for directory if not needed
- (void)runTask:(NSString*)toolPath directory:(NSString*)currentDirectory withArgs:(NSArray*)args;
- (void)runTask:(NSString*)toolPath directory:(NSString*)currentDirectory withArgs:(NSArray*)args input:(NSData*)input;

- (BOOL)taskResult;
- (BOOL)isRunning;
- (void)stopTask;

- (void)setBufferOutputToDelegateWithDelay:(BOOL)set;
- (BOOL)bufferOutputToDelegateWithDelay;
- (BOOL)readTilEndOfFile;
- (void)setReadTilEndOfFile:(BOOL)flag;

@end
