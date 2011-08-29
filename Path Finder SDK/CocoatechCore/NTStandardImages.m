//
//  NTStandardImages.m
//  CocoatechCore
//
//  Created by Steve Gehrman on 7/23/04.
//  Copyright 2004 __MyCompanyName__. All rights reserved.
//

#import "NTStandardImages.h"
#import "NSBundle-NTExtensions.h"
#import "NTImageMaker.h"
#import "NSImage-NTExtensions.h"
#import "NSAttributedString-NTExtensions.h"
#import "NTColorSet.h"

@implementation NTStandardImages

+ (NSImage*)resizeIndicator;
{
    NSRect bounds = NSMakeRect(0,0, 12, 12);
    NSBezierPath *linePath = [NSBezierPath bezPath];
    [linePath setLineWidth:.5];

    [linePath moveToPoint:bounds.origin];
    [linePath lineToPoint:NSMakePoint(NSMaxX(bounds), NSMaxY(bounds))];
    
    NSAffineTransform* transform = [NSAffineTransform transform];
    [transform translateXBy:1.5 yBy:0];
    
    // create the image
    NTImageMaker* imageMaker = [NTImageMaker maker:bounds.size];
    [imageMaker lockFocus];
    
    NSColor *blackColor = [[NSColor blackColor] colorWithAlphaComponent:.9];
    NSColor* whiteColor = [[NSColor whiteColor] colorWithAlphaComponent:.6];
    
    NSInteger i;
    for (i=0;i<6;i++)
    {
        [blackColor set];
        [linePath stroke];
        
        [linePath transformUsingAffineTransform:transform];
       
        [whiteColor set];
        [linePath stroke];
        
        [linePath transformUsingAffineTransform:transform];
        [linePath transformUsingAffineTransform:transform];
    }
    
    return [imageMaker unlockFocus];
}

+ (NSImage*)horizontalSplitViewImage;
{
    NSRect bounds = NSMakeRect(0, 0, 10, 7);
        
    // create the image
    NTImageMaker* imageMaker = [NTImageMaker maker:bounds.size];
    [imageMaker lockFocus];
    
    NSColor *blackColor = [[NSColor blackColor] colorWithAlphaComponent:.7];
    NSColor* whiteColor = [[NSColor whiteColor] colorWithAlphaComponent:.6];
	
	[whiteColor set];
	[NSBezierPath fillRect:NSInsetRect(bounds, 0, 2)];
	
	[blackColor set];
	[NSBezierPath fillRect:NSInsetRect(bounds, 0, 3)];
	    
    return [imageMaker unlockFocus];
}

+ (NSImage*)verticalSplitViewImage;
{
    NSRect bounds = NSMakeRect(0, 0, 7, 10);
            
    // create the image
    NTImageMaker* imageMaker = [NTImageMaker maker:bounds.size];
    [imageMaker lockFocus];
    
    NSColor *blackColor = [[NSColor blackColor] colorWithAlphaComponent:.7];
    NSColor* whiteColor = [[NSColor whiteColor] colorWithAlphaComponent:.6];
    	
	[whiteColor set];
	[NSBezierPath fillRect:NSInsetRect(bounds, 2, 0)];

	[blackColor set];
	[NSBezierPath fillRect:NSInsetRect(bounds, 3, 0)];

    return [imageMaker unlockFocus];
}

+ (NSImage*)smallRoundSplitViewImage;
{
	return [self makeRoundSplitViewImage:5];
}

+ (NSImage*)roundSplitViewImage;
{
	return [self makeRoundSplitViewImage:7];
}

+ (NSImage*)makeRoundSplitViewImage:(NSInteger)width;
{
    NSRect bounds = NSMakeRect(0, 0, width, width);
    NSRect ovalBounds = NSInsetRect(bounds, 1, 1);
    NSBezierPath *ovalPath = [NSBezierPath ovalPath:ovalBounds];
    
    NSColor *blackColor = [[NSColor blackColor] colorWithAlphaComponent:.8];
    NSColor* whiteColor = [[NSColor whiteColor] colorWithAlphaComponent:.9];
    
    NSAffineTransform* transform = [NSAffineTransform transform];
    [transform translateXBy:0 yBy:(width<7) ? -1: -2];
    
    // create the image
    NTImageMaker* imageMaker = [NTImageMaker maker:bounds.size];
	
    [imageMaker lockFocus];
    
    [ovalPath setClip];
    
    [blackColor set];
    [ovalPath fill];

    [ovalPath transformUsingAffineTransform:transform];
    
    [whiteColor set];
    [ovalPath fill];
    
	return [imageMaker unlockFocus];
}

