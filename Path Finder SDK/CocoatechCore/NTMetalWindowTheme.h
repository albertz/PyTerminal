//
//  NTMetalWindowTheme.h
//  CocoatechCore
//
//  Created by Steve Gehrman on 11/7/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class NTGradientDraw;

@interface NTMetalWindowTheme : NSObject 
{
	NSRect lastWindowRect;
	NSRect lastDimmedWindowRect;
	
	NTGradientDraw* gradient;
	NSColor* backgroundColor;

	NTGradientDraw* dimmedGradient;
	NSColor* dimmedBackgroundColor;
	
	NSImage *normalImage;
	NSImage *dimmedImage;
}

+ (NTMetalWindowTheme*)theme:(NSWindow*)theWindow backColor:(NSColor*)theBackColor;

@end

// category added to check if window is drawn with theme
@interface NSWindow (NTMetalWindowTheme)
- (BOOL)isThemeInstalled;
@end

@interface NSWindow (NTMetalWindowTheme_Imp)
// override this if supporting themes
- (BOOL)isThemeInstalled_Imp;
@end
