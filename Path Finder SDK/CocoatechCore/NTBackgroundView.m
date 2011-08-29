//
//  NTBackgroundView.m
//  CocoatechCore
//
//  Created by Steve Gehrman on Sun Mar 17 2002.
//  Copyright (c) 2001 CocoaTech. All rights reserved.
//

#import "NTBackgroundView.h"
#import "NTGeometry.h"
#import "NSImage-NTExtensions.h"

@interface NTBackgroundView (Private)
+ (void)drawBackgroundColorInView:(NSView*)view
							color:(NSColor*)color 
						   inRect:(NSRect)rect
		  eraseWhiteIfTransparent:(BOOL)eraseWhiteIfTransparent;

+ (void)drawBackgroundImageInView:(NSView*)view
						 clipRect:(NSRect)clipRect
							image:(NSImage*)image
						 fraction:(CGFloat)fraction
				 imageDrawingMode:(NTImageDrawingMode)imageDrawingMode;
@end

@implementation NTBackgroundView

- (id)initWithFrame:(NSRect)frame;
{
    self = [super initWithFrame:frame];

    mv_drawingMode = kTileImageMode;
	[self setWhiteWhenBackgroundColorIsTransparent:YES];
	[self setImageOpacity:1.0];

    return self;
}

- (void)dealloc;
{
    [mv_backImage release];
    [mv_backColor release];
	
	[self setImagePath:nil];
	
    [super dealloc];
}

- (BOOL)isOpaque;
{
    // we are only opaque if our backcolor has an alpha component or an image
    if (mv_backColor)
	{
		if ([self whiteWhenBackgroundColorIsTransparent])
			return YES;
		else
			return ([mv_backColor alphaComponent] == 1.0);
	}
    
    if (mv_backImage)
        return YES;
    
    return [super isOpaque];
}

- (void)setImageDrawingMode:(NTImageDrawingMode)mode;
{
    mv_drawingMode = mode;
}

- (void)setBackgroundColor:(NSColor*)backColor;
{
	if (mv_backColor != backColor)
	{
		[mv_backColor release];
		mv_backColor = [backColor retain];
	}
}

- (NSColor*)backgroundColor;
{
	return mv_backColor;
}

- (void)drawRect:(NSRect)rect;
{    
	[[self class] drawBackgroundInView:self
						clipRect:rect
						   color:[self backgroundColor] 
		 eraseWhiteIfTransparent:[self whiteWhenBackgroundColorIsTransparent]
						   image:mv_backImage
					   imagePath:mv_imagePath
							  fraction:[self imageOpacity]
				imageDrawingMode:mv_drawingMode];
}

// pass the firstResponder to my subviews (this is what scrollview does with it's contentView)
- (BOOL)becomeFirstResponder;
{
    BOOL result = [super becomeFirstResponder];

    if (![self acceptsFirstResponder])
    {
        NSArray* subviews = [self subviews];
        NSView* subview;

        for (subview in subviews)
        {
            if ([subview acceptsFirstResponder])
            {
                result = [[self window] makeFirstResponder:subview];

                break;
            }
        }
    }

    return result;
}

- (void)setImage:(NSImage*)image;
{
	if (image != mv_backImage)
	{
		[mv_backImage autorelease];
		mv_backImage = nil;
		
		if ([image isValid])
		{
			mv_backImage = [image retain];
			
			[mv_backImage setScalesWhenResized:YES];
		}
	}
}

- (BOOL)whiteWhenBackgroundColorIsTransparent
{
    return mv_whiteWhenBackgroundColorIsTransparent;
}

- (void)setWhiteWhenBackgroundColorIsTransparent:(BOOL)flag
{
    mv_whiteWhenBackgroundColorIsTransparent = flag;
}

- (NSString *)imagePath
{
    return mv_imagePath; 
}

- (void)setImagePath:(NSString *)theImagePath
{
    if (mv_imagePath != theImagePath)
    {
        [mv_imagePath release];
        mv_imagePath = [theImagePath retain];
    }
}

//---------------------------------------------------------- 
//  imageOpacity 
//---------------------------------------------------------- 
- (CGFloat)imageOpacity
{
    return mv_imageOpacity;
}

- (void)setImageOpacity:(CGFloat)theImageOpacity
{
    mv_imageOpacity = theImageOpacity;
}

@end

@implementation NTBackgroundView (Private)

