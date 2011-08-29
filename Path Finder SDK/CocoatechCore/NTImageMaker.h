//
//  NTImageMaker.h
//  CocoatechCore
//
//  Created by Steve Gehrman on 11/15/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NTImageMaker : NSObject
{
	NSSize size;
	NSImageInterpolation savedImageInterpolation;
	NSBitmapImageRep* bitmapImageRep;
	NSGraphicsContext *bitmapContext;
	BOOL locked;
}

@property (assign) NSSize size;
@property (assign) NSImageInterpolation savedImageInterpolation;
@property (retain) NSBitmapImageRep* bitmapImageRep;
@property (retain) NSGraphicsContext *bitmapContext;
@property (assign) BOOL locked;

+ (NTImageMaker*)maker:(NSSize)size;

- (void)lockFocus;
- (NSImage*)unlockFocus;
- (NSImage*)unlockFocus:(BOOL)template;

- (NSBitmapImageRep*)imageRep;  // a copy of the imagerep added to image in unlockFocus

@end
