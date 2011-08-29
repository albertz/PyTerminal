//
//  NTCoordinate.h
//  CocoatechCore
//
//  Created by Steve Gehrman on Tue May 20 2003.
//  Copyright (c) 2003 CocoaTech. All rights reserved.
//

#import <Foundation/Foundation.h>

// same as an NSPoint, just a better name when we are dealing with coordinates
typedef NSPoint NTCoordinate;

extern const NTCoordinate NTInvalidCoordinate;

FOUNDATION_STATIC_INLINE NSPoint NTMakeCoordinate(CGFloat x, CGFloat y) {
    NTCoordinate p;
    p.x = x;
    p.y = y;
    return p;
}

	FOUNDATION_STATIC_INLINE BOOL NTEqualCoordinates(NTCoordinate aPoint, NTCoordinate bPoint) {
    return ((aPoint.x == bPoint.x) && (aPoint.y == bPoint.y));
}

FOUNDATION_STATIC_INLINE BOOL NTIsValidCoordinate(NTCoordinate aPoint) {
	return !NTEqualCoordinates(NTInvalidCoordinate, aPoint);
}

@interface NTCoordinateUtilities : NSObject
+ (NSString *)keyForCoordinate:(NTCoordinate)coordinate;
+ (NTCoordinate)coordinateForKey:(NSString*)key;
@end