+ (NSImage*)popupArrowImage:(NSColor*)color;
{
	return [self popupArrowImage:color small:NO];
}

+ (NSImage*)popupArrowImage:(NSColor*)color small:(BOOL)small;
{
	return [self popupArrowImage:color small:small direction:kTrianglePointingDownDirection];
}

+ (NSImage*)popupArrowImage:(NSColor*)color 
					  small:(BOOL)small 
				  direction:(NTTrianglePathDirection)direction;
{
	NSBezierPath *linePath;
	NSInteger height=0, width=0;
	
	switch (direction)
	{
		case kTrianglePointingUpDirection:
		case kTrianglePointingDownDirection:
		{
			if (small)
			{
				height = 4;
				width = 6;
			}
			else
			{
				height = 5;
				width = 7;
			}
		}
			break;
		case kTrianglePointingLeftDirection:
		case kTrianglePointingRightDirection:
		{
			if (small)
			{
				height = 6;
				width = 4;
			}
			else
			{
				height = 7;
				width = 5;
			}
		}
			break;
	}
	
	NSRect arrowRect=NSMakeRect(0,0, width, height);
	
	NSSize arrowSize = arrowRect.size;
		
    NTImageMaker *result = [NTImageMaker maker:arrowSize];
    
    [result lockFocus];
	
    linePath = [NSBezierPath trianglePath:arrowRect direction:direction flipped:NO];
	
    [color set];
    [linePath fill];
    
	return [result unlockFocus:YES];
}

+ (NSImage*)sharedRightPopupArrowImage;
{
    static NSImage* shared = nil;
    
    if (!shared)
		shared = [[self popupArrowImage:[[NTColorSet standardSet] colorForKey:kNTCS_blackImage] small:NO direction:kTrianglePointingRightDirection] retain];    
    
    return shared;
}

+ (NSImage*)sharedSmallRightPopupArrowImage;
{
    static NSImage* shared = nil;
    
    if (!shared)
		shared = [[self popupArrowImage:[[NTColorSet standardSet] colorForKey:kNTCS_blackImage] small:YES direction:kTrianglePointingRightDirection] retain];    
    
    return shared;
}

+ (NSImage*)sharedPopupArrowImage;
{
    static NSImage* shared = nil;
    
    if (!shared)
		shared = [[self popupArrowImage:[[NTColorSet standardSet] colorForKey:kNTCS_blackImage]] retain];    
    
    return shared;
}

+ (NSImage*)sharedLightPopupArrowImage;
{
    static NSImage* shared = nil;
    
    if (!shared)
		shared = [[self popupArrowImage:[NSColor colorWithCalibratedWhite:0 alpha:.6]] retain];    
    
    return shared;
}

+ (NSImage*)sharedSmallPopupArrowImage;
{
    static NSImage* shared = nil;
    
    if (!shared)
		shared = [[self popupArrowImage:[[NTColorSet standardSet] colorForKey:kNTCS_blackImage] small:YES] retain];    
    
    return shared;
}

+ (NSImage*)home:(NSColor*)color;
{
	static NSImage* sHomeImage = nil;
	
	if (!sHomeImage)
	{
		const NSInteger triangleHeight = 6;
		const NSInteger smokeStackWidth = 1;
		
		// NTFileDesc* desc = [[NTDefaultDirectory sharedInstance] home];
		// sHomeImage = [NSImage iconRef:[[desc icon] iconRef] toImage:14];
		
		NSBezierPath *path;
		NSRect imageRect = NSZeroRect;
		imageRect.size = NSMakeSize(13, 11);
		NSRect boxRect;
		
		NTImageMaker *imageMaker = [NTImageMaker maker:imageRect.size];
		[imageMaker lockFocus];
		{		
			[[NSColor blackColor] set];
			
			// roof
			path = [NSBezierPath bezPath];
			[path moveToPoint:NSMakePoint(NSMinX(imageRect), NSMaxY(imageRect)-triangleHeight)];
			[path lineToPoint:NSMakePoint(NSMidX(imageRect), NSMaxY(imageRect))];
			[path lineToPoint:NSMakePoint(NSMaxX(imageRect), NSMaxY(imageRect)-triangleHeight)];
			[path closePath];
			[path fill];
			
			// house box
			boxRect = NSInsetRect(imageRect, 2, 0);
			boxRect.size.height = NSHeight(imageRect)-triangleHeight;
			path = [NSBezierPath rectPath:boxRect];
			[path fill];
			
			// smokestack
			boxRect = NSInsetRect(imageRect, 2, 0);
			boxRect.size.height = NSHeight(imageRect)-2;
			boxRect.origin.x = NSMaxX(boxRect) - smokeStackWidth;
			boxRect.size.width = smokeStackWidth;
			NSRectFill(boxRect);
			
			sHomeImage = [[imageMaker unlockFocus] retain];
		}
	}
	
	// set as a template
	NSImage* result = [sHomeImage coloredImage:color];
	[result setTemplate:YES];
	
	return result;
}

