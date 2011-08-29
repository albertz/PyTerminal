//
//  NTBoxView.h
//  CocoatechCore
//
//  Created by Steve Gehrman on Sat May 17 2003.
//  Copyright (c) 2003 CocoaTech. All rights reserved.
//

#import "NTBackgroundView.h"

typedef enum NTFrameType
{
	NTFrame_none =   0,
	
	NTFrame_left =   0x00000001,
	NTFrame_right =  0x00000002,
	NTFrame_top =    0x00000004,
	NTFrame_bottom = 0x00000008,
	
	NTFrame_all =    0x0000000F,
	
} NTFrameType;

@interface NTBoxView : NTBackgroundView
{
    NTFrameType mv_frameType; 
}

- (NSRect)contentBounds;

- (NTFrameType)frameType;
- (void)setFrameType:(NTFrameType)theFrameType;

+ (void)drawWithFrameType:(NTFrameType)frameType inRect:(NSRect)rect inView:(NSView*)inView;
@end
