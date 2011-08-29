//
//  NTCarbonGeometry.h
//  CocoatechCore
//
//  Created by Steve Gehrman on 1/22/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

Rect NSRectToQDRect(const NSRect inNSRect);
NSRect QDRectToNSRect(const Rect inQDRect);

Point NSPointToQDPoint(const NSPoint inNSPoint);
NSPoint QDPointToNSPoint(const Point inQDPoint);
