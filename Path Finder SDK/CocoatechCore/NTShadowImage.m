//
//  NTShadowImage.m
//  CocoaTechAppKit
//
//  Created by Steve Gehrman on 11/15/09.
//  Copyright 2009 Cocoatech. All rights reserved.
//

#import "NTShadowImage.h"
#import "NTImageMaker.h"
#import "NTStandardColors.h"

@interface NTShadowImage ()
@property (nonatomic, retain) NSImage *topShadowImage;
@property (nonatomic, retain) NSImage *leftShadowImage;
@property (nonatomic, retain) NSImage *rightShadowImage;

@property (nonatomic, assign) CGFloat shadowOffset;
@property (nonatomic, assign) CGFloat shadowBlur;
@property (nonatomic, assign) NSUInteger shadowSize;
@property (nonatomic, retain) NSColor *topShadowColor;
@property (nonatomic, retain) NSColor *shadowColor;
@end

@implementation NTShadowImage

@synthesize topShadowImage;
@synthesize leftShadowImage;
@synthesize rightShadowImage;
@synthesize shadowOffset;
@synthesize shadowBlur;
@synthesize shadowSize;
@synthesize topShadowColor;
@synthesize shadowColor;

//---------------------------------------------------------- 
// dealloc
//---------------------------------------------------------- 
- (void) dealloc
{
    self.topShadowColor = nil;
    self.shadowColor = nil;
    self.topShadowImage = nil;
    self.leftShadowImage = nil;
    self.rightShadowImage = nil;
	
    [super dealloc];
}

+ (NTShadowImage*)shadowImage;
{
	NTShadowImage* result = [[NTShadowImage alloc] init];
	
	result.shadowOffset = 1.0;
	result.shadowBlur = 3;
	result.shadowSize = 8;
	result.topShadowColor = [[NTStandardColors frameColor:NO] colorWithAlphaComponent:1];
	result.shadowColor = [[NTStandardColors frameColor:NO] colorWithAlphaComponent:.75];
	
	return [result autorelease];
}

+ (NTShadowImage*)largeShadowImage;
{
	NTShadowImage* result = [[NTShadowImage alloc] init];
	
	result.shadowOffset = 12.0;
	result.shadowBlur = 6;
	result.shadowSize = 40;
	result.topShadowColor = [NSColor blackColor];
	result.shadowColor = [NSColor blackColor];
	
	return [result autorelease];
}

- (void)drawTopShadowInRect:(NSRect)inRect;
{
	NSRect theDrawRect;

	if (!self.topShadowImage)
	{
		NSShadow *shadow = [[[NSShadow alloc] init] autorelease];
		[shadow setShadowBlurRadius:self.shadowBlur];
		[shadow setShadowColor:self.topShadowColor];
		[shadow setShadowOffset:NSMakeSize(0, -self.shadowOffset)];
		
		NSRect imageRect = NSMakeRect(0, 0, 1, self.shadowSize);
		NTImageMaker* imageMaker = [NTImageMaker maker:imageRect.size];
		
		[imageMaker lockFocus];
		{
			theDrawRect = imageRect;
			
			theDrawRect.origin.y = NSMaxY(theDrawRect);
			
			[shadow set];
			[[NSColor blackColor] set];
			NSRectFill(theDrawRect);
		}
		self.topShadowImage = [imageMaker unlockFocus];
	}
	
	theDrawRect = inRect;
	theDrawRect.size.height = [self.topShadowImage size].height;
	theDrawRect.origin.y = NSMaxY(inRect) - NSHeight(theDrawRect);
	
	[self.topShadowImage drawInRect:theDrawRect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1];
}

- (void)drawLeftShadowInRect:(NSRect)inRect;
{
	NSRect theDrawRect;
	
	if (!self.leftShadowImage)
	{
		NSShadow *shadow = [[[NSShadow alloc] init] autorelease];
		[shadow setShadowBlurRadius:self.shadowBlur];
		[shadow setShadowColor:self.shadowColor];
		[shadow setShadowOffset:NSMakeSize(self.shadowOffset, 0)];
		
		NSRect imageRect = NSMakeRect(0, 0, self.shadowSize, 1);
		NTImageMaker* imageMaker = [NTImageMaker maker:imageRect.size];
		
		[imageMaker lockFocus];
		{
			theDrawRect = imageRect;
			
			theDrawRect.origin.x -= NSWidth(theDrawRect);
			
			[shadow set];
			[[NSColor blackColor] set];
			NSRectFill(theDrawRect);
		}
		self.leftShadowImage = [imageMaker unlockFocus];
	}
	
	theDrawRect = inRect;
	theDrawRect.size.width = [self.leftShadowImage size].width;
	
	[self.leftShadowImage drawInRect:theDrawRect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1];	
}

- (void)drawRightShadowInRect:(NSRect)inRect;
{
	NSRect theDrawRect;
	
	if (!self.rightShadowImage)
	{
		NSShadow *shadow = [[[NSShadow alloc] init] autorelease];
		[shadow setShadowBlurRadius:self.shadowBlur];
		[shadow setShadowColor:self.shadowColor];
		[shadow setShadowOffset:NSMakeSize(-self.shadowOffset, 0)];
		
		NSRect imageRect = NSMakeRect(0, 0, self.shadowSize, 1);
		NTImageMaker* imageMaker = [NTImageMaker maker:imageRect.size];
		
		[imageMaker lockFocus];
		{
			theDrawRect = imageRect;
			
			theDrawRect.origin.x = NSMaxX(theDrawRect);
			
			[shadow set];
			[[NSColor blackColor] set];
			NSRectFill(theDrawRect);
		}
		self.rightShadowImage = [imageMaker unlockFocus];
	}
	
	theDrawRect = inRect;
	theDrawRect.size.width = [self.rightShadowImage size].width;
	theDrawRect.origin.x = NSMaxX(inRect) - theDrawRect.size.width;
	
	[self.rightShadowImage drawInRect:theDrawRect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1];	
}

@end
