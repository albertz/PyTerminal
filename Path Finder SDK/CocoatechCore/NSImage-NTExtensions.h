//
//  NSImage-NTExtensions.h
//  CocoatechCore
//
//  Created by Steve Gehrman on Tue Nov 11 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSImage (NTExtensions)
- (void)tileInView:(NSView*)view;
- (void)tileInView:(NSView*)view fraction:(CGFloat)fraction;
- (void)tileInView:(NSView*)view fraction:(CGFloat)fraction clipRect:(NSRect)clipRect;

- (void)tileInRect:(NSRect)rect isFlipped:(BOOL)isFlipped operation:(NSCompositingOperation)operation fraction:(CGFloat)fraction;

// drawInRect that turns on NSImageInterpolationHigh
- (void)drawCenteredInRect:(NSRect)rect operation:(NSCompositingOperation)op fraction:(CGFloat)delta;

// centers the image within the rect
- (void)compositeInRect:(NSRect)frame operation:(NSCompositingOperation)op flipped:(BOOL)flipped fraction:(CGFloat)fraction;

- (NSImage*)imageWithShadow:(NSShadow*)shadow;
- (NSImage *)monochromeImage;

- (NSImage *)normalizeSize;
- (NSImage*)coloredImage:(NSColor*)color;
- (NSImage*)imageWithAlpha:(CGFloat)theAlpha;
- (NSImage*)imageWithBackground:(NSColor*)backColor;
- (NSImage*)selectedImage:(NSSize)imageSize;

- (NSData *)bmpData;
- (NSImageRep *)imageRepOfClass:(Class)imageRepClass;

- (NSImage*)sizeIcon:(int)size;
- (NSImage*)imageWithSize:(NSSize)theSize;
- (NSImage*)imageWithSize:(NSSize)theSize scaleLarger:(BOOL)scaleLarger;
- (NSImage*)imageWithTopMargin:(NSUInteger)topMargin bottomMargin:(NSUInteger)bottomMargin;
- (NSImage*)imageWithSetSize:(NSInteger)theSize;

- (NSBitmapImageRep*)bitmapImageRepForSize:(int)size;

- (BOOL)hasCachedImageRep;
- (NSImage*)imageWithOnlyCachedImageRep;

- (NSImage*)imageWithMaxSize:(int)maxSize;

// returns a new image but that has toggled it's flipped state
- (NSImage*)flip;

+ (NSImage*)imageFromCGImageRef:(CGImageRef)image;

- (NSImage*)imageWithControlImage:(NSImage*)image;

// cell template drawing
- (void)drawInRect:(NSRect)rect
			inView:(NSView*)controlView
	   highlighted:(BOOL)highlighted
   backgroundStyle:(NSBackgroundStyle)backgroundStyle;

@end

@interface NSImage (StandardImages)
+ (NSImage*)stopImage:(NSRect)rect backColor:(NSColor*)backColor lineColor:(NSColor*)lineColor;
+ (NSImage*)stopInteriorImage:(NSRect)bounds lineColor:(NSColor*)lineColor;

+ (NSImage*)plusImage:(NSRect)rect backColor:(NSColor*)backColor lineColor:(NSColor*)lineColor;
+ (NSImage*)plusInteriorImage:(NSRect)bounds lineColor:(NSColor*)lineColor;

+ (NSImage*)minusImage:(NSRect)rect backColor:(NSColor*)backColor lineColor:(NSColor*)lineColor;
+ (NSImage*)minusInteriorImage:(NSRect)bounds lineColor:(NSColor*)lineColor;
@end
