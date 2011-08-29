//
//  NSSplitView-NTExtensions.h
//  CocoatechCore
//
//  Created by Steve Gehrman on 1/9/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSSplitView (AnimationExtensions)

- (void)setPosition:(CGFloat)position ofDividerAtIndex:(NSInteger)dividerIndex animate:(BOOL)animate;
- (CGFloat)position;

- (CGFloat)splitFraction;
- (void)setSplitFraction:(CGFloat)newFract animate:(BOOL)animate;

// sets the autosave name and the default fraction
- (void)setupSplitView:(NSString*)autosaveName 
	   defaultFraction:(CGFloat)defaultFraction;

- (void)savePositionPreference;
- (CGFloat)positionFromPreference;
@end

