//
//  NSObject-Dispatch.h
//  CocoatechCore
//
//  Created by Steve Gehrman on 1/28/10.
//  Copyright 2010 Cocoatech. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSObject (Dispatch)

// mode: -1, 0, 1 (low, default, high)
- (void)dispatch:(NSInteger)mode thread:(SEL)thread main:(SEL)main param:(id)param;
- (void)dispatchAfter:(NSTimeInterval)after mode:(NSInteger)mode thread:(SEL)thread main:(SEL)main param:(id)param;

@end

/*
 // example
 
 - (void)doSomethingAsync;
 {
 [self dispatch:0 thread:@selector(worker:) main:@selector(worker_result:) param:@"mutha"];
 }
 
 - (id)worker:(id)theParam;
 {
 return [NSString stringWithFormat:@"%@ %@", theParam, @"fuka!"];
 }
 
 - (void)worker_result:(id)theResult;
 {
 NSLog(@"%@", theResult);
 }
 
 */
