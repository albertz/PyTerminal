//
//  NTMetalWindowTheme.m
//  CocoatechCore
//
//  Created by Steve Gehrman on 11/7/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "NTMetalWindowTheme.h"
#import "NTGradientDraw.h"
#import "NTImageMaker.h"
#import "NSColor-NTExtensions.h"
#import "NSWindow-NTExtensions.h"
#import "NSString-Utilities.h"

@interface NTMetalWindowTheme ()
@property (nonatomic, assign) NSRect lastWindowRect;
@property (nonatomic, assign) NSRect lastDimmedWindowRect;
@property (nonatomic, retain) NTGradientDraw *gradient;
@property (nonatomic, retain) NTGradientDraw *dimmedGradient;
@property (nonatomic, retain) NSColor *backgroundColor;
@property (nonatomic, retain) NSColor *dimmedBackgroundColor;
@property (nonatomic, retain) NSImage *normalImage;
@property (nonatomic, retain) NSImage *dimmedImage;
@end

@interface NTMetalWindowTheme (Private)
- (NSImage *)makeBackgroundImage:(NSWindow*)theWindow;
- (void)rebuildColorPattern:(NSWindow*)theWindow;
@end

@implementation NTMetalWindowTheme

@synthesize lastWindowRect;
@synthesize lastDimmedWindowRect;
@synthesize gradient, dimmedGradient;
@synthesize backgroundColor, dimmedBackgroundColor;
@synthesize normalImage;
@synthesize dimmedImage;

+ (NTMetalWindowTheme*)theme:(NSWindow*)theWindow backColor:(NSColor*)theBackColor;
{	
	if (!theWindow)
		return nil;
	
	NTMetalWindowTheme* result = [[NTMetalWindowTheme alloc] init];
	
	if (!theBackColor)
		theBackColor = [NSColor colorWithCalibratedWhite:0.52 alpha:1];
	
	result.backgroundColor = theBackColor;
	result.gradient = [NTGradientDraw gradientWithStartColor:[result.backgroundColor lighterColor:.5] endColor:result.backgroundColor];

	result.dimmedBackgroundColor = [NSColor colorWithCalibratedWhite:.8 alpha:1.0];
	result.dimmedGradient = [NTGradientDraw gradientWithStartColor:[NSColor colorWithCalibratedWhite:.9 alpha:1.0] endColor:result.dimmedBackgroundColor];

	[result rebuildColorPattern:theWindow];

	[[NSNotificationCenter defaultCenter] addObserver:result 
											 selector:@selector(rebuildColorPatternNotification:) 
												 name:NSWindowDidResizeNotification 
											   object:theWindow];
	[[NSNotificationCenter defaultCenter] addObserver:result 
											 selector:@selector(rebuildColorPatternNotification:) 
												 name:NSWindowDidResignMainNotification 
											   object:theWindow];
	[[NSNotificationCenter defaultCenter] addObserver:result 
											 selector:@selector(rebuildColorPatternNotification:) 
												 name:NSWindowDidBecomeMainNotification 
											   object:theWindow];
	
	return [result autorelease];
}

//---------------------------------------------------------- 
// dealloc
//---------------------------------------------------------- 
- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
    self.gradient = nil;
    self.backgroundColor = nil;
    self.dimmedGradient = nil;
    self.dimmedBackgroundColor = nil;
    self.normalImage = nil;
    self.dimmedImage = nil;
	
    [super dealloc];
}

@end

@implementation NTMetalWindowTheme (Private)

- (void)rebuildColorPatternNotification:(NSNotification *)aNotification
{
	NSWindow* theWindow = [aNotification object];
	
	[self rebuildColorPattern:theWindow];
}

- (void)rebuildColorPattern:(NSWindow*)theWindow;
{
	if (theWindow)
	{
		NSRect windowRect = [theWindow frame];
		windowRect.origin = NSZeroPoint;
		
		// did frame change?
		NSRect lastRect = self.lastWindowRect;
		if ([theWindow dimControls])
			lastRect = self.lastDimmedWindowRect;
		
		// only change if height changes
		if (!NSEqualRects(windowRect, lastRect))
		{
			if ([theWindow dimControls])
			{
				self.lastDimmedWindowRect = windowRect;
				self.dimmedImage = [self makeBackgroundImage:theWindow];
			}
			else
			{
				self.lastWindowRect = windowRect;
				self.normalImage = [self makeBackgroundImage:theWindow];
			}
		}
		
		NSImage* theImage = self.normalImage;
		if ([theWindow dimControls])
			theImage = self.dimmedImage;
		
		if (theImage != [[theWindow backgroundColor] patternImage])
		{
			[theWindow setBackgroundColor:[NSColor colorWithPatternImage:theImage]];

			// invalidate views
			NSRect invalidateRect = [[theWindow contentView] bounds];
			[[theWindow contentView] setNeedsDisplayInRect:invalidateRect];
		}
	}
}

- (NSImage *)makeBackgroundImage:(NSWindow*)theWindow;
{
	if (!theWindow)
		return nil;
		
	NSRect windowFrame = [theWindow frame];		
	
	NSUInteger theHeight = NSHeight(windowFrame);
	NSRect drawRect = NSZeroRect;
	drawRect.size.height = theHeight;
	drawRect.size.width = 1;
	
	NTImageMaker* imageMaker = [NTImageMaker maker:drawRect.size];
	[imageMaker lockFocus];
	{
		NSColor *theBackColor = self.backgroundColor;
		NTGradientDraw *theGradient = self.gradient;
		if ([theWindow dimControls])
		{
			theGradient = self.dimmedGradient;
			theBackColor = self.dimmedBackgroundColor;
		}
		
		[theBackColor set];
		[NSBezierPath fillRect:drawRect];

		// top gradient
		if (theGradient)
		{
			NSRect contentRect = [theWindow contentRectForFrameRect:windowFrame];

			NSUInteger gradientHeight = (NSMaxY(windowFrame) - NSMaxY(contentRect));
			
			if (gradientHeight > 50)
				gradientHeight *= 1.8;
			else
				gradientHeight *= 3;
			
			NSRect gradientRect = drawRect;
			gradientRect.origin.y = NSMaxY(gradientRect) - gradientHeight;
			gradientRect.size.height = gradientHeight;
			[theGradient drawInRect:gradientRect 
							 horizontal:YES
								flipped:NO];
		}
	}
	NSImage* result = [imageMaker unlockFocus];
	
	 return result;
}

@end

// ==================================================================================
// ==================================================================================

@implementation NSWindow (NTMetalWindowTheme)

- (BOOL)isThemeInstalled;
{
	if ([self respondsToSelector:@selector(isThemeInstalled_Imp)])
		return [self isThemeInstalled_Imp];
	
	return NO;
}

@end