+ (void)drawBackgroundColorInView:(NSView*)view
							color:(NSColor*)color 
						   inRect:(NSRect)rect
		  eraseWhiteIfTransparent:(BOOL)eraseWhiteIfTransparent;
{
    if (color)
    {
		if (eraseWhiteIfTransparent)
		{
			if ([color alphaComponent] != 1.0)
			{
				[[NSColor whiteColor] set];
				[NSBezierPath fillRect:rect];
			}
		}
		
		// optimization, if alpha is zero, don't do anything
		if ([color alphaComponent] != 0.0)
		{
			[color set];
			[NSBezierPath fillRect:rect];
		}
	}
}

+ (void)drawBackgroundImageInView:(NSView*)view
						 clipRect:(NSRect)clipRect
							image:(NSImage*)image
						 fraction:(CGFloat)fraction
				 imageDrawingMode:(NTImageDrawingMode)imageDrawingMode;
{
    if (image)
    {
        NSSize imageSize = [image size];
		
        if (!NSEqualSizes(NSZeroSize, imageSize))
        {
            NSRect rect = [view bounds];
            NSRect scaledRect = rect;
			
            if (imageDrawingMode == kScaleImageMode)
            {
                NSInteger tmp;
                CGFloat ratio;
                NSInteger diff;
				
                ratio = imageSize.height/imageSize.width;
				
                // the width will stay the same, must figure out height
                tmp = scaledRect.size.width * ratio;
				
                if (tmp < rect.size.height)
                {
                    ratio = imageSize.width/imageSize.height;
					
                    // the width will stay the same, must figure out height
                    scaledRect.size.width = scaledRect.size.height * ratio;
					
                    // center the image
                    diff = (scaledRect.size.width - rect.size.width) /  2;
                    scaledRect.origin.x -= diff;
                }
                else
                {
                    scaledRect.size.height = tmp;
					
                    diff = (scaledRect.size.height - rect.size.height) /  2;
                    scaledRect.origin.y -= diff;
                }
				
                [image setSize:NSMakeSize(scaledRect.size.width, scaledRect.size.height)];
				                
                [image compositeToPoint:scaledRect.origin operation:NSCompositeSourceOver fraction:fraction];
            }
            else if (imageDrawingMode == kTileImageMode)
                [image tileInView:view fraction:fraction clipRect:clipRect];
            else if (imageDrawingMode == kCenterImageMode)
            {
                NSRect drawRect = NSMakeRect(0,0,imageSize.width, imageSize.height);
                
                drawRect = [NTGeometry rect:drawRect centeredIn:[view bounds] scaleToFitContainer:NO];
                
                [image compositeToPoint:drawRect.origin operation:NSCompositeSourceOver fraction:fraction];
            }
			else if (imageDrawingMode == kStretchImageMode)
			{
                NSRect theImageRect = NSMakeRect(0,0,imageSize.width, imageSize.height);
                                
				[image drawInRect:[view bounds] fromRect:theImageRect operation:NSCompositeSourceOver fraction:fraction];
			}
			else if (imageDrawingMode == kFitImageMode)
			{
                NSRect theImageRect = NSMakeRect(0,0,imageSize.width, imageSize.height);
                
				NSRect drawRect = [NTGeometry rect:theImageRect centeredIn:[view bounds] scaleToFitContainer:YES canScaleLarger:YES];
                
				[image drawInRect:drawRect fromRect:theImageRect operation:NSCompositeSourceOver fraction:fraction];
			}
        }
    }
}

@end

@implementation NTBackgroundView (Utilities)

+ (void)drawBackgroundInView:(NSView*)view
					clipRect:(NSRect)clipRect
					   color:(NSColor*)color 
	 eraseWhiteIfTransparent:(BOOL)eraseWhiteIfTransparent
					   image:(NSImage*)image
				   imagePath:(NSString*)imagePath
					fraction:(CGFloat)fraction
			imageDrawingMode:(NTImageDrawingMode)imageDrawingMode;
{
	[self drawBackgroundColorInView:view
							  color:color
							 inRect:clipRect 
			eraseWhiteIfTransparent:eraseWhiteIfTransparent];
	
	if (image)
	{
		[self drawBackgroundImageInView:view
							   clipRect:clipRect
								  image:image 
							   fraction:fraction
					   imageDrawingMode:imageDrawingMode];
	}
	else if (imagePath)
	{
		NSImage* image=nil;
		
		NS_DURING
			image = [[NSImage alloc] initWithContentsOfFile:imagePath];
		NS_HANDLER
			image = nil;
		NS_ENDHANDLER
		
		if (image)
		{
			[image normalizeSize];  // Dan Woods suggestion?
			
			[image setCacheMode:NSImageCacheNever];
			[image setScalesWhenResized:YES];
			[self drawBackgroundImageInView:view
								   clipRect:clipRect
									  image:image 
								   fraction:fraction
						   imageDrawingMode:imageDrawingMode];
			
			[image release];
		}
	}
}

@end