+ (NSImage*)computer:(NSColor*)color;
{
	static NSImage* shared=nil;
	
	if (!shared)
	{
		unichar appleLogo = 63743;
		NSInteger offset = 0;
		
		NSFont* font = [NSFont fontWithName:@"AppleGothic" size:13];
		
		if (!font)
		{
			offset = -1;
			font = [NSFont systemFontOfSize:13];
		}
		
		NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, nil];
		NSAttributedString *attrString = [NSAttributedString stringWithString:[NSString stringWithCharacters:&appleLogo length:1] attributes:attributes];
		
		NSSize theSize = [attrString size];
		theSize.width = ceil(theSize.width);
		theSize.height = ceil(theSize.height);
		
		NTImageMaker* imageMaker = [NTImageMaker maker:theSize];
		
		[imageMaker lockFocus];
		[attrString drawAtPoint:NSMakePoint(0, offset)];
		shared = [[imageMaker unlockFocus:YES] retain];
	}
	
	return [shared coloredImage:color];
}

+ (NSImage*)chevron;
{
    static NSImage* shared=nil;
    
    if (!shared)
        shared = [[[NSBundle bundleForClass:self] imageWithName:@"NTChevron.tiff" inDirectory:@"images"] retain];
    
    return shared;
}

+ (NSImage*)favoritesTemplate;
{
    static NSImage* shared=nil;
    
    if (!shared)
	{
        shared = [[[NSBundle bundleForClass:self] imageWithName:@"favorites.png" inDirectory:@"images"] retain];
		[shared setTemplate:YES];
    }
	
    return shared;
}

+ (NSImage*)ascendingSortIndicator;
{
	return [NSImage imageNamed:@"NSAscendingSortIndicator"];
}

+ (NSImage*)descendingSortIndicator;
{
	return [NSImage imageNamed:@"NSDescendingSortIndicator"];
}

+ (NSImage*)actionGear;
{
    static NSImage* shared=nil;
    
    if (!shared)
	{
		shared = [[NSImage imageNamed:NSImageNameActionTemplate] retain];
		[shared setSize:NSMakeSize(13, 13)];
	}
	    
    return shared;
}

+ (NSImage*)dropTarget;
{
	NSImage* result = nil;
	NSRect rect = NSMakeRect(0, 0, 24, 24);
	NSImage* srcImage = nil;
	NSImage* destImage = nil;
	NSBezierPath* path;
		
	NTImageMaker* imageMaker = [NTImageMaker maker:rect.size];
	[imageMaker lockFocus];
	[[NSColor blackColor] set];
	path = [NSBezierPath bezierPathWithOvalInRect:NSInsetRect(rect, 2, 2)];
	[path fill];
	srcImage = [imageMaker unlockFocus];
	
	imageMaker = [NTImageMaker maker:rect.size];
	[imageMaker lockFocus];
	[[NSColor blackColor] set];
	path = [NSBezierPath bezierPathWithOvalInRect:NSInsetRect(rect, 6, 6)];
	[path fill];
	destImage = [imageMaker unlockFocus];
	
	imageMaker = [NTImageMaker maker:rect.size];
	[imageMaker lockFocus];
	
	[destImage drawInRect:rect fromRect:rect operation:NSCompositeCopy fraction:1.0];
	[srcImage drawInRect:rect fromRect:rect operation:NSCompositeSourceOut fraction:1.0];
	
	[[NSColor blackColor] set];
	path = [NSBezierPath bezierPathWithOvalInRect:NSInsetRect(rect, 8.5, 8.5)];
	[path fill];
	
	result = [imageMaker unlockFocus:YES];
		
	return result;
}

@end
