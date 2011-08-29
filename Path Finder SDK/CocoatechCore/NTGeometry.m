//
//  NTGeometry.m
//  CocoatechCore
//
//  Created by Steve Gehrman on Sat Aug 10 2002.
//  Copyright (c) 2002 CocoaTech. All rights reserved.
//

#import "NTGeometry.h"

// could not be a category since there is no NSGeometry class
@implementation NTGeometry

+ (NSRect)rectFromPoint:(NSPoint)one andPoint:(NSPoint)two;
{
    return NSMakeRect(MIN(one.x, two.x), MIN(one.y, two.y), abs(one.x - two.x), abs(one.y - two.y));
}

+ (NSRect)rect:(NSRect)rect centeredIn:(NSRect)containerRect scaleToFitContainer:(BOOL)scaleToFit;
{
	return [self rect:rect centeredIn:containerRect scaleToFitContainer:scaleToFit canScaleLarger:NO];
}

+ (NSRect)rect:(NSRect)rect centeredIn:(NSRect)containerRect scaleToFitContainer:(BOOL)scaleToFit canScaleLarger:(BOOL)canScaleLarger;
{
    NSRect resultRect;
    NSSize containerSize = containerRect.size;

    resultRect = rect;
    resultRect.origin = containerRect.origin;
	
    if (scaleToFit)
    {
		BOOL needsToBeScaledSmaller = NO;
		BOOL needsToBeScaledBigger = NO;
		NSSize rectSize = rect.size;
		
		if (canScaleLarger)
		{
			if ((rectSize.height < containerSize.height) && (rectSize.width < containerSize.width))
				needsToBeScaledBigger = YES;
		}

		if (!needsToBeScaledBigger)
		{
			// only need to scale if the rect is taller or wider than the container
			if ((rectSize.height > containerSize.height) || (rectSize.width > containerSize.width))
				needsToBeScaledSmaller = YES;
		}
		
		if (needsToBeScaledSmaller || needsToBeScaledBigger)
		{			
			// use the width, if the height becomes too big, do again based on the height
			resultRect.size.width = containerSize.width;
			resultRect.size.height = containerSize.width * (rectSize.height / rectSize.width);

			// height grew too big, no problem, do the opposite
			if (resultRect.size.height > containerSize.height)
			{
				resultRect.size.height = containerSize.height;
				resultRect.size.width = containerSize.height * (rectSize.width / rectSize.height);
			}
		}
	}
	
    //  now center the rect
    resultRect.origin.x += ((containerSize.width - resultRect.size.width) / 2.0);
    resultRect.origin.y += ((containerSize.height - resultRect.size.height) / 2.0);
    
    return resultRect;
}

// adjusts point so it fits within the rect
+ (NSPoint)point:(NSPoint)inPoint insideRect:(NSRect)theRect;
{
	if (inPoint.x < NSMinX(theRect))
		inPoint.x = NSMinX(theRect);
	else if (inPoint.x > NSMaxX(theRect))
		inPoint.x = NSMaxX(theRect);

	if (inPoint.y < NSMinY(theRect))
		inPoint.y = NSMinY(theRect);
	else if (inPoint.y > NSMaxY(theRect))
		inPoint.y = NSMaxY(theRect);
	
	return inPoint;
}

+ (NSScreen*)screenForPoint:(NSPoint)inPoint;
{
	NSArray* screens = [NSScreen screens];
	NSUInteger minDiff = NSNotFound;
	NSScreen* result = nil;
	
	for (NSScreen* screen in screens)
	{
		NSUInteger min = 0;
		NSRect frame = [screen frame];
		
		// inside rect, return we've found it
		if (NSPointInRect(inPoint, frame))
			return screen;
		
		// outside rect, keep track of closest screen frame
		if (inPoint.x < NSMinX(frame))
			min += NSMinX(frame) - inPoint.x;
		else if (inPoint.x > NSMaxX(frame))
			min += inPoint.x - NSMaxX(frame);
		
		if (inPoint.y < NSMinY(frame))
			min += NSMinY(frame) - inPoint.y;
		else if (inPoint.y > NSMaxY(frame))
			min += inPoint.y - NSMaxY(frame);
		
		if ((minDiff == NSNotFound) || min < minDiff)
		{
			result = screen;
			minDiff = min;
		}
	}
	
	return result;
}

