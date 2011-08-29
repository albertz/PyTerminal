//
//  NSBezierPath-NTExtensions.m
//  CocoatechCore
//

#import "NSBezierPath-NTExtensions.h"
#import "NTGeometry.h"
#import "NSGraphicsContext-NTExtensions.h"
#import "NSImage-NTExtensions.h"
#import "NTImageMaker.h"
#import "NTColorSet.h"

@interface NSBezierPath (NTExtensionsPrivate)
+ (NSImage*)gridImage:(NSRect)bounds;
@end

@implementation NSBezierPath (NTExtensions)

- (BOOL)isClosed
{
    NSInteger elements = [self elementCount];
    
    if (elements)
    {
        if ([self elementAtIndex:[self elementCount] -1] == NSClosePathBezierPathElement)
            return YES;
    }

    return NO;
}

- (NSBezierPath *)closedPath
{
    if (![self isClosed])
    {
        NSBezierPath *result = [[self copy] autorelease];
        [result closePath];
        return result;
    }
    
    return self;
}

- (void)appendBezierPathWithBottomRoundedCorners: (NSRect) aRect
									   radius: (CGFloat) radius
{
	NSPoint bottomMid = NSMakePoint(NSMidX(aRect), NSMinY(aRect));
	NSPoint rightMid = NSMakePoint(NSMaxX(aRect), NSMidY(aRect));
	NSPoint topLeft = NSMakePoint(NSMinX(aRect), NSMaxY(aRect));
	NSPoint topRight = NSMakePoint(NSMaxX(aRect), NSMaxY(aRect));
	NSPoint bottomRight = NSMakePoint(NSMaxX(aRect), NSMinY(aRect));
	NSPoint bottomLeft = NSMakePoint(NSMinX(aRect), NSMinY(aRect));
	
	[self moveToPoint: rightMid];
	[self lineToPoint: topRight];
	[self lineToPoint: topLeft];

	[self appendBezierPathWithArcFromPoint: bottomLeft
								   toPoint: bottomMid
									radius: radius];
	[self appendBezierPathWithArcFromPoint: bottomRight
								   toPoint: rightMid
									radius: radius];
	[self closePath];
}

- (void)appendBezierPathWithRoundedRectangle:(NSRect)aRect radius:(CGFloat)radius;
{
	radius = MIN(radius, 0.5 * MIN(aRect.size.width, aRect.size.height));	

	[self appendBezierPathWithRoundedRect:aRect xRadius:radius yRadius:radius];
}

- (void)appendBezierPathWithRoundedRectangle:(NSRect)aRect topRadius:(CGFloat)topRadius bottomRadius:(CGFloat)bottomRadius;
{
	[self appendBezierPathWithRoundedRectangle:aRect
								 topLeftRadius:topRadius
								topRightRadius:topRadius
							  bottomLeftRadius:bottomRadius
							 bottomRightRadius:bottomRadius];
}

