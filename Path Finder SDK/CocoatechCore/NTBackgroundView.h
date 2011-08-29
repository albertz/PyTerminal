//
//  NTBackgroundView.h
//  CocoatechCore
//
//  Created by Steve Gehrman on Sun Mar 17 2002.
//  Copyright (c) 2001 CocoaTech. All rights reserved.
//

#import "NTView.h"

typedef enum
{
    kTileImageMode,
    kScaleImageMode,
    kCenterImageMode,
    kStretchImageMode,
    kFitImageMode,
} NTImageDrawingMode;

// you can set an image or backcolor
@interface NTBackgroundView : NTView
{
    NTImageDrawingMode mv_drawingMode;
    
    NSColor* mv_backColor;

	CGFloat mv_imageOpacity;
	NSImage* mv_backImage;
	NSString* mv_imagePath;
	
	BOOL mv_whiteWhenBackgroundColorIsTransparent;
}

- (void)setBackgroundColor:(NSColor*)backColor;
- (NSColor*)backgroundColor;

- (void)setImage:(NSImage*)image;

// for images that only need to draw infrequently.  Loads the image, draws and releases it.  saves ram for huge images
- (NSString *)imagePath;
- (void)setImagePath:(NSString *)theImagePath;

- (CGFloat)imageOpacity;
- (void)setImageOpacity:(CGFloat)theImageOpacity;

    // the default is to tile
- (void)setImageDrawingMode:(NTImageDrawingMode)mode;

// default is YES
- (BOOL)whiteWhenBackgroundColorIsTransparent;
- (void)setWhiteWhenBackgroundColorIsTransparent:(BOOL)flag;

@end

// non NTBackgroundView subclasses can reused the technology of drawing the background
@interface NTBackgroundView (Utilities)

+ (void)drawBackgroundInView:(NSView*)view
					clipRect:(NSRect)clipRect
					   color:(NSColor*)color 
	 eraseWhiteIfTransparent:(BOOL)eraseWhiteIfTransparent
					   image:(NSImage*)image
				   imagePath:(NSString*)imagePath
					fraction:(CGFloat)fraction
			imageDrawingMode:(NTImageDrawingMode)imageDrawingMode;

@end
