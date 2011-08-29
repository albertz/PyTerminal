//
//  NTSliderMenuItem.h
//  CocoatechCore
//
//  Created by Steve Gehrman on 5/14/08.
//  Copyright 2008 Cocoatech. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class NTMenuSlider, NTSliderGradientView;

@interface NTSliderMenuItem : NSMenuItem
{
	id model;
	NTMenuSlider *slider;
	NTSliderGradientView *sliderView;
}

@property (retain) id model;
@property (retain) NTMenuSlider *slider;
@property (retain) NTSliderGradientView *sliderView;

+ (NTSliderMenuItem*)menuItem:(id)theModel;

@end
