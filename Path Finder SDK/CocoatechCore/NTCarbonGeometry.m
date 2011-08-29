//
//  NTCarbonGeometry.m
//  CocoatechCore
//
//  Created by Steve Gehrman on 1/22/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "NTCarbonGeometry.h"

Rect NSRectToQDRect(const NSRect inNSRect)
{
	Rect qdRect;
	
	qdRect.top = (SInt16) NSMinY( inNSRect );
	qdRect.left = (SInt16) NSMinX( inNSRect );
	qdRect.bottom = (SInt16) NSMaxY( inNSRect );
	qdRect.right = (SInt16) NSMaxX( inNSRect );
	
	return qdRect;
}

NSRect QDRectToNSRect(const Rect inQDRect)
{
	return NSMakeRect(inQDRect.left, inQDRect.top, (inQDRect.right-inQDRect.left), (inQDRect.bottom-inQDRect.top));
}

Point NSPointToQDPoint(const NSPoint inNSPoint)
{
	Point qdPoint;
	
	qdPoint.h = (SInt16) inNSPoint.x;
	qdPoint.v = (SInt16) inNSPoint.y;
	
	return qdPoint;
}

NSPoint QDPointToNSPoint(const Point inQDPoint)
{
	return NSMakePoint(inQDPoint.h, inQDPoint.v);
}