- (void)appendBezierPathWithRoundedRectangle:(NSRect)aRect topLeftRadius:(CGFloat)topLeftRadius topRightRadius:(CGFloat)topRightRadius bottomLeftRadius:(CGFloat)bottomLeftRadius bottomRightRadius:(CGFloat)bottomRightRadius;
{
	CGFloat maxRadius =  0.5 * MIN(aRect.size.width, aRect.size.height);
	
	topLeftRadius = MIN(topLeftRadius, maxRadius);	
	bottomLeftRadius = MIN(bottomLeftRadius, maxRadius);	
	topRightRadius = MIN(topRightRadius, maxRadius);	
	bottomRightRadius = MIN(bottomRightRadius, maxRadius);	
	
    NSPoint topMid = NSMakePoint(NSMidX(aRect), NSMaxY(aRect));
    NSPoint leftMid = NSMakePoint(NSMinX(aRect), NSMidY(aRect));
    NSPoint rightMid = NSMakePoint(NSMaxX(aRect), NSMidY(aRect));
    NSPoint bottomMid = NSMakePoint(NSMidX(aRect), NSMinY(aRect));
    NSPoint topLeft = NSMakePoint(NSMinX(aRect), NSMaxY(aRect));
    NSPoint topRight = NSMakePoint(NSMaxX(aRect), NSMaxY(aRect));
    NSPoint bottomRight = NSMakePoint(NSMaxX(aRect), NSMinY(aRect));
	NSPoint bottomLeft = NSMakePoint(NSMinX(aRect), NSMinY(aRect));
	
    [self moveToPoint:topMid];
    [self appendBezierPathWithArcFromPoint:topLeft 
                                   toPoint:leftMid
                                    radius:topLeftRadius];
	
	[self appendBezierPathWithArcFromPoint:bottomLeft
								   toPoint:bottomMid 
									radius:bottomLeftRadius];
	
	[self appendBezierPathWithArcFromPoint:bottomRight
                                   toPoint:rightMid
                                    radius:bottomRightRadius];
	
	[self appendBezierPathWithArcFromPoint:topRight 
								   toPoint:topMid
                                    radius:topRightRadius];
    [self closePath];
}

- (void)appendBezierPathWithRoundedRectangle:(NSRect)aRect radius:(CGFloat)radius leftSideOnly:(BOOL)leftSideOnly;
{
	radius = MIN(radius, 0.5 * MIN(aRect.size.width, aRect.size.height));	

    NSPoint topMid = NSMakePoint(NSMidX(aRect), NSMaxY(aRect));
    NSPoint topLeft = NSMakePoint(NSMinX(aRect), NSMaxY(aRect));
    NSPoint topRight = NSMakePoint(NSMaxX(aRect), NSMaxY(aRect));
    NSPoint bottomRight = NSMakePoint(NSMaxX(aRect), NSMinY(aRect));
    
    [self moveToPoint:topMid];
    
    if (leftSideOnly)
    {
        [self appendBezierPathWithArcFromPoint:topLeft 
                                       toPoint:aRect.origin
                                        radius:radius];
        [self appendBezierPathWithArcFromPoint:aRect.origin
                                       toPoint:bottomRight
										radius:radius];
        [self appendBezierPathWithArcFromPoint:bottomRight 
                                       toPoint:topRight
                                        radius:radius/2];
        [self appendBezierPathWithArcFromPoint:topRight 
									   toPoint:topLeft
                                        radius:radius/2];
    }
    else
    {
        [self appendBezierPathWithArcFromPoint:topLeft 
                                       toPoint:aRect.origin
                                        radius:radius/2];
        [self appendBezierPathWithArcFromPoint:aRect.origin
                                       toPoint:bottomRight 
										radius:radius/2];
        [self appendBezierPathWithArcFromPoint:bottomRight 
                                       toPoint:topRight
                                        radius:radius];
        [self appendBezierPathWithArcFromPoint:topRight
									   toPoint:topLeft
                                        radius:radius];
    }    
    
    [self closePath];
}

- (NSImage*)convertToImage:(NSColor*)color frameColor:(NSColor*)frameColor template:(BOOL)template;
{
    NSRect bounds = [self bounds];
	
	// make sure bounds is int, not float
	bounds = [NTGeometry integerRect:bounds];
    NTImageMaker* result = [NTImageMaker maker:bounds.size];
    
    [result lockFocus];
    {
        // clip to the path
        [self setClip];
        
		if (color)
		{
			[color set];
			[self fill];
        }
		
        if (frameColor)
        {
            [frameColor set];
            [self stroke];
        }
    }
    return [result unlockFocus:template];
}

