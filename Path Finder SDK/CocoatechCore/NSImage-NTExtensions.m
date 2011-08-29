//
//  NSImage-NTExtensions.m
//  CocoatechCore
//
//  Created by Steve Gehrman on Tue Nov 11 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import "NSImage-NTExtensions.h"
#import "NSBezierPath-NTExtensions.h"
#import "NTGeometry.h"
#import "NSGraphicsContext-NTExtensions.h"
#import "NSShadow-NTExtensions.h"
#import "NTImageMaker.h"
#import "NSWindow-NTExtensions.h"

@interface NSImage (NTExtensionsPrivate)
- (NSRect)tileRectForBounds:(NSRect)bounds;
+ (NSImage*)image:(NSRect)bounds interior:(NSImage*)image backColor:(NSColor*)backColor;
@end

@implementation NSImage (NTExtensions)

- (void)tileInView:(NSView*)view;
{
    [self tileInView:view fraction:1.0 clipRect:NSZeroRect];
}

- (void)tileInView:(NSView*)view fraction:(CGFloat)fraction;
{
    [self tileInView:view fraction:fraction clipRect:NSZeroRect];
}

- (void)tileInView:(NSView*)view fraction:(CGFloat)fraction clipRect:(NSRect)clipRect
{
    NSSize imageSize = [self size];
	
	if (imageSize.height && imageSize.width)
	{
		NSRect rect = [self tileRectForBounds:[view bounds]];

		int x, y=rect.origin.y;
		NSRect imageRect;
		NSPoint drawPoint;
		NSRect visibleRect = [view visibleRect];
		NSRect fromRect;
		
		if (!NSIsEmptyRect(clipRect))
			visibleRect = NSIntersectionRect(visibleRect, clipRect);
		
		DISABLE_FLUSH_WINDOW([view window]);

		while (y < NSMaxY(rect))
		{
			x = rect.origin.x;
			
			while (x < NSMaxX(rect))
			{
				imageRect = NSMakeRect(x,y,imageSize.width,imageSize.height);
				
				// save time, don't draw if it's not going to be visible anyway
				if (NSIntersectsRect(visibleRect, imageRect))
				{
					drawPoint = imageRect.origin;
					
					fromRect = NSIntersectionRect(visibleRect, imageRect);
					if ([view isFlipped])
					{
						drawPoint.y += NSHeight(imageRect);
						fromRect.origin.y += NSHeight(fromRect);
						
						fromRect.origin.x = fromRect.origin.x - drawPoint.x;
						fromRect.origin.y = drawPoint.y - fromRect.origin.y;
						
						drawPoint.x += fromRect.origin.x;
						drawPoint.y -= fromRect.origin.y;
					}
					else
					{
						fromRect.origin.x = fromRect.origin.x - drawPoint.x;
						fromRect.origin.y = fromRect.origin.y - drawPoint.y;
						
						drawPoint.x += fromRect.origin.x;
						drawPoint.y += fromRect.origin.y;
					}
									
					// compositeToPoint is broken.  0.0 fraction draws as 1.0
					if (fraction > 0.0)
						[self compositeToPoint:drawPoint fromRect:fromRect operation:NSCompositeSourceOver fraction:fraction];
				}
				
				x += ceil(imageSize.width);
			}
			
			y += ceil(imageSize.height);
		}
		
		ENABLE_FLUSH_WINDOW([view window]);
	}
}

- (void)tileInRect:(NSRect)rect isFlipped:(BOOL)isFlipped operation:(NSCompositingOperation)operation fraction:(CGFloat)fraction;
{
    NSSize imageSize = [self size];
	if (imageSize.height && imageSize.width)
	{
		int x, y=rect.origin.y;
		NSRect imageRect;
		NSPoint drawPoint;
		
		SGS;
		[NSBezierPath clipRect:rect];
		
		while (y < NSMaxY(rect))
		{
			x = rect.origin.x;
			
			while (x < NSMaxX(rect))
			{
				imageRect = NSMakeRect(x,y,imageSize.width,imageSize.height);
				
				drawPoint = imageRect.origin;
				
				if (isFlipped)
					drawPoint.y += imageRect.size.height;
				
				[self compositeToPoint:drawPoint operation:operation fraction:fraction];
				
				x += imageSize.width;
			}
			
			y += imageSize.height;
		}
		
		RGS;
	}
}

