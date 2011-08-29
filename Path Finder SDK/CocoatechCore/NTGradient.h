//
//  NTGradient.h
//  CocoatechCore
//
//  Created by Steve Gehrman on 8/26/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NTGradient : NSObject {
	@public
    CGColorSpaceRef _colorSpace;
    CGShadingRef _shading;
    CGFunctionRef _function;    
    
    CGPoint _startPoint;
    CGPoint _endPoint;
    NSColor* _color;
	
	int _numComponents;
    float _colorArray[4];
    BOOL _flip;
}

+ (NTGradient*)buttonGradient:(BOOL)flip;
+ (NTGradient*)smoothGradient:(BOOL)flip;
+ (NTGradient*)tubeGradient:(BOOL)flip;
+ (NTGradient*)labelGradient:(BOOL)flip;

- (void)fillRect:(NSRect)rect withColor:(NSColor*)color;
- (void)fillBezierPath:(NSBezierPath*)path withColor:(NSColor*)color;

// create an image using the gradient as a fill
- (NSImage*)imageWithSize:(NSSize)size color:(NSColor*)color;
- (NSImage*)imageWithSize:(NSSize)size color:(NSColor*)color backColor:(NSColor*)backColor;

@end
