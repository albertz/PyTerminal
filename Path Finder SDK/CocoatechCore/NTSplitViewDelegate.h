//
//  NTSplitViewDelegate.h
//  CocoatechCore
//
//  Created by Steve Gehrman on 12/20/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NTSplitViewDelegate : NSObject <NSSplitViewDelegate>
{
	id delegate; // not retained
	
	BOOL resizeProportionally;
	NSInteger resizeViewIndex;  // which view to resize when window grows
	NSInteger collapseViewIndex; // index of view to collapse on double click, set to -1 to disallow collapsing completely, default is 1
	
	NSInteger preventViewCollapseAtIndex;  // default -1 which doesn nothing
	
	CGFloat minCoordinate;
	CGFloat maxCoordinate;
}

@property (assign) id delegate;  // not retained
@property (assign) NSInteger resizeViewIndex;
@property (assign) NSInteger collapseViewIndex;   // default is 1
@property (assign) NSInteger preventViewCollapseAtIndex;
@property (assign) CGFloat minCoordinate;
@property (assign) CGFloat maxCoordinate;
@property (assign) BOOL resizeProportionally;

+ (NTSplitViewDelegate*)splitViewDelegate;
+ (NTSplitViewDelegate*)splitViewDelegate:(id)delegate;
- (void)clearDelegate;

@end
