//
//  NSMatrix-CoreExtensions.m
//  CocoatechCore
//
//  Created by Steve Gehrman on 1/5/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "NSMatrix-CoreExtensions.h"

@implementation NSMatrix (CoreExtensions)

- (NSRect)rectOfCell:(NSCell*)cell;
{
	NSInteger row, col;
	
	if ([self getRow:&row column:&col ofCell:cell])
		return [self cellFrameAtRow:row column:col];
	
	return NSZeroRect;
}

- (NSRect)rectOfCells:(NSArray*)cells;
{
	NSRect cellsRect=NSZeroRect;
	NSCell* cell;
				
	for (cell in cells)
	{
		NSRect cellRect;
		
		cellRect = [self rectOfCell:cell];            
		
		cellsRect = NSUnionRect(cellsRect, cellRect);
	}
	
	return cellsRect;	
}

- (NSRect)rectOfSelectedCells;
{
	return [self rectOfCells:[self selectedCells]];    
}

- (BOOL)isCellSelected:(NSCell*)cell;
{
	return ([[self selectedCells] indexOfObjectIdenticalTo:cell] != NSNotFound);
}

- (NSInteger)numberOfSelectedCells;
{
	return [[self selectedCells] count];
}

- (NSCell*)cellAtPoint:(NSPoint)point;
{
	NTCoordinate coordinate = [self coordinateAtPoint:point];
	
	if (NTIsValidCoordinate(coordinate))
		return [self cellWithCoordinate:coordinate];
	
	return nil;
}

- (NTCoordinate)coordinateAtPoint:(NSPoint)point;
{
	NSInteger row, col;
	NTCoordinate result = NTInvalidCoordinate;
	
	BOOL found = [self getRow:&row column:&col forPoint:point];
	
	if (found)
	{
		result.x = col; 
		result.y = row;
	}
	
	return result;
}

- (NSRect)cellRectWithCoordinate:(NTCoordinate)coordinate;
{
	NSInteger row = coordinate.y;
	NSInteger col = coordinate.x;
	
	if (row < [self numberOfRows] && col < [self numberOfColumns])
		return [self cellFrameAtRow:row column:col];
	
	return NSZeroRect;
}

- (NSCell*)cellWithCoordinate:(NTCoordinate)coordinate;
{
	NSInteger row = coordinate.y;
	NSInteger col = coordinate.x;
	
	if (row < [self numberOfRows] && col < [self numberOfColumns])
		return [self cellAtRow:row column:col];
	
	return nil;	
}

- (NTCoordinate)coordinateOfCell:(NSCell *)cell;
{
	NSInteger row, col;
	
	if ([self getRow:&row column:&col ofCell:cell])
		return NTMakeCoordinate(col, row);
	
	return NTInvalidCoordinate;
}

- (BOOL)isCoordinateSelected:(NTCoordinate)coordinate;
{
	NSCell* cell = [self cellWithCoordinate:coordinate];
	
	if (cell)
		return [self isCellSelected:cell];
	
	return NO;
}

- (NSUInteger)firstSelectedRow;
{
	NSArray* cells = [self selectedCells];
	
	if ([cells count])
		return [self coordinateOfCell:[cells objectAtIndex:0]].y;
	
	return NSNotFound;
}	

- (NSUInteger)lastSelectedRow;
{
	NSArray* cells = [self selectedCells];
	
	if ([cells count])
		return [self coordinateOfCell:[cells objectAtIndex:[cells count]-1]].y;
	
	return NSNotFound;	
}

- (NSIndexSet *)selectedIndexes;
{
	NSEnumerator *enumerator = [[self selectedCells] objectEnumerator];
	NSMutableIndexSet *result = [NSMutableIndexSet indexSet];
	NSCell* cell;
	NTCoordinate coordinate;
	
	while (cell = [enumerator nextObject])
	{
		coordinate = [self coordinateOfCell:cell];
		
		[result addIndex:coordinate.y];
	}
	
	return result;
}

@end
