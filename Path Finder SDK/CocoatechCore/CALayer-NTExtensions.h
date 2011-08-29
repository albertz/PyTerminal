//
//  CALayer-NTExtensions.h
//  CocoatechCore
//
//  Created by Steve Gehrman on 6/6/08.
//  Copyright 2008 Cocoatech. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface CALayer (NTExtensions)

- (NSString*)longDescription;
- (void)debugLayers:(BOOL)showSubviews;
- (void)scale:(CGFloat)theScale;

- (CGPoint)scrollPositionAsPercentage;
- (void)setScrollPositionAsPercentage:(CGPoint)scrollPosition;

@end
