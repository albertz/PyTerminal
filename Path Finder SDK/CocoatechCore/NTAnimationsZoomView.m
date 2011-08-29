//
//  NTAnimationsZoomView.m
//  CocoatechCore
//
//  Created by Steve Gehrman on 1/2/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "NTAnimationsZoomView.h"
#import "NTGeometry.h"
#import "NSImage-NTExtensions.h"
#import "NSBezierPath-NTExtensions.h"
#import "CALayer-NTExtensions.h"

@interface NTAnimationsZoomView (Private)
- (void)setImageToLayer;
- (void)reset;
- (void)setupLayer;
@end

@implementation NTAnimationsZoomView

@synthesize image;
@synthesize imageLayer;
@synthesize transformAnimation;
@synthesize opacityAnimation;

+ (NTAnimationsZoomView*)view:(NSRect)frame;
{
	NTAnimationsZoomView* result = [[NTAnimationsZoomView alloc] initWithFrame:frame];

	result.transformAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
	[result.transformAnimation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
	[result.transformAnimation setDuration:.3];
	result.transformAnimation.delegate = result;

	result.opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
	[result.opacityAnimation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
	[result.opacityAnimation setDuration:.3];	
	
	[result setAutoresizingMask:NSViewHeightSizable|NSViewWidthSizable];
	result.wantsLayer = YES;

	[result setupLayer];
	
	return [result autorelease];
}

//---------------------------------------------------------- 
// dealloc
//---------------------------------------------------------- 
- (void) dealloc
{
    self.image = nil;
	
	self.imageLayer.delegate = nil;
    self.imageLayer = nil;
	
	self.transformAnimation.delegate = nil;
    self.transformAnimation = nil;
	
    self.opacityAnimation = nil;
    [super dealloc];
}

- (void)animate;
{	
	[self setImageToLayer];

	[self.imageLayer scale:1];
	self.imageLayer.opacity = 0.0;
}

@end

@implementation NTAnimationsZoomView (CALayerDelegate)

- (id<CAAction>)actionForLayer:(CALayer *)layer forKey:(NSString *)event;
{	
    if (layer == self.imageLayer)
	{		
		if ([event isEqualToString:@"transform"]) 
			return self.transformAnimation;
		else if ([event isEqualToString:@"opacity"]) 
			return self.opacityAnimation;
	}
	
	return nil;
}

@end

@implementation NTAnimationsZoomView (CAAnimationDelegate)

- (void)animationDidStart:(CAAnimation *)anim;
{
	if (![[self window] isVisible])
		[[self window] orderFront:nil];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag;
{
	if ([[self window] isVisible])
	{
		[[self window] orderOut:nil];
		[self reset];
	}
}

@end

@implementation NTAnimationsZoomView (Private)

- (void)setImageToLayer;
{	
	[CATransaction begin];
	[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
	
	self.imageLayer.contents = self.image;
		
	[CATransaction commit];
}	

- (void)setupLayer;
{
	if (!self.imageLayer)
	{
		CALayer *theLayer = [CALayer layer];
		
		theLayer.frame = NSRectToCGRect([self bounds]);
		theLayer.opaque = YES;
		[self.layer addSublayer:theLayer];
		
		self.imageLayer = theLayer;
		self.imageLayer.delegate = self;

		[self reset];
	}
}	

- (void)reset;
{	
	[CATransaction begin];
	[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
	
	[self setImage:nil];
	[self setImageToLayer];

	[self.imageLayer scale:.1];
	self.imageLayer.opacity = .92;
	
	[CATransaction commit];
}	

@end