- (void)compositeInRect:(NSRect)frame operation:(NSCompositingOperation)op flipped:(BOOL)flipped fraction:(CGFloat)fraction;
{
	NSPoint point = frame.origin;
	
	if (flipped)
		point.y += NSHeight(frame);
		
	// center image in rect
	point.x += (NSWidth(frame) - [self size].width) / 2;
	
	if (flipped)
		point.y -= (NSHeight(frame) - [self size].height) / 2;
	else
		point.y += (NSHeight(frame) - [self size].height) / 2;
		
	[self compositeToPoint:point operation:op fraction:fraction];
}

- (void)drawCenteredInRect:(NSRect)rect operation:(NSCompositingOperation)op fraction:(CGFloat)delta;
{
	NSRect imageRect = NSZeroRect;
	imageRect.size = [self size];
	NSRect drawRect = [NTGeometry rect:imageRect centeredIn:rect scaleToFitContainer:YES];
	drawRect = [NTGeometry integerRect:drawRect];
		
	[self drawInRect:drawRect fromRect:NSZeroRect operation:op fraction:delta];
}

typedef struct
{
    unsigned char grayValue;
    unsigned char alpha;
} MonochromePixel;

- (NSImage *)monochromeImage
{
    NSSize mySize = [self size];
	
    NSImage *monochromeImage = [[[self class] alloc] initWithSize:mySize];
	
    int row, column, widthInPixels = mySize.width, heightInPixels = mySize.height;
	
    // Need a place to put the monochrome pixels.
    NSBitmapImageRep *blackAndWhiteRep = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes: nil  // Nil pointer tells the kit to allocate the pixel buffer for us.
                                                                                 pixelsWide: widthInPixels
                                                                                 pixelsHigh: heightInPixels
                                                                              bitsPerSample: 8
                                                                            samplesPerPixel: 2
                                                                                   hasAlpha: YES
                                                                                   isPlanar: NO
                                                                             colorSpaceName: NSCalibratedWhiteColorSpace // 0 = black, 1 = white in this color space.
                                                                                bytesPerRow: 0     // Passing zero means "you figure it out."
                                                                               bitsPerPixel: 16];  // This must agree with bitsPerSample and samplesPerPixel.
	
    MonochromePixel *pixels = (MonochromePixel *)[blackAndWhiteRep bitmapData];  // -bitmapData returns a void*, not an NSData object ;-)
	
    [self lockFocus]; // necessary for NSReadPixel() to work.
    for (row = 0; row < heightInPixels; row++)
    {
        for (column = 0; column < widthInPixels; column++)
        {
            MonochromePixel *thisPixel = &(pixels[((widthInPixels * row) + column)]);
			
            NSColor *pixelColor = NSReadPixel(NSMakePoint(column, heightInPixels - (row +1)));
			
            //  thisPixel->grayValue = 1.0 - rint(255 *      // use this line for negative..
            thisPixel->grayValue = rint(255 * (0.299 * [pixelColor redComponent]
                                               + 0.587 * [pixelColor greenComponent]
                                               + 0.114 * [pixelColor blueComponent]));
			
            // handle the transparency, too
            thisPixel->alpha = ([pixelColor alphaComponent] * 255);
         }
    }
    [self unlockFocus];
	
    [monochromeImage addRepresentation:blackAndWhiteRep];
    [blackAndWhiteRep release];
	
    return [monochromeImage autorelease];
}

- (NSImage*)imageWithShadow:(NSShadow*)shadow;
{
	NTImageMaker *result = [NTImageMaker maker:[self size]];
	
	[result lockFocus];

	[shadow set];
		
	[self compositeToPoint:NSMakePoint(0,0) operation:NSCompositeSourceOver fraction:1.0];
	
	return [result unlockFocus:[self isTemplate]];
}

- (NSImage*)imageWithBackground:(NSColor*)backColor;
{
	NSRect imageRect = NSZeroRect;
	imageRect.size = [self size];
	
	NTImageMaker *result = [NTImageMaker maker:imageRect.size];
	
	[result lockFocus];
	
	[backColor set];
	[NSBezierPath fillRect:imageRect];
	
	[self compositeToPoint:NSMakePoint(0,0) operation:NSCompositeSourceOver fraction:1.0];
	
	return [result unlockFocus:[self isTemplate]];
}

/*" If a bitmap image, fix the size of the bitmap so that it is equal to the exact pixel dimensions. "*/

