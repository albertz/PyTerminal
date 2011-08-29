//
//  NTAnimationsWindow.h
//  CocoatechCore
//
//  Created by Steve Gehrman on 12/28/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class NTAnimationsZoomView;

@interface NTAnimationsWindow : NSWindow
{
	NTAnimationsZoomView* imageView;
}

@property (retain) NTAnimationsZoomView* imageView;

+ (id)window;

- (void)zoomImage:(NSImage*)image atPoint:(NSPoint)point;

@end