// convert any real values to whole numbers
+ (NSRect)integerRect:(NSRect)rect;
{
	// NSIntegralRect changes the height and width for example {1.5, 1, 10, 10} will become {1, 1, 11, 10} (stupid shit was distorting images I was drawing)
	// return NSIntegralRect(rect);
	NSRect result = rect;
	
	result.origin.x = floor(result.origin.x);
    result.origin.y = floor(result.origin.y);
	result.size.width = floor(result.size.width);
    result.size.height = floor(result.size.height);
	    
	return result;
}

+ (NSPoint)topLeft:(NSRect)rect;
{
	return NSMakePoint(NSMinX(rect), NSMaxY(rect));
}

+ (NSPoint)bottomLeft:(NSRect)rect;
{
	return rect.origin;
}

+ (NSPoint)topRight:(NSRect)rect;
{
	return NSMakePoint(NSMaxX(rect), NSMaxY(rect));
}

+ (NSPoint)bottomRight:(NSRect)rect;
{
	return NSMakePoint(NSMaxX(rect), NSMinY(rect));
}

+ (NSPoint)topMid:(NSRect)rect;
{
	return NSMakePoint(NSMidX(rect), NSMaxY(rect));
}

+ (NSPoint)bottomMid:(NSRect)rect;
{
	return NSMakePoint(NSMidX(rect), NSMinY(rect));
}

+ (NSPoint)rightMid:(NSRect)rect;
{
	return NSMakePoint(NSMaxX(rect), NSMidY(rect));
}

+ (NSPoint)leftMid:(NSRect)rect;
{
	return NSMakePoint(NSMinX(rect), NSMidY(rect));
}

+ (NSPoint)topLeft:(NSRect)rect flipped:(BOOL)flipped;
{
	return NSMakePoint(NSMinX(rect), NSMinY(rect));
}

+ (NSPoint)bottomLeft:(NSRect)rect flipped:(BOOL)flipped;
{
	return NSMakePoint(NSMinX(rect), NSMaxY(rect));
}

+ (NSPoint)topRight:(NSRect)rect flipped:(BOOL)flipped;
{
	return NSMakePoint(NSMaxX(rect), NSMinY(rect));
}

+ (NSPoint)bottomRight:(NSRect)rect flipped:(BOOL)flipped;
{
	return NSMakePoint(NSMaxX(rect), NSMaxY(rect));
}

/*" This method splits any of the original rects that intersect rectToAvoid. Note that the rects array must be a mutable array as it is (potentially) modified by this function. Rects which are not as tall or as wide as minimumSize are removed from the original rect array (or never added, if the splitting operation results in any new rects smaller than the minimum size). The end result is that the rects array consists of rects encompassing the same overall area except for any overlap with rectToAvoid, excluding any rects not of minimumSize. No attempt is made to remove duplicate rects or rects which are subsets of other rects in the array. "*/
+ (void)updateRectsToAvoidRectGivenMinimumSize:(NSMutableArray *)rects rectToAvoid:(NSRect)rectToAvoid minSize:(NSSize)minimumSize;
{
    NSInteger rectIndex = [rects count];
	
    // Very important to iterate over the constraining rects _backwards_, as we will be appending to the constraining rects array and also removing some constraining rects as we iterate over them
    while (rectIndex-- > 0) {
        NSRect iteratedRect = [[rects objectAtIndex:rectIndex] rectValue];
		
        if (!NSIntersectsRect(iteratedRect, rectToAvoid)) {
            if (!NTSizeIsOfMinimumSize(iteratedRect.size, minimumSize)) {
                // The constraining rect is too small - remove it
                [rects removeObjectAtIndex:rectIndex];
            }
			
        } else {
            NSRect workRect;
            
            // Remove the intersecting rect from the list of constraining rects
            [rects removeObjectAtIndex:rectIndex];
            
            // If there is a non-intersecting portion on the left of the intersecting rect, add that to the list of constraining rects
            workRect = iteratedRect;
            workRect.size.width = NSMinX(rectToAvoid) - NSMinX(iteratedRect);
            if (NTSizeIsOfMinimumSize(workRect.size, minimumSize)) {
                [rects addObject:[NSValue valueWithRect:workRect]];
            }
			
            // Same for the right
            workRect = iteratedRect;
            workRect.origin.x = NSMaxX(rectToAvoid);
            workRect.size.width = NSMaxX(iteratedRect) - NSMaxX(rectToAvoid);
            if (NTSizeIsOfMinimumSize(workRect.size, minimumSize)) {
                [rects addObject:[NSValue valueWithRect:workRect]];
            }
			
            // Same for the top
            workRect = iteratedRect;
            workRect.origin.y = NSMaxY(rectToAvoid);
            workRect.size.height = NSMaxY(iteratedRect) - NSMaxY(rectToAvoid);
            if (NTSizeIsOfMinimumSize(workRect.size, minimumSize)) {
                [rects addObject:[NSValue valueWithRect:workRect]];
            }
			
            // Same for the bottom
            workRect = iteratedRect;
            workRect.size.height = NSMinY(rectToAvoid) - NSMinY(iteratedRect);
            if (NTSizeIsOfMinimumSize(workRect.size, minimumSize)) {
                [rects addObject:[NSValue valueWithRect:workRect]];
            }
        }
    }
}

