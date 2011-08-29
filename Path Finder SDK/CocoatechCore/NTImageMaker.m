//
//  NTImageMaker.m
//  CocoatechCore
//
//  Created by Steve Gehrman on 11/15/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "NTImageMaker.h"

@implementation NTImageMaker

@synthesize size;
@synthesize savedImageInterpolation;
@synthesize bitmapImageRep;
@synthesize bitmapContext;
@synthesize locked;

//---------------------------------------------------------- 
// dealloc
//---------------------------------------------------------- 
- (void) dealloc
{
    self.bitmapImageRep = nil;
    self.bitmapContext = nil;
    [super dealloc];
}

+ (NTImageMaker*)maker:(NSSize)size;
{
	NTImageMaker* result = [[NTImageMaker alloc] init];
	
	[result setSize:size];
	
	return [result autorelease];
}

- (void)lockFocus;
{
	if (self.locked)
		NSLog(@"imageMaker is already locked");
	else
	{
		self.locked = YES;
		
		[self setBitmapImageRep:[[[NSBitmapImageRep alloc] initWithBitmapDataPlanes:NULL 
																		 pixelsWide:[self size].width
																		 pixelsHigh:[self size].height 
																	  bitsPerSample:8 
																	samplesPerPixel:4
																		   hasAlpha:YES 
																		   isPlanar:NO
																	 colorSpaceName:NSCalibratedRGBColorSpace 
																	   bitmapFormat:0
																		bytesPerRow:0
																	   bitsPerPixel:0] autorelease]];
		
		// Clear the NSBitmapImageRep.
		unsigned char *bitmapData = [[self bitmapImageRep] bitmapData];
		if (bitmapData != NULL)
			bzero(bitmapData, [[self bitmapImageRep] bytesPerRow] * [[self bitmapImageRep] pixelsHigh]);
		
		// Create an NSGraphicsContext that we can use to draw into the NSBitmapImageRep, and make it current.  Make sure we have a graphics context before proceeding.  (Creation of the bitmap context should succeed as long as the bitmap is of a supported format though.)
		[self setBitmapContext:[NSGraphicsContext graphicsContextWithBitmapImageRep:[self bitmapImageRep]]];
		if ([self bitmapContext]) 
		{
			[NSGraphicsContext saveGraphicsState];
			[NSGraphicsContext setCurrentContext:[self bitmapContext]];
			
			// Set the context's interpolation parameter to the desired value.  Since the imageInterpolation isn't part of the graphics state, and therefore won't be automatically restored to its previous setting when we invoke [NSGraphicsContext restoreGraphicsState] below, we save the previous value and explicitly restore it below after we're done.
			[self setSavedImageInterpolation:[[self bitmapContext] imageInterpolation]];
			[[self bitmapContext] setImageInterpolation:NSImageInterpolationHigh];
		}
	}
}

- (NSImage*)unlockFocus;
{
	return [self unlockFocus:NO];
}

- (NSImage*)unlockFocus:(BOOL)template;
{
	NSImage* result=nil;
	
	if (!self.locked)
		NSLog(@"imageMaker is not locked");
	else
	{
		self.locked = NO;
		
		// Restore the previous graphics context and image interpolation setting.
		[[self bitmapContext] setImageInterpolation:[self savedImageInterpolation]];
		[NSGraphicsContext restoreGraphicsState];	
		
		// create NSImage and return it
		result = [[[NSImage alloc] initWithSize:[self size]] autorelease];
		[result addRepresentation:[self bitmapImageRep]];
		
		[result setTemplate:template];
	}
	
	return result;
}

- (NSBitmapImageRep*)imageRep;  // same one added to image in unlockFocus
{
	// a rep can't exist in more than one image, so copy it
	return [[[self bitmapImageRep] copy] autorelease];
}

@end