+ (NSBezierPath*)downArrowPath:(NSRect)inRect;
{
	NSBezierPath* result = [NSBezierPath bezPath];
	NSRect arrowRect = NSMakeRect(0,0,1,1);
	CGFloat quarter = .25;
	CGFloat midY = .65;
	
	[result moveToPoint:NSMakePoint(NSMinX(arrowRect), midY)];
	[result lineToPoint:NSMakePoint(NSMidX(arrowRect), NSMinY(arrowRect))];
	[result lineToPoint:NSMakePoint(NSMaxX(arrowRect), midY)];
	[result lineToPoint:NSMakePoint(NSMaxX(arrowRect)-quarter, midY)];
	[result lineToPoint:NSMakePoint(NSMaxX(arrowRect)-quarter, NSMaxY(arrowRect))];
	[result lineToPoint:NSMakePoint(NSMinX(arrowRect)+quarter, NSMaxY(arrowRect))];
	[result lineToPoint:NSMakePoint(NSMinX(arrowRect)+quarter, midY)];
	[result closePath];
	
	// now convert to correct size
	NSAffineTransform* transform = [NSAffineTransform transform];
	[transform scaleXBy:NSWidth(inRect) yBy:NSWidth(inRect)];
	[result transformUsingAffineTransform:transform];
	
	return result;
}

+ (NSImage*)downArrowImage:(NSRect)inRect;
{
	inRect.origin = NSZeroPoint;
	NTImageMaker *result = [NTImageMaker maker:inRect.size];
	[result lockFocus];
	[[[NTColorSet standardSet] colorForKey:kNTCS_blackImage] set];
	[[self downArrowPath:inRect] fill];
	return [result unlockFocus:YES];
}

+ (NSImage*)upArrowImage:(NSRect)inRect;
{
	return [[self downArrowImage:inRect] flip];
}

+ (NSImage*)downTriangleImage:(NSRect)inRect flipped:(BOOL)flipped;
{
	NSBezierPath *linePath;
	
	linePath = [NSBezierPath trianglePath:inRect direction:kTrianglePointingDownDirection flipped:flipped];
	
    NTImageMaker *result = [NTImageMaker maker:inRect.size];
	[result lockFocus];
	[[[NTColorSet standardSet] colorForKey:kNTCS_blackImage] set];
	[linePath fill];
	return [result unlockFocus:YES];
}

+ (NSImage*)rightTriangleImage:(NSRect)inRect;
{
    inRect.origin = NSMakePoint(0,0);
    
    NTImageMaker *result = [NTImageMaker maker:inRect.size];
    NSBezierPath *path = [NSBezierPath trianglePath:inRect direction:kTrianglePointingRightDirection flipped:NO];
    
    [result lockFocus];
	[[[NTColorSet standardSet] colorForKey:kNTCS_blackImage] set];
	[path fill];   
	return [result unlockFocus:YES];
}

+ (NSImage*)leftTriangleImage:(NSRect)inRect;
{   
    inRect.origin = NSMakePoint(0,0);
    
    NTImageMaker *result = [NTImageMaker maker:inRect.size];
    
    NSBezierPath *path = [NSBezierPath trianglePath:inRect direction:kTrianglePointingLeftDirection flipped:NO];
	
    [result lockFocus];
	[[[NTColorSet standardSet] colorForKey:kNTCS_blackImage] set];
	[path fill];
	return [result unlockFocus:YES];
}

+ (NSBezierPath *)bezierPathWithPlateInRect:(NSRect)rect
{
	return [self bezierPathWithPlateInRect:rect onLeft:YES onRight:YES];
}

+ (NSBezierPath *)bezierPathWithPlateInRect:(NSRect)rect onLeft:(BOOL)onLeft onRight:(BOOL)onRight;
{
	if (!onLeft && !onRight)
		return [self rectPath:rect];
		
	NSBezierPath *result = [NSBezierPath bezPath];
	[result appendBezierPathWithPlateInRect:rect onLeft:onLeft onRight:onRight];
	return result;	
}

