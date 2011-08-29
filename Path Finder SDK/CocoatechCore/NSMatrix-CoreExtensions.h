//
//  NSMatrix-CoreExtensions.h
//  CocoatechCore
//
//  Created by Steve Gehrman on 1/5/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "NTCoordinate.h"

@interface NSMatrix (CoreExtensions)

- (NSRect)rectOfCell:(NSCell*)cell;
- (NSRect)rectOfSelectedCells;
- (NSRect)rectOfCells:(NSArray*)cells;
- (BOOL)isCellSelected:(NSCell*)cell;
- (NSInteger)numberOfSelectedCells;

	// returns NSNotFound if no row selected
- (NSUInteger)firstSelectedRow;
- (NSUInteger)lastSelectedRow;
- (NSIndexSet *)selectedIndexes;

- (NTCoordinate)coordinateAtPoint:(NSPoint)point;
- (NTCoordinate)coordinateOfCell:(NSCell *)cell;

- (NSRect)cellRectWithCoordinate:(NTCoordinate)coordinate;
- (NSCell*)cellWithCoordinate:(NTCoordinate)coordinate;
- (NSCell*)cellAtPoint:(NSPoint)point;
- (BOOL)isCoordinateSelected:(NTCoordinate)coordinate;

@end
