//
//  NTSelectionGradient.h
//  CocoatechCore
//
//  Created by Steve Gehrman on 10/29/08.
//  Copyright 2008 Cocoatech. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class NTGradientDraw;

@interface NTSelectionGradient : NSObject {
	NTGradientDraw* aquaGradient;
	NSColor* aquaLineColor;
	
	NTGradientDraw* graphiteGradient;
	NSColor* graphiteLineColor;

	NTGradientDraw* dimmedGradient;
	NSColor* dimmedLineColor;
}

@property (retain) NTGradientDraw* aquaGradient;
@property (retain) NSColor* aquaLineColor;
@property (retain) NTGradientDraw* graphiteGradient;
@property (retain) NSColor* graphiteLineColor;
@property (retain) NTGradientDraw* dimmedGradient;
@property (retain) NSColor* dimmedLineColor;

+ (NTSelectionGradient*)gradient;

- (void)drawGradientInRect:(NSRect)frame 
					dimmed:(BOOL)dimmed 
				   flipped:(BOOL)flipped;
@end
