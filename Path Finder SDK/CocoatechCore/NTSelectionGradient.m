//
//  NTSelectionGradient.m
//  CocoatechCore
//
//  Created by Steve Gehrman on 10/29/08.
//  Copyright 2008 Cocoatech. All rights reserved.
//

#import "NTSelectionGradient.h"
#import "NTGlobalPreferences.h"
#import "NTGradientDraw.h"

@interface NTSelectionGradient (Private)
- (NTGradientDraw*)selectionGradientInRect:(BOOL)dimmed
							  outLineColor:(NSColor**)outLineColor;
@end

@implementation NTSelectionGradient

@synthesize aquaGradient;
@synthesize aquaLineColor;
@synthesize graphiteGradient;
@synthesize graphiteLineColor;
@synthesize dimmedGradient;
@synthesize dimmedLineColor;

+ (NTSelectionGradient*)gradient;
{
	NTSelectionGradient* result = [[NTSelectionGradient alloc] init];
	
	return [result autorelease];
}

//---------------------------------------------------------- 
// dealloc
//---------------------------------------------------------- 
- (void) dealloc
{
    self.aquaGradient = nil;
    self.aquaLineColor = nil;
    self.graphiteGradient = nil;
    self.graphiteLineColor = nil;
    self.dimmedGradient = nil;
    self.dimmedLineColor = nil;
    [super dealloc];
}

- (void)drawGradientInRect:(NSRect)frame 
					dimmed:(BOOL)dimmed 
				   flipped:(BOOL)flipped;
{
	NSColor* theLineColor=nil;
	NTGradientDraw* theGradient = [self selectionGradientInRect:(BOOL)dimmed
												 outLineColor:&theLineColor];
	
	[theGradient drawInRect:frame horizontal:YES flipped:flipped];	
	
	NSRect topLine = frame;
	if (!flipped)
		topLine.origin.y += NSHeight(topLine)-1;
	topLine.size.height = 1;		
	[theLineColor set];
	[NSBezierPath fillRect:topLine];
}

@end

@implementation NTSelectionGradient (Private)

- (NTGradientDraw*)selectionGradientInRect:(BOOL)dimmed
							  outLineColor:(NSColor**)outLineColor;
{
	NTGradientDraw* theGradient=nil;
	NSColor* theLineColor=nil;
	
	if (dimmed)
	{
		if (!self.dimmedGradient)
			self.dimmedGradient = [NTGradientDraw gradientWithStartColor:[NSColor colorWithCalibratedRed:.706 green:.706 blue:.706 alpha:1]
													   endColor:[NSColor colorWithCalibratedRed:.541 green:.541 blue:.541 alpha:1]];
		
		if (!self.dimmedLineColor)
			self.dimmedLineColor = [NSColor colorWithCalibratedRed:.592 green:.592 blue:.592 alpha:1];
		
		theGradient = self.dimmedGradient;
		theLineColor = self.dimmedLineColor;
	}
	else
	{
		if ([[NTGlobalPreferences sharedInstance] useGraphiteAppearance])
		{
			if (!self.graphiteGradient)
				self.graphiteGradient = [NTGradientDraw gradientWithStartColor:[NSColor colorWithCalibratedRed:.510 green:.576 blue:.651 alpha:1]
														   endColor:[NSColor colorWithCalibratedRed:.251 green:.341 blue:.439 alpha:1]];
			
			if (!self.graphiteLineColor)
				self.graphiteLineColor = [NSColor colorWithCalibratedRed:.408 green:.471 blue:.549 alpha:1];
			
			theGradient = self.graphiteGradient;
			theLineColor = self.graphiteLineColor;
		}
		else
		{
			if (!self.aquaGradient)
				self.aquaGradient = [NTGradientDraw gradientWithStartColor:[NSColor colorWithCalibratedRed:.361 green:.576 blue:.835 alpha:1]
														   endColor:[NSColor colorWithCalibratedRed:.082 green:.325 blue:.667 alpha:1]];
			
			if (!self.aquaLineColor)
				self.aquaLineColor = [NSColor colorWithCalibratedRed:.271 green:.502 blue:.784 alpha:1];
			
			theGradient = self.aquaGradient;
			theLineColor = self.aquaLineColor;			
		}
	}
	
	if (outLineColor)
		*outLineColor = theLineColor;
	
	return theGradient;
}

@end
