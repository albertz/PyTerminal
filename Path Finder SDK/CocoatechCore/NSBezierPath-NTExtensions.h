//
//  NSBezierPathExtensions.h
//  CocoatechCore
//

#import <Cocoa/Cocoa.h>

typedef enum NTTrianglePathDirection
{
	kTrianglePointingUpDirection,
	kTrianglePointingDownDirection,
	kTrianglePointingLeftDirection,
	kTrianglePointingRightDirection
} NTTrianglePathDirection;

@interface NSBezierPath  (NTExtensions)

- (BOOL)isClosed;
- (NSBezierPath *)closedPath;

- (void)appendBezierPathWithRoundedRectangle:(NSRect)aRect radius:(CGFloat)radius;
- (void)appendBezierPathWithRoundedRectangle:(NSRect)aRect topRadius:(CGFloat)topRadius bottomRadius:(CGFloat)bottomRadius;
- (void)appendBezierPathWithRoundedRectangle:(NSRect)aRect radius:(CGFloat)radius leftSideOnly:(BOOL)leftSideOnly;
- (void)appendBezierPathWithBottomRoundedCorners:(NSRect)aRect radius:(CGFloat)radius;
- (void)appendBezierPathWithRoundedRectangle:(NSRect)rect topLeftRadius:(CGFloat)topLeftRadius topRightRadius:(CGFloat)topRightRadius bottomLeftRadius:(CGFloat)bottomLeftRadius bottomRightRadius:(CGFloat)bottomRightRadius;

- (NSImage*)convertToImage:(NSColor*)color frameColor:(NSColor*)frameColor template:(BOOL)template;

+ (NSImage*)downTriangleImage:(NSRect)inRect flipped:(BOOL)flipped;
+ (NSImage*)rightTriangleImage:(NSRect)inRect;
+ (NSImage*)leftTriangleImage:(NSRect)inRect;

+ (NSBezierPath*)downArrowPath:(NSRect)inRect;
+ (NSImage*)downArrowImage:(NSRect)inRect;
+ (NSImage*)upArrowImage:(NSRect)inRect;

+ (NSBezierPath *)bezierPathWithPlateInRect:(NSRect)rect;
+ (NSBezierPath *)bezierPathWithPlateInRect:(NSRect)rect onLeft:(BOOL)onLeft onRight:(BOOL)onRight;
- (void)appendBezierPathWithPlateInRect:(NSRect)rect onLeft:(BOOL)onLeft onRight:(BOOL)onRight;

// top and bottom have plate
+ (NSBezierPath *)bezierPathWithTopPlateInRect:(NSRect)rect;
- (void)appendBezierPathWithTopPlateInRect:(NSRect)rect;

// endcaps fall outside the rects passed in
+ (NSBezierPath *)endcappedBezierPathForRect:(NSRect)rect capWidth:(NSInteger)capWidth;

+ (void)drawGridEffect:(NSRect)rect isFlipped:(BOOL)isFlipped;

+ (void)eraseRect:(NSRect)rect;
- (void)erasePath;

+ (NSBezierPath*)bezPath;
+ (NSBezierPath*)ovalPath:(NSRect)rect;
+ (NSBezierPath*)rectPath:(NSRect)rect;
+ (NSBezierPath*)trianglePath:(NSRect)rect direction:(NTTrianglePathDirection)direction flipped:(BOOL)inFlipped;
+ (NSBezierPath*)roundRectPath:(NSRect)rect radius:(CGFloat)radius;
+ (NSBezierPath*)roundRectPath:(NSRect)rect topRadius:(CGFloat)topRadius bottomRadius:(CGFloat)bottomRadius;
+ (NSBezierPath*)roundRectPath:(NSRect)rect topLeftRadius:(CGFloat)topLeftRadius topRightRadius:(CGFloat)topRightRadius bottomLeftRadius:(CGFloat)bottomLeftRadius bottomRightRadius:(CGFloat)bottomRightRadius;
+ (NSBezierPath*)chevronPath:(NSRect)imageBounds pointingRight:(BOOL)pointingRight;

+ (void)fillRoundRect:(NSRect)rect radius:(CGFloat)radius;
+ (void)fillRoundRect:(NSRect)rect radius:(CGFloat)radius frameColor:(NSColor*)frameColor;
+ (void)fillRoundRect:(NSRect)rect radius:(CGFloat)radius frameColor:(NSColor*)frameColor frameWidth:(CGFloat)frameWidth;
+ (void)fillTriangle:(NSRect)rect direction:(NTTrianglePathDirection)direction flipped:(BOOL)inFlipped;
+ (void)fillOval:(NSRect)rect;
+ (void)strokeOval:(NSRect)rect;
+ (void)fillOval:(NSRect)rect frameColor:(NSColor*)frameColor;
+ (void)frameRoundRect:(NSRect)rect radius:(CGFloat)radius;
+ (NSBezierPath*)bottomRoundRectPath:(NSRect)rect radius:(CGFloat)radius;
- (void)transformPathForView:(NSView*)theView bounds:(NSRect)bounds;

// caller must release
- (CGPathRef)newCGPath;

@end
