//
//  NTGeometry.h
//  CocoatechCore
//
//  Created by Steve Gehrman on Sat Aug 10 2002.
//  Copyright (c) 2002 CocoaTech. All rights reserved.
//

#import <Cocoa/Cocoa.h>

// could not be a category since there is no NSGeometry class
@interface NTGeometry : NSObject
{
}

+ (NSRect)rectFromPoint:(NSPoint)one andPoint:(NSPoint)two;

    // scaleToFitContainer only sales if rect is taller or wider than containerRect
+ (NSRect)rect:(NSRect)rect centeredIn:(NSRect)containerRect scaleToFitContainer:(BOOL)scaleToFit;
+ (NSRect)rect:(NSRect)rect centeredIn:(NSRect)containerRect scaleToFitContainer:(BOOL)scaleToFit canScaleLarger:(BOOL)canScaleLarger;

// convert any real values to whole numbers
+ (NSRect)integerRect:(NSRect)rect;

// adjusts point so it fits within the rect
+ (NSPoint)point:(NSPoint)inPoint insideRect:(NSRect)theRect;
+ (NSScreen*)screenForPoint:(NSPoint)inPoint;

+ (NSPoint)topLeft:(NSRect)rect;
+ (NSPoint)bottomLeft:(NSRect)rect;
+ (NSPoint)topRight:(NSRect)rect;
+ (NSPoint)bottomRight:(NSRect)rect;

+ (NSPoint)topMid:(NSRect)rect;
+ (NSPoint)bottomMid:(NSRect)rect;
+ (NSPoint)rightMid:(NSRect)rect;
+ (NSPoint)leftMid:(NSRect)rect;

+ (NSPoint)topLeft:(NSRect)rect flipped:(BOOL)flipped;
+ (NSPoint)bottomLeft:(NSRect)rect flipped:(BOOL)flipped;
+ (NSPoint)topRight:(NSRect)rect flipped:(BOOL)flipped;
+ (NSPoint)bottomRight:(NSRect)rect flipped:(BOOL)flipped;

+ (CGFloat)distanceBetweenPoint:(NSPoint)a point:(NSPoint)b;
+ (NSPoint)centerPoint:(NSRect)theRect;

+ (void)updateRectsToAvoidRectGivenMinimumSize:(NSMutableArray *)rects rectToAvoid:(NSRect)rectToAvoid minSize:(NSSize)minimumSize;

@end

/*" Returns YES if sourceSize is at least as tall and as wide as minimumSize, and that neither the height nor the width of minimumSize is 0. "*/
static inline BOOL NTSizeIsOfMinimumSize(NSSize sourceSize, NSSize minimumSize)
{
    return (sourceSize.width >= minimumSize.width) && (sourceSize.height >= minimumSize.height) && (sourceSize.width > 0.0) && (sourceSize.height > 0.0);
}

NSRect NTClosestRectToRect(NSRect sourceRect, NSArray *candidateRects);
CGFloat NTSquaredDistanceToFitRectInRect(NSRect sourceRect, NSRect destinationRect);
