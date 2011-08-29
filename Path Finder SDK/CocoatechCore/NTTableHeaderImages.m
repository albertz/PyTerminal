//
//  NTTableHeaderImages.m
//  CocoatechCore
//
//  Created by Steve Gehrman on 9/2/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "NTTableHeaderImages.h"
#import "NSGraphicsContext-NTExtensions.h"

@interface NTTableHeaderImages (Private)
- (void)drawButton:(CGContextRef)cgContext
			  kind:(ThemeButtonKind)inKind
			  rect:(NSRect)inBoxRect
		   enabled:(BOOL)enabled
			active:(BOOL)active
		   pressed:(BOOL)pressed
	   highlighted:(BOOL)highlighted
		 adornment:(ThemeButtonAdornment)inAdornment;
@end

@implementation NTTableHeaderImages

NTSINGLETON_INITIALIZE;
NTSINGLETONOBJECT_STORAGE;

//---------------------------------------------------------- 
// dealloc
//---------------------------------------------------------- 
- (void)dealloc
{
    [super dealloc];
}

- (CGFloat)height;
{
	return 17.0;
}

- (void)drawInFrame:(NSRect)frame 
		highlighted:(BOOL)highlighted
		   selected:(BOOL)selected
			flipped:(BOOL)flipped;
{					
	SGS;
	{
		[NSBezierPath clipRect:frame];

		// avoid lines at ends
		frame.origin.x -= 5;
		frame.size.width += 10;
		
		[self drawButton:[[NSGraphicsContext currentContext] graphicsPort]
					kind:kThemeListHeaderButton
					rect:frame
				 enabled:YES
				  active:YES
				 pressed:selected
			 highlighted:highlighted
			   adornment:(kThemeAdornmentNone | kThemeAdornmentHeaderButtonNoSortArrow)];
	}
	RGS;
}

@end

@implementation NTTableHeaderImages (Private)

- (void)drawButton:(CGContextRef)cgContext
			  kind:(ThemeButtonKind)inKind
			  rect:(NSRect)inBoxRect
		  enabled:(BOOL)enabled
			active:(BOOL)active
		   pressed:(BOOL)pressed
		   highlighted:(BOOL)highlighted
		 adornment:(ThemeButtonAdornment)inAdornment;
{
	HIThemeButtonDrawInfo bdi;
	
	bdi.version = 0;
	bdi.kind = inKind;
	bdi.value = (highlighted) ? kThemeButtonOn : kThemeButtonOff;
	bdi.adornment = inAdornment;
	
	if (!enabled)
	{
		if (active)
			bdi.state = kThemeStateUnavailable;
		else
			bdi.state = kThemeStateUnavailableInactive;
	}
	else 
	{
		if (pressed)
			bdi.state = kThemeStatePressed;
		else if (active)
			bdi.state = kThemeStateActive;
		else
			bdi.state = kThemeStateInactive;
	}	
		
	HIThemeDrawButton((CGRect*)&inBoxRect, &bdi, cgContext, kHIThemeOrientationInverted, NULL);
}

@end