- (void)appendBezierPathWithPlateInRect:(NSRect)rect onLeft:(BOOL)onLeft onRight:(BOOL)onRight;
{
	if (rect.size.height > 0) 
    {
		CGFloat radius = rect.size.height/2.0;
		NSPoint leftStartPoint = NSMakePoint(rect.origin.x + radius, NSMaxY(rect));
		NSPoint rightStartPoint = NSMakePoint(NSMaxX(rect) - radius, rect.origin.y+radius);
		NSPoint center1 = NSMakePoint(rect.origin.x+radius, rect.origin.y+radius);
		NSPoint center2 = NSMakePoint(NSMaxX(rect) - radius, rect.origin.y+radius);
        		
		if (onLeft && onRight)
		{
			[self moveToPoint:leftStartPoint];
			[self appendBezierPathWithArcWithCenter:center1 radius:radius startAngle:90.0 endAngle:270.0];
			[self appendBezierPathWithArcWithCenter:center2 radius:radius startAngle:270.0 endAngle:90.0];
		}
		else if (onLeft && !onRight)
		{
			[self moveToPoint:leftStartPoint];
			[self appendBezierPathWithArcWithCenter:center1 radius:radius startAngle:90.0 endAngle:270.0];
			[self lineToPoint:NSMakePoint(NSMaxX(rect), rect.origin.y)];
			[self lineToPoint:NSMakePoint(NSMaxX(rect), NSMaxY(rect))];
			[self lineToPoint:NSMakePoint(NSMaxX(rect)+radius, NSMaxY(rect))];
		}
		else
		{
			[self moveToPoint:rightStartPoint];
			[self appendBezierPathWithArcWithCenter:center2 radius:radius startAngle:270.0 endAngle:90.0];
			[self lineToPoint:NSMakePoint(NSMinX(rect), NSMaxY(rect))];
			[self lineToPoint:NSMakePoint(NSMinX(rect), NSMinY(rect))];
			[self lineToPoint:NSMakePoint(NSMaxX(rect)-radius, NSMinY(rect))];
		}
		
		[self closePath];
	}
}

+ (NSBezierPath *)bezierPathWithTopPlateInRect:(NSRect)rect;
{	
	NSBezierPath *result = [NSBezierPath bezPath];
	[result appendBezierPathWithTopPlateInRect:rect];
	return result;	
}

- (void)appendBezierPathWithTopPlateInRect:(NSRect)rect;
{
	if (rect.size.width > 0) 
    {
		CGFloat radius = rect.size.width/2.0;
		NSPoint startPoint = NSMakePoint(NSMinX(rect), NSMinY(rect) + radius);
		NSPoint centerTop = NSMakePoint(NSMinX(rect) + radius, NSMaxY(rect) - radius);
		NSPoint centerBottom = NSMakePoint(NSMinX(rect) + radius, NSMinY(rect) + radius);
		
		[self moveToPoint:startPoint];
		[self appendBezierPathWithArcWithCenter:centerBottom radius:radius startAngle:180.0 endAngle:0.0];
		[self appendBezierPathWithArcWithCenter:centerTop radius:radius startAngle:0.0 endAngle:180.0];
		
		[self closePath];
	}
}

- (void)erasePath;
{
	SGS;
	
	[self addClip];
	[NSBezierPath eraseRect:[self bounds]];
	
	RGS;
}

// endcaps fall outside the rects passed in
+ (NSBezierPath *)endcappedBezierPathForRect:(NSRect)rect capWidth:(NSInteger)capWidth;
{
    NSBezierPath *result = nil;
    
    CGFloat thirdHeight = (NSHeight(rect) / 3.0);
    result = [NSBezierPath bezPath];
    
    [result moveToPoint:NSMakePoint(NSMinX(rect), NSMinY(rect))];
    [result curveToPoint:NSMakePoint(NSMinX(rect), NSMaxY(rect)) controlPoint1:NSMakePoint(NSMinX(rect) - capWidth, NSMidY(rect)-thirdHeight) controlPoint2:NSMakePoint(NSMinX(rect) - capWidth, NSMidY(rect)+thirdHeight)];
    [result lineToPoint:NSMakePoint(NSMaxX(rect), NSMaxY(rect))];
    [result curveToPoint:NSMakePoint(NSMaxX(rect), NSMinY(rect)) controlPoint1:NSMakePoint(NSMaxX(rect) + capWidth, NSMidY(rect)+thirdHeight) controlPoint2:NSMakePoint(NSMaxX(rect) + capWidth, NSMidY(rect)-thirdHeight)];
    
    [result closePath];
    
    return result;
}