- (NSImage *) normalizeSize
{
	NSBitmapImageRep *theBitmap = nil;
	NSSize newSize;
	NSArray *reps = [self representations];
	
	for (NSImageRep *theRep in reps )
	{
		if ([theRep isKindOfClass:[NSBitmapImageRep class]])
		{
			theBitmap = (NSBitmapImageRep *)theRep;
			break;
		}
	}
	if (nil != theBitmap)
	{
		newSize.width = [theBitmap pixelsWide];
		newSize.height = [theBitmap pixelsHigh];
		[theBitmap setSize:newSize];
		[self setSize:newSize];
	}
	return self;
}

- (NSImage*)coloredImage:(NSColor*)color;
{
	NTImageMaker *result = [NTImageMaker maker:[self size]];
	
	NSRect imageRect = NSZeroRect;
	imageRect.size = [self size];
		
	[result lockFocus];
	
	[color set];
	[NSBezierPath fillRect:imageRect];
	
	[self compositeToPoint:NSMakePoint(0,0) operation:NSCompositeDestinationIn fraction:1.0];
		
	return [result unlockFocus:[self isTemplate]];
}

- (NSImage*)selectedImage:(NSSize)imageSize;
{
	NTImageMaker *result = [NTImageMaker maker:imageSize];
	
	NSRect imageRect = NSZeroRect;
	imageRect.size = imageSize;
	
	[result lockFocus];
	
	[[NSColor colorWithCalibratedWhite:0 alpha:.5] set];
	[NSBezierPath fillRect:imageRect];
	
	NSRect destRect = NSZeroRect;
	destRect.size = imageSize;
	
	[self drawInRect:destRect fromRect:NSZeroRect operation:NSCompositeDestinationAtop fraction:1.0];
	
	return [result unlockFocus:[self isTemplate]];
}

- (NSImage*)imageWithAlpha:(CGFloat)theAlpha;
{
	NTImageMaker *result = [NTImageMaker maker:[self size]];
	
	NSRect imageRect = NSZeroRect;
	imageRect.size = [self size];
	
	[result lockFocus];
		
	[self compositeToPoint:NSMakePoint(0,0) operation:NSCompositeSourceOver fraction:theAlpha];
	
	return [result unlockFocus:[self isTemplate]];	
}

- (NSImage*)imageWithMaxSize:(int)maxSize;
{
	NTImageMaker *result = [NTImageMaker maker:NSMakeSize(maxSize, maxSize)];
	
	NSRect imageRect = NSZeroRect;
	imageRect.size = [self size];
	NSRect newRect = [NTGeometry rect:imageRect centeredIn:NSMakeRect(0,0,maxSize,maxSize) scaleToFitContainer:YES];

	[result lockFocus];
	
	[self drawInRect:newRect fromRect:imageRect operation:NSCompositeSourceOver fraction:1.0];

	return [result unlockFocus:[self isTemplate]];
}
	
- (NSImage*)imageWithSize:(NSSize)theSize;
{
	return [self imageWithSize:theSize scaleLarger:YES];
}

- (NSImage*)imageWithSize:(NSSize)theSize scaleLarger:(BOOL)scaleLarger;
{
	NSSize srcSize = [self size];
	
	if (!NSEqualSizes(srcSize, theSize))
	{
		NSRect destRect = NSMakeRect(0, 0, theSize.width, theSize.height);		
		NSRect srcRect = NSMakeRect(0, 0, srcSize.width, srcSize.height);
		
		NSRect imageRect = [NTGeometry rect:srcRect centeredIn:destRect scaleToFitContainer:YES canScaleLarger:scaleLarger];
		imageRect = [NTGeometry integerRect:imageRect];
		
		NTImageMaker *result = [NTImageMaker maker:destRect.size];
				
		[result lockFocus];
		
		[self drawInRect:imageRect fromRect:srcRect operation:NSCompositeSourceOver fraction:1.0];
		
		return [result unlockFocus:[self isTemplate]];
	}
	
	return self;
}

- (NSImage*)imageWithTopMargin:(NSUInteger)topMargin bottomMargin:(NSUInteger)bottomMargin;
{
	NSSize srcSize = [self size];
	
	NSRect srcRect = NSMakeRect(0, 0, srcSize.width, srcSize.height);
	NSRect destRect = srcRect;		
	destRect.size.height += (topMargin + bottomMargin);
	destRect.origin.y += bottomMargin;
	
	NTImageMaker *result = [NTImageMaker maker:destRect.size];
	[result lockFocus];
	
	[self compositeToPoint:destRect.origin operation:NSCompositeSourceOver fraction:1];
	
	return [result unlockFocus:[self isTemplate]];
}