+ (NSPoint)centerPoint:(NSRect)theRect;
{
	NSPoint result;
	
	result.x = NSMidX(theRect);
	result.y = NSMidY(theRect);
	
	return result;
}

+ (CGFloat)distanceBetweenPoint:(NSPoint)a point:(NSPoint)b;
{
    CGFloat dx = a.x - b.x;
    CGFloat dy = a.y - b.y;
	
    return (sqrt((dx * dx) + (dy * dy)));
}

@end

/*" This function returns the candidateRect that is closest to sourceRect. The distance used is the distance required to move sourceRect into the candidateRect, rather than simply having the closest approach. "*/
NSRect NTClosestRectToRect(NSRect sourceRect, NSArray *candidateRects)
{
    NSInteger rectIndex = [candidateRects count];
    NSRect closestRect = NSZeroRect;
    if (rectIndex > 0)
	{
        rectIndex--;
        NSRect rect = [(NSValue *)[candidateRects objectAtIndex:rectIndex] rectValue];
        CGFloat shortestDistance = NTSquaredDistanceToFitRectInRect(sourceRect, rect);
        closestRect = rect;
		
        while (rectIndex-- > 0) 
		{
            NSRect iteratedRect = [(NSValue *)[candidateRects objectAtIndex:rectIndex] rectValue];
            CGFloat distance = NTSquaredDistanceToFitRectInRect(sourceRect, iteratedRect);
            if (distance < shortestDistance)
			{
                shortestDistance = distance;
                closestRect = iteratedRect;
            }
        }
    }
	
    return closestRect;
}

/*" Returns the squared distance from the origin of sourceRect to the closest point in destinationRect. Assumes (and asserts) that destinationRect is large enough to fit sourceRect inside. The reason for returning the squared distance rather than the actual distance is one of optimization - this relieves us of having to take the square root of the product of the squares of the horizontal and vertical distances. The return value is of direct use in comparing against other squared distances, and the square root can be taken if the caller needs the actual distance rather than to simply compare for a variety of potential destination rects. "*/
CGFloat NTSquaredDistanceToFitRectInRect(NSRect sourceRect, NSRect destinationRect)
{
    CGFloat xDistance, yDistance;
		
    if (NSMinX(sourceRect) < NSMinX(destinationRect)) {
        xDistance = NSMinX(destinationRect) - NSMinX(sourceRect);
    } else if (NSMaxX(sourceRect) > NSMaxX(destinationRect)) {
        xDistance = NSMaxX(sourceRect) - NSMaxX(destinationRect);
    } else {
        xDistance = 0.0f;
    }
	
    if (NSMinY(sourceRect) < NSMinY(destinationRect)) {
        yDistance = NSMinY(destinationRect) - NSMinY(sourceRect);
    } else if (NSMaxY(sourceRect) > NSMaxY(destinationRect)) {
        yDistance = NSMaxY(sourceRect) - NSMaxY(destinationRect);
    } else {
        yDistance = 0.0f;
    }
	
    return (xDistance * xDistance) + (yDistance * yDistance);
}