+ (void)drawGridEffect:(NSRect)rect isFlipped:(BOOL)isFlipped;
{
    static NSImage* shared=nil;
    
    if (!shared)
        shared = [[self gridImage:NSMakeRect(0, 0, 128, 128)] retain];
    
    [shared tileInRect:rect isFlipped:isFlipped operation:NSCompositeSourceOver fraction:.05];
}

+ (void)eraseRect:(NSRect)rect;
{
	[[NSColor clearColor] set];
	NSRectFillUsingOperation(rect, NSCompositeCopy);
}    

+ (NSBezierPath*)bezPath;
{
    NSBezierPath *path = [[[NSBezierPath alloc] init] autorelease];
    [path setLineWidth:1];
    [path setFlatness:.001];
    
    return path;
}    

+ (NSBezierPath*)ovalPath:(NSRect)rect;
{    
    NSBezierPath *path = [NSBezierPath bezierPathWithOvalInRect:rect];
    [path setLineWidth:1.5];
    [path setFlatness:.01];
    
    return path;
}

+ (NSBezierPath*)rectPath:(NSRect)rect;
{    
    NSBezierPath *path = [NSBezierPath bezierPathWithRect:rect];
    [path setLineWidth:1];
    [path setFlatness:.01];
    
    return path;
}

+ (NSBezierPath*)roundRectPath:(NSRect)rect radius:(CGFloat)radius;
{
	return [self roundRectPath:rect topRadius:radius bottomRadius:radius];
}

+ (NSBezierPath*)roundRectPath:(NSRect)rect topLeftRadius:(CGFloat)topLeftRadius topRightRadius:(CGFloat)topRightRadius bottomLeftRadius:(CGFloat)bottomLeftRadius bottomRightRadius:(CGFloat)bottomRightRadius;
{
	NSBezierPath *path = [NSBezierPath bezPath];
	[path appendBezierPathWithRoundedRectangle:rect topLeftRadius:topLeftRadius topRightRadius:topRightRadius bottomLeftRadius:bottomLeftRadius bottomRightRadius:bottomRightRadius];
	
	return path;	
}

+ (NSBezierPath*)roundRectPath:(NSRect)rect topRadius:(CGFloat)topRadius bottomRadius:(CGFloat)bottomRadius;
{
	NSBezierPath *path = [NSBezierPath bezPath];
	[path appendBezierPathWithRoundedRectangle:rect topRadius:topRadius bottomRadius:bottomRadius];
	
	return path;
}

+ (NSBezierPath*)bottomRoundRectPath:(NSRect)rect radius:(CGFloat)radius;
{
	NSBezierPath *path = [NSBezierPath bezPath];
	[path appendBezierPathWithBottomRoundedCorners:rect radius:radius];
	
	return path;
}

+ (void)fillRoundRect:(NSRect)rect radius:(CGFloat)radius;
{
	[self fillRoundRect:rect radius:radius frameColor:nil];
}

+ (void)frameRoundRect:(NSRect)rect radius:(CGFloat)radius;
{
	NSBezierPath *path = [NSBezierPath roundRectPath:rect radius:radius];
	
	SGS;
	
	[path setLineWidth:1];
	[path addClip];
	[path stroke];
	
	RGS;
}

+ (void)fillRoundRect:(NSRect)rect radius:(CGFloat)radius frameColor:(NSColor*)frameColor;
{
	[self fillRoundRect:rect radius:radius frameColor:frameColor frameWidth:1.0];
}

