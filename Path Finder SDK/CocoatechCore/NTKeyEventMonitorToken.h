//
//  NTKeyEventMonitorToken.h
//  CocoatechCore
//
//  Created by Steve Gehrman on 9/29/09.
//  Copyright 2009 Cocoatech. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NTKeyEventMonitorToken : NSObject
{
	unichar hotKey;
	NSInteger identifier;
	NSUInteger modifierFlags;
}

@property (nonatomic, assign) unichar hotKey;
@property (nonatomic, assign) NSInteger identifier;
@property (nonatomic, assign) NSUInteger modifierFlags;

+ (NTKeyEventMonitorToken*)token:(unichar)hotKey
					  identifier:(NSInteger)identifier
				   modifierFlags:(NSUInteger)modifierFlags;

- (BOOL)isEqual:(NTKeyEventMonitorToken*)rightObject;
@end

