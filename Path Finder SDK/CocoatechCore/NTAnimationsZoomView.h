//
//  NTAnimationsZoomView.h
//  CocoatechCore
//
//  Created by Steve Gehrman on 1/2/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NTAnimationsZoomView : NSView
{
	NSImage* image;
	CALayer* imageLayer;
	
	CAAnimation *transformAnimation;
	CAAnimation *opacityAnimation;
}

@property (retain) NSImage* image;
@property (retain) CALayer* imageLayer;
@property (retain) CAAnimation *transformAnimation;
@property (retain) CAAnimation *opacityAnimation;

+ (NTAnimationsZoomView*)view:(NSRect)frame;

- (void)animate;

@end