- (NSImage*)imageWithSetSize:(NSInteger)theSize;
{
	NSImage* result = [self copy];
	
	[result setSize:NSMakeSize(theSize, theSize)];
	
	return [result autorelease];
}

// find the right representation and create a new autoreleased NSImage
// we don't want to change the size of the original
- (NSImage*)sizeIcon:(int)size;
{
    NSImage* sizedImage = nil;
    NSArray* reps = [self representations];
    int i, cnt = [reps count];
    NSImageRep *rep;
	
    for (i=0;i<cnt;i++)
    {
        rep = [reps objectAtIndex:i];
		
        if (([rep size].width == size) && ([rep size].height == size))
        {
			sizedImage = [[[NSImage alloc] initWithSize:NSMakeSize(size, size)] autorelease];
            // a rep can't exist in more than one image, so copy it
            rep = [[rep copy] autorelease];
            [sizedImage addRepresentation:rep];
            break;
        }
    }
	
    // the size wasn't found, so lets draw the image scaled inside the correct size rectangle
    if (!sizedImage)
    {
        NSImageRep* closestRep=nil;
		
        // need to find the closest size for our source rectangle
        for (i=0;i<cnt;i++)
        {
            rep = [reps objectAtIndex:i];
			
            if (closestRep)
            {
                // is this a closer match?
                if (abs([rep size].width - size) < abs([closestRep size].width - size))
                {
                    // is it bigger than the size passed in?
                    if ([rep size].width > size)
                        closestRep = rep;
                }
            }
            else
                closestRep = rep;
        }
		
		if (closestRep)
		{
			NSRect srcRect = NSZeroRect;
			srcRect.size = [closestRep size];
			
			NTImageMaker *maker = [NTImageMaker maker:NSMakeSize(size, size)];
			[maker lockFocus];
			
			NSRect destRect = NSMakeRect(0, 0, size, size);
			
			// if height and width are different, we don't want distortion
			if (srcRect.size.height != srcRect.size.width)
				destRect = [NTGeometry rect:srcRect centeredIn:destRect scaleToFitContainer:YES];
			
			[closestRep drawInRect:destRect];
			
			sizedImage = [maker unlockFocus:[self isTemplate]];
		}
    }
	
    return sizedImage;
}

- (NSBitmapImageRep*)bitmapImageRepForSize:(int)size;
{
	NSRect imageRect = NSMakeRect(0, 0, size, size);
	NTImageMaker *imageMaker = [NTImageMaker maker:imageRect.size];
	[imageMaker lockFocus];
	
	NSRect drawRect = NSZeroRect;
	drawRect.size = [self size];
	
	drawRect = [NTGeometry rect:drawRect centeredIn:imageRect scaleToFitContainer:YES canScaleLarger:YES];
	drawRect = [NTGeometry integerRect:drawRect];
	
	[self drawInRect:drawRect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0 respectFlipped:NO hints:nil];
	
	[imageMaker unlockFocus];
	
	return [imageMaker imageRep];
}

- (BOOL)hasCachedImageRep;
{
	NSEnumerator* enumerator = [[self representations] objectEnumerator];
	NSImageRep* rep;
	
	while (rep = [enumerator nextObject])
	{		
		if ([rep isKindOfClass:[NSCachedImageRep class]])
			return YES;
	}
	
	return NO;
}

- (NSImage*)imageWithOnlyCachedImageRep;
{    
	NSImage* newImage = nil;
	NSImageRep* rep;
	NSImageRep* largestRep=nil;
	NSEnumerator* enumerator = [[self representations] objectEnumerator];
	
	while (rep = [enumerator nextObject])
	{
		if ([rep isKindOfClass:[NSCachedImageRep class]])
		{
			if (largestRep)
			{
				NSSize repSize = [rep size];
				NSSize largestSize = [largestRep size];
				
				if ((repSize.width > largestSize.width) || (repSize.height > largestSize.height))
					largestRep = rep;
			}
			else
				largestRep = rep;
		}
	}
	
	if (largestRep)
	{
		newImage = [[[NSImage alloc] initWithSize:[self size]] autorelease];
		
		[largestRep retain];
		[self removeRepresentation:largestRep];
		[newImage addRepresentation:largestRep];
		[largestRep release];
	}
	
	if (!newImage)
	{
		NTImageMaker* imageMaker = [NTImageMaker maker:[self size]];
		[imageMaker lockFocus];
		[self compositeToPoint:NSMakePoint(0,0) operation:NSCompositeCopy];
		newImage = [imageMaker unlockFocus];
	}
	
	return newImage;
}