+ (void)fillRoundRect:(NSRect)rect radius:(CGFloat)radius frameColor:(NSColor*)frameColor frameWidth:(CGFloat)frameWidth;
{
	NSBezierPath *path = [NSBezierPath roundRectPath:rect radius:radius];
	
	[path fill];	
	
	if (frameColor)
	{
		SGS;
		
		[frameColor set];
		[path setLineWidth:frameWidth];
		[path addClip];
		[path stroke];
		
		RGS;
	}
}

+ (NSBezierPath*)chevronPath:(NSRect)inRect pointingRight:(BOOL)pointingRight;
{
	NSBezierPath *path = [NSBezierPath bezPath];
	
	if (pointingRight)
	{
		[path moveToPoint:NSMakePoint(NSMinX(inRect), NSMinY(inRect))];
		[path lineToPoint:NSMakePoint(NSMinX(inRect)+3, NSMinY(inRect))];
		[path lineToPoint:NSMakePoint(NSMaxX(inRect), NSMidY(inRect))];
		
		[path lineToPoint:NSMakePoint(NSMinX(inRect)+3, NSMaxY(inRect))];
		[path lineToPoint:NSMakePoint(NSMinX(inRect), NSMaxY(inRect))];
		
		[path lineToPoint:NSMakePoint(NSMaxX(inRect)-3, NSMidY(inRect))];
		[path lineToPoint:NSMakePoint(NSMinX(inRect), NSMinY(inRect))];			
	}
	else
	{
		[path moveToPoint:NSMakePoint(NSMaxX(inRect), NSMinY(inRect))];
		[path lineToPoint:NSMakePoint(NSMaxX(inRect)-3, NSMinY(inRect))];
		[path lineToPoint:NSMakePoint(NSMinX(inRect), NSMidY(inRect))];
		
		[path lineToPoint:NSMakePoint(NSMaxX(inRect)-3, NSMaxY(inRect))];
		[path lineToPoint:NSMakePoint(NSMaxX(inRect), NSMaxY(inRect))];
		
		[path lineToPoint:NSMakePoint(NSMinX(inRect)+3, NSMidY(inRect))];
		[path lineToPoint:NSMakePoint(NSMaxX(inRect), NSMinY(inRect))];			
	}
	
	[path closePath];
	
	return path;	
}

+ (NSBezierPath*)trianglePath:(NSRect)inRect direction:(NTTrianglePathDirection)direction flipped:(BOOL)inFlipped;
{
	NSBezierPath *path = [NSBezierPath bezPath];
	
	// if flipped, just swap up and down
	if (inFlipped)
	{
		if (direction == kTrianglePointingUpDirection)
			direction = kTrianglePointingDownDirection;
		else if (direction == kTrianglePointingDownDirection)
			direction = kTrianglePointingUpDirection;
	}
	
	switch (direction)
	{
		case kTrianglePointingUpDirection:
			[path moveToPoint:NSMakePoint(NSMinX(inRect), NSMinY(inRect))];
			[path lineToPoint:NSMakePoint(NSMidX(inRect), NSMaxY(inRect))];
			[path lineToPoint:NSMakePoint(NSMaxX(inRect), NSMinY(inRect))];			
			break;
			
		case kTrianglePointingDownDirection:
			[path moveToPoint:NSMakePoint(NSMinX(inRect), NSMaxY(inRect))];
			[path lineToPoint:NSMakePoint(NSMidX(inRect), NSMinY(inRect))];
			[path lineToPoint:NSMakePoint(NSMaxX(inRect), NSMaxY(inRect))];
			break;
			
		case kTrianglePointingLeftDirection:
			[path moveToPoint:NSMakePoint(NSMaxX(inRect), NSMinY(inRect))];
			[path lineToPoint:NSMakePoint(NSMaxX(inRect), NSMaxY(inRect))];
			[path lineToPoint:NSMakePoint(NSMinX(inRect), NSMidY(inRect))];			
			break;
			
		case kTrianglePointingRightDirection:
			[path moveToPoint:NSMakePoint(NSMinX(inRect), NSMinY(inRect))];
			[path lineToPoint:NSMakePoint(NSMinX(inRect), NSMaxY(inRect))];
			[path lineToPoint:NSMakePoint(NSMaxX(inRect), NSMidY(inRect))];
			break;
	}
	
	[path closePath];
	
	return path;	
}

