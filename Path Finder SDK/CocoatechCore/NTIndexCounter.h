//
//  NTIndexCounter.h
//  CocoatechCore
//
//  Created by Steve Gehrman on 7/14/09.
//  Copyright 2009 Cocoatech. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NTIndexCounter : NSObject {
	NSUInteger count;
	NSUInteger index;
}

@property (readonly, nonatomic, assign) NSUInteger count;
@property (readonly, nonatomic, assign) NSUInteger index;

+ (NTIndexCounter*)counter:(NSUInteger)count;

- (void)increment;

- (BOOL)done;
- (NSUInteger)remaining;

@end