- (NSImage*)flip;
{
	NSSize size = [self size];
		
	if ((size.height > 0) && (size.width > 0))
	{
		NTImageMaker* result = [NTImageMaker maker:size];

		[result lockFocus];
		
		NSRect drawRect = NSZeroRect;
		drawRect.size = size;
		
		SGS;
		
		CGContextRef contextRef = [[NSGraphicsContext currentContext] graphicsPort];
		CGContextTranslateCTM(contextRef, 0, size.height);
        CGContextScaleCTM(contextRef, 1, -1);
		
		[self drawInRect:drawRect fromRect:NSMakeRect(0, 0, size.width, size.height) operation:NSCompositeCopy fraction:1.0];
				
		RGS;
		
		return [result unlockFocus:[self isTemplate]];
	}
	
	return self;
}

+ (NSImage*)imageFromCGImageRef:(CGImageRef)cgImage
{
	NSImage* result = [[NSImage alloc] initWithCGImage:(CGImageRef)cgImage size:NSZeroSize];

	return [result autorelease];
}

- (NSImage*)imageWithControlImage:(NSImage*)controlImage;
{	
	NSRect totalRect = NSZeroRect;
	totalRect.size.width = self.size.width + controlImage.size.width + 4;
	totalRect.size.height = MAX(self.size.height, controlImage.size.height);

	NTImageMaker *result = [NTImageMaker maker:totalRect.size];
	
	[result lockFocus];
	
	NSRect arrowRect, contentRect;
	
	NSDivideRect(totalRect, &arrowRect, &contentRect, controlImage.size.width, NSMaxXEdge);
	
	// center arrow
	arrowRect.origin.y += rint((NSHeight(arrowRect) - [controlImage size].height) / 2);
	arrowRect.origin.y -= 1;
	
	[self drawCenteredInRect:contentRect operation:NSCompositeSourceOver fraction:1.0];
	[controlImage compositeToPoint:arrowRect.origin operation:NSCompositeSourceOver fraction:1.0];
	
	return [result unlockFocus:[self isTemplate]];
}

- (void)drawInRect:(NSRect)rect
			inView:(NSView*)controlView
	   highlighted:(BOOL)highlighted
   backgroundStyle:(NSBackgroundStyle)backgroundStyle;
{
	static NSImageCell* shared; 
	
	if (!shared)
	{
		shared = [[NSImageCell alloc] init];
		
		// don't scale image
		[shared setImageScaling:NSScaleNone];
	}
	
	if ([[controlView window] dimControls])
		backgroundStyle = NSBackgroundStyleLight;
	
	[shared setBackgroundStyle:backgroundStyle];
	
	// optimization, keep same image if already OK
	if ([shared image] != self)
		[shared setImage:self];
	
	if ([shared isHighlighted] != highlighted)
		[shared setHighlighted:highlighted];
	
	[shared drawWithFrame:rect inView:controlView];
}	

- (NSImageRep *)imageRepOfClass:(Class)imageRepClass;
{
    NSArray *representations = [self representations];
    unsigned int representationIndex, representationCount = [representations count];
    for (representationIndex = 0; representationIndex < representationCount; representationIndex++) {
        NSImageRep *rep = [representations objectAtIndex:representationIndex];
        if ([rep isKindOfClass:imageRepClass]) {
            return rep;
        }
    }
    return nil;
}

#include <stdlib.h>
#include <memory.h>