+ (void)fillTriangle:(NSRect)rect direction:(NTTrianglePathDirection)direction flipped:(BOOL)inFlipped;
{
	NSBezierPath *path = [NSBezierPath trianglePath:rect direction:direction flipped:inFlipped];
	
	[path fill];	
}

+ (void)fillOval:(NSRect)rect frameColor:(NSColor*)frameColor;
{
	NSBezierPath *path = [NSBezierPath ovalPath:rect];
	
	[path fill];	

	if (frameColor)
	{
		[frameColor set];
		[path stroke];
	}
}

+ (void)fillOval:(NSRect)rect;
{
	[self fillOval:rect frameColor:nil];
}

+ (void)strokeOval:(NSRect)rect;
{
	NSBezierPath *path = [NSBezierPath ovalPath:rect];
	
	[path stroke];	
}

- (void)transformPathForView:(NSView*)theView bounds:(NSRect)bounds;
{
	if ([theView isFlipped])
	{
		NSAffineTransform *flip = [NSAffineTransform transform];
		[flip translateXBy:0 yBy:NSHeight(bounds)];
		[flip scaleXBy:1 yBy:-1];
		[self transformUsingAffineTransform:flip];
	}		
	
	NSAffineTransform *originTransform = [NSAffineTransform transform];
	[originTransform translateXBy:bounds.origin.x yBy:bounds.origin.y];
	[self transformUsingAffineTransform:originTransform];
}

// caller must release
- (CGPathRef)newCGPath
{
    NSInteger i, numElements;
	
    // Need to begin a path here.
    CGPathRef immutablePath = NULL;
	
    // Then draw the path elements.
    numElements = [self elementCount];
    if (numElements > 0)
    {
        CGMutablePathRef    path = CGPathCreateMutable();
        NSPoint             points[3];
        BOOL                didClosePath = YES;
		
        for (i = 0; i < numElements; i++)
        {
            switch ([self elementAtIndex:i associatedPoints:points])
            {
                case NSMoveToBezierPathElement:
                    CGPathMoveToPoint(path, NULL, points[0].x, points[0].y);
                    break;
					
                case NSLineToBezierPathElement:
                    CGPathAddLineToPoint(path, NULL, points[0].x, points[0].y);
                    didClosePath = NO;
                    break;
					
                case NSCurveToBezierPathElement:
                    CGPathAddCurveToPoint(path, NULL, points[0].x, points[0].y,
										  points[1].x, points[1].y,
										  points[2].x, points[2].y);
                    didClosePath = NO;
                    break;
					
                case NSClosePathBezierPathElement:
                    CGPathCloseSubpath(path);
                    didClosePath = YES;
                    break;
            }
        }
		
        // Be sure the path is closed or Quartz may not do valid hit detection.
        if (!didClosePath)
            CGPathCloseSubpath(path);
		
        immutablePath = CGPathCreateCopy(path);
        CGPathRelease(path);
    }
	
    return immutablePath;
}

@end

@implementation NSBezierPath (NTExtensionsPrivate)

+ (NSImage*)gridImage:(NSRect)bounds;
{
    NTImageMaker* image = [NTImageMaker maker:bounds.size];
    
    [image lockFocus];
    
    [[NSColor whiteColor] set];
    
    NSInteger x = NSMinX(bounds);    
    while (x < NSMaxX(bounds))
    {
        [NSBezierPath fillRect:NSMakeRect(x, 0, 1, NSHeight(bounds))];
        x += 4;
    }
    
    NSInteger y = NSMinY(bounds);
    while (y < NSMaxY(bounds))
    {
        [NSBezierPath fillRect:NSMakeRect(0, y, NSWidth(bounds), 1)];
        y += 4;
    }
    
    return [image unlockFocus];
}    

@end
