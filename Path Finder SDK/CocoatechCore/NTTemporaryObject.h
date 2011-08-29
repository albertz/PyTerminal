//
//  NTTemporaryObject.h
//  CocoatechCore
//
//  Created by Steve Gehrman on 1/4/10.
//  Copyright 2010 Cocoatech. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NTTemporaryObject : NSObject
{
	id contents;
}

@property (readonly, retain) id contents;

+ (NTTemporaryObject*)tempObject:(id)theContents timeToLive:(NSTimeInterval)timeToLive;

@end
