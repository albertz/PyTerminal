//
//  NTSynchronousTask.h
//  CocoatechCore
//
//  Created by Steve Gehrman on 9/29/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NTSynchronousTask : NSObject
{
    NSTask *task;
	
    NSPipe *outputPipe;
    NSPipe *errorsPipe;
    NSPipe *inputPipe;
	
	NSData* output;
	NSData* errors;
	
	BOOL done;
	NSInteger result;
}

// pass nil for directory if not needed
// returns the result dictionary (result, output, errors)
+ (NSDictionary*)runTask:(NSString*)toolPath directory:(NSString*)currentDirectory withArgs:(NSArray*)args;
+ (NSDictionary*)runTask:(NSString*)toolPath directory:(NSString*)currentDirectory withArgs:(NSArray*)args input:(NSData*)input;

@end
