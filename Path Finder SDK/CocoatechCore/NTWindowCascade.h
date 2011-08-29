//
//  NTWindowCascade.h
//  CocoatechCore
//
//  Created by Steve Gehrman on 11/10/08.
//  Copyright 2008 Cocoatech. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol NTWindowCascadeDataSource;

#import <Foundation/NSGeometry.h> // For NSPoint, NSRect

@interface NTWindowCascade : NSObject
{
    NSRect lastStartingFrame;
    NSPoint lastWindowOrigin;
}

+ (id)sharedInstance;
+ (void)addDataSource:(id <NTWindowCascadeDataSource>)newValue;
+ (void)removeDataSource:(id <NTWindowCascadeDataSource>)oldValue;
+ (void)avoidFontPanel;
+ (void)avoidColorPanel;

+ (NSScreen *)screenForPoint:(NSPoint)aPoint;

+ (NSRect)unobscuredWindowFrameFromStartingFrame:(NSRect)startingFrame avoidingWindows:(NSArray *)windowsToAvoid;

- (NSRect)nextWindowFrameFromStartingFrame:(NSRect)startingFrame avoidingWindows:(NSArray *)windowsToAvoid;
- (void)reset;

@end


@protocol NTWindowCascadeDataSource
- (NSArray *)windowsThatShouldBeAvoided;
@end