- (NSData *)bmpData;
{
	NSColor *backgroundColor = nil;
	
    /* 	This is a Unix port of the bitmap.c code that writes .bmp files to disk.
	 It also runs on Win32, and should be easy to get to run on other platforms.
	 Please visit my web page, http://www.ece.gatech.edu/~slabaugh and click on "c" and "Writing Windows Bitmaps" for a further explanation.  This code has been tested and works on HP-UX 11.00 using the cc compiler.  To compile, just type "cc -Ae bitmapUnix.c" at the command prompt.
	 
	 The Windows .bmp format is little endian, so if you're running this code on a big endian system it will be necessary to swap bytes to write out a little endian file.
	 
	 Thanks to Robin Pitrat for testing on the Linux platform.
	 
	 Greg Slabaugh, 11/05/01
	 */
	
	
    // This pragma is necessary so that the data in the structures is aligned to 2-byte boundaries.  Some different compilers have a different syntax for this line.  For example, if you're using cc on Solaris, the line should be #pragma pack(2).
#pragma pack(2)
	
    // Default data types.  Here, uint16 is an unsigned integer that has size 2 bytes (16 bits), and uint32 is datatype that has size 4 bytes (32 bits).  You may need to change these depending on your compiler.
#define uint16 unsigned short
#define uint32 unsigned int
	
#define BI_RGB 0
#define BM 19778
	
    typedef struct {
        uint16 bfType;
        uint32 bfSize;
        uint16 bfReserved1;
        uint16 bfReserved2;
        uint32 bfOffBits;
    } BITMAPFILEHEADER;
	
    typedef struct {
        uint32 biSize;
        uint32 biWidth;
        uint32 biHeight;
        uint16 biPlanes;
        uint16 biBitCount;
        uint32 biCompression;
        uint32 biSizeImage;
        uint32 biXPelsPerMeter;
        uint32 biYPelsPerMeter;
        uint32 biClrUsed;
        uint32 biClrImportant;
    } BITMAPINFOHEADER;
	
	
    typedef struct {
        unsigned char rgbBlue;
        unsigned char rgbGreen;
        unsigned char rgbRed;
        unsigned char rgbReserved;
    } RGBQUAD;
	
	
    NSBitmapImageRep *bitmapImageRep = (id)[self imageRepOfClass:[NSBitmapImageRep class]];
    if (bitmapImageRep == nil || backgroundColor != nil) {
        NSRect imageBounds = {NSZeroPoint, [self size]};
        NSImage *newImage = [[NSImage alloc] initWithSize:imageBounds.size];
        [newImage lockFocus]; {
            [backgroundColor ? backgroundColor : [NSColor clearColor] set];
            NSRectFill(imageBounds);
            [self drawInRect:imageBounds fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
            bitmapImageRep = [[[NSBitmapImageRep alloc] initWithFocusedViewRect:imageBounds] autorelease];
        } [newImage unlockFocus];
        [newImage release];
    }
	
    uint32 width = [bitmapImageRep pixelsWide];
    uint32 height= [bitmapImageRep pixelsHigh];
    unsigned char *image = [bitmapImageRep bitmapData];
    unsigned int samplesPerPixel = [bitmapImageRep samplesPerPixel];
	
    /*
     This function writes out a 24-bit Windows bitmap file that is readable by Microsoft Paint.
     The image data is a 1D array of (r, g, b) triples, where individual (r, g, b) values can
     each take on values between 0 and 255, inclusive.
	 
     The input to the function is:
     uint32 width:					The width, in pixels, of the bitmap
     uint32 height:					The height, in pixels, of the bitmap
     unsigned char *image:				The image data, where each pixel is 3 unsigned chars (r, g, b)
	 
     Written by Greg Slabaugh (slabaugh@ece.gatech.edu), 10/19/00
     */
    uint32 extrabytes = (4 - (width * 3) % 4) % 4;
	
    /* This is the size of the padded bitmap */
    uint32 bytesize = (width * 3 + extrabytes) * height;
	
    NSMutableData *mutableBMPData = [NSMutableData data];
	
    /* Fill the bitmap file header structure */
    BITMAPFILEHEADER bmpFileHeader;
    bmpFileHeader.bfType = NSSwapHostShortToLittle(BM);   /* Bitmap header */
    bmpFileHeader.bfSize = NSSwapHostIntToLittle(0);      /* This can be 0 for BI_RGB bitmaps */
    bmpFileHeader.bfReserved1 = NSSwapHostShortToLittle(0);
    bmpFileHeader.bfReserved2 = NSSwapHostShortToLittle(0);
    bmpFileHeader.bfOffBits = NSSwapHostIntToLittle(sizeof(BITMAPFILEHEADER) + sizeof(BITMAPINFOHEADER));
    [mutableBMPData appendBytes:&bmpFileHeader length:sizeof(BITMAPFILEHEADER)];
	
    /* Fill the bitmap info structure */
    BITMAPINFOHEADER bmpInfoHeader;
    bmpInfoHeader.biSize = NSSwapHostIntToLittle(sizeof(BITMAPINFOHEADER));
    bmpInfoHeader.biWidth = NSSwapHostIntToLittle(width);
    bmpInfoHeader.biHeight = NSSwapHostIntToLittle(height);
    bmpInfoHeader.biPlanes = NSSwapHostShortToLittle(1);
    bmpInfoHeader.biBitCount = NSSwapHostShortToLittle(24);            /* 24 - bit bitmap */
    bmpInfoHeader.biCompression = NSSwapHostIntToLittle(BI_RGB);
    bmpInfoHeader.biSizeImage = NSSwapHostIntToLittle(bytesize);     /* includes padding for 4 byte alignment */
    bmpInfoHeader.biXPelsPerMeter = NSSwapHostIntToLittle(0);
    bmpInfoHeader.biYPelsPerMeter = NSSwapHostIntToLittle(0);
    bmpInfoHeader.biClrUsed = NSSwapHostIntToLittle(0);
    bmpInfoHeader.biClrImportant = NSSwapHostIntToLittle(0);
    [mutableBMPData appendBytes:&bmpInfoHeader length:sizeof(BITMAPINFOHEADER)];
	
    /* Allocate memory for some temporary storage */
    unsigned char *paddedImage = (unsigned char *)calloc(sizeof(unsigned char), bytesize);
	
    // This code does three things.  First, it flips the image data upside down, as the .bmp format requires an upside down image.  Second, it pads the image data with extrabytes number of bytes so that the width in bytes of the image data that is written to the file is a multiple of 4.  Finally, it swaps (r, g, b) for (b, g, r).  This is another quirk of the .bmp file format.
	
    uint32 row, column;
    for (row = 0; row < height; row++) {
        unsigned char *imagePtr = image + (height - 1 - row) * width * samplesPerPixel;
        unsigned char *paddedImagePtr = paddedImage + row * (width * 3 + extrabytes);
        for (column = 0; column < width; column++) {
            *paddedImagePtr = *(imagePtr + 2);
            *(paddedImagePtr + 1) = *(imagePtr + 1);
            *(paddedImagePtr + 2) = *imagePtr;
            imagePtr += samplesPerPixel;
            paddedImagePtr += 3;
        }
    }
	
    /* Write bmp data */
    [mutableBMPData appendBytes:paddedImage length:bytesize];
	
    free(paddedImage);
	
    return mutableBMPData;
}

@end

@implementation NSImage (NTExtensionsPrivate)

+ (NSImage*)image:(NSRect)bounds interior:(NSImage*)interior backColor:(NSColor*)backColor;
{
	NSRect rect = NSInsetRect(bounds, 2, 2);
	NSBezierPath *outerPath;
	
	NSShadow *blackShadow = [NSShadow shadowWithColor:[[NSColor blackColor] colorWithAlphaComponent:.2] offset:NSMakeSize(0, -1) blurRadius:0];
	
	outerPath = [NSBezierPath ovalPath:rect];
	
	// create the image
	NTImageMaker* image = [NTImageMaker maker:bounds.size];
	[image lockFocus];
	
	SGS;
	[backColor set];
	[outerPath fill];
	
	[outerPath addClip];

	[[[NSColor blackColor] colorWithAlphaComponent:.15] set];
	[outerPath stroke];
	RGS;
	
	[blackShadow set];
	NSRect interiorBounds = bounds;
	interiorBounds.size = [interior size];
	interiorBounds = [NTGeometry rect:interiorBounds centeredIn:bounds scaleToFitContainer:NO];
	[interior compositeToPoint:interiorBounds.origin operation:NSCompositeSourceOver fraction:1.0];
	
	return [image unlockFocus];
}

- (NSRect)tileRectForBounds:(NSRect)bounds;
{
	NSRect imageRect = NSZeroRect;
	NSSize imageSize = [self size];
	
	// must have a size, otherwise we endless loop
	if (imageSize.height && imageSize.width)
	{
		imageRect.size = imageSize;
		
		imageRect = [NTGeometry rect:imageRect centeredIn:bounds scaleToFitContainer:NO];
		
		while (imageRect.origin.x > bounds.origin.x || imageRect.origin.y > bounds.origin.y)
		{
			imageRect.origin.x -= imageSize.width;
			imageRect.origin.y -= imageSize.height;
		}
	}
	
	return NSUnionRect(imageRect, bounds);
}

@end

@implementation NSImage (StandardImages)

+ (NSImage*)stopInteriorImage:(NSRect)bounds lineColor:(NSColor*)lineColor;
{
    NSBezierPath* copy, *linePath = [NSBezierPath bezPath];
    NSRect imageBounds = bounds;
	imageBounds.origin = NSZeroPoint;
	
    [linePath setLineWidth:1.5];
    [linePath moveToPoint: NSMakePoint(0, (imageBounds.size.height/2))];
    [linePath lineToPoint: NSMakePoint(imageBounds.size.width, (imageBounds.size.height/2))];
    
    // create the image
    NTImageMaker* image = [NTImageMaker maker:imageBounds.size];
	
    [image lockFocus];
    
    [lineColor set];
    
    [NSBezierPath clipRect:NSInsetRect(imageBounds, NSWidth(imageBounds)/3.5, NSHeight(imageBounds)/3.5)];
    
    NSAffineTransform* transform = [NSAffineTransform transform];
    [transform translateXBy:imageBounds.size.width/2 yBy:imageBounds.size.height/2];
    [transform rotateByDegrees:45];
    [transform translateXBy:-(imageBounds.size.width/2) yBy:-(imageBounds.size.height/2)];
    copy = [[linePath copy] autorelease];
    [copy transformUsingAffineTransform: transform];
    [copy stroke];
    
    transform = [NSAffineTransform transform];
    [transform translateXBy:imageBounds.size.width/2 yBy:imageBounds.size.height/2];
    [transform rotateByDegrees:-45];
    [transform translateXBy:-(imageBounds.size.width/2) yBy:-(imageBounds.size.height/2)];
    copy = [[linePath copy] autorelease];
    [copy transformUsingAffineTransform: transform];
    [copy stroke];
    
	return [image unlockFocus];
}

+ (NSImage*)stopImage:(NSRect)bounds backColor:(NSColor*)backColor lineColor:(NSColor*)lineColor;
{
	NSImage* interior = [self stopInteriorImage:NSInsetRect(bounds, 1, 1) lineColor:lineColor];
	
	return [self image:bounds interior:interior backColor:backColor];
}    

+ (NSImage*)plusInteriorImage:(NSRect)bounds lineColor:(NSColor*)lineColor;
{
    NSBezierPath* copy, *linePath = [NSBezierPath bezPath];
    
    [linePath setLineWidth:1.5];
    [linePath moveToPoint: NSMakePoint(0, (bounds.size.height/2))];
    [linePath lineToPoint: NSMakePoint(bounds.size.width, (bounds.size.height/2))];
    
    // create the image
    NTImageMaker* image = [NTImageMaker maker:bounds.size];
	
    [image lockFocus];
    
    [lineColor set];
    
    [NSBezierPath clipRect:NSInsetRect(bounds, NSWidth(bounds)/3.5, NSHeight(bounds)/3.5)];
    
    [linePath stroke];
    
    NSAffineTransform* transform = [NSAffineTransform transform];
    [transform translateXBy:bounds.size.width/2 yBy:bounds.size.height/2];
    [transform rotateByDegrees:90];
    [transform translateXBy:-(bounds.size.width/2) yBy:-(bounds.size.height/2)];
    copy = [[linePath copy] autorelease];
    [copy transformUsingAffineTransform: transform];
    [copy stroke];
    
    return [image unlockFocus];
}

+ (NSImage*)plusImage:(NSRect)bounds backColor:(NSColor*)backColor lineColor:(NSColor*)lineColor;
{
	NSImage* interior = [self plusInteriorImage:bounds lineColor:lineColor];
	
	return [self image:bounds interior:interior backColor:backColor];
}    

+ (NSImage*)minusInteriorImage:(NSRect)bounds lineColor:(NSColor*)lineColor;
{
    NSBezierPath *linePath = [NSBezierPath bezPath];
    
    [linePath setLineWidth:1.5];
    [linePath moveToPoint: NSMakePoint(0, (bounds.size.height/2))];
    [linePath lineToPoint: NSMakePoint(bounds.size.width, (bounds.size.height/2))];
    
    // create the image
    NTImageMaker* image = [NTImageMaker maker:bounds.size];
	
    [image lockFocus];
    
    [lineColor set];
    
    [NSBezierPath clipRect:NSInsetRect(bounds, NSWidth(bounds)/3.5, NSHeight(bounds)/3.5)];
    
    [linePath stroke];
    
    return [image unlockFocus];
}

+ (NSImage*)minusImage:(NSRect)bounds backColor:(NSColor*)backColor lineColor:(NSColor*)lineColor;
{
	NSImage* interior = [self minusInteriorImage:bounds lineColor:lineColor];
	
	return [self image:bounds interior:interior backColor:backColor];
}    

@end

