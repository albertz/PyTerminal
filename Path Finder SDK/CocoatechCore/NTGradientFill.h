//
//  NTGradientFill.h
//  CocoatechCore
//
//  Created by Steve Gehrman on Tue Feb 10 2004.
//  Copyright (c) 2004 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum _NTGradientType
{
    kNTLightGradient,
    kNTMediumGradient,
    kNTHeavyGradient,
	
	kHeaderGradient,  // like an NSTableView header
} NTGradientType;

@interface NTGradientFill : NSObject 
{
    CGColorSpaceRef _colorSpace;
    CGShadingRef _shading;
    CGFunctionRef _function;    
    
    CGPoint _startPoint;
    CGPoint _endPoint;
    NSColor* _color;
    
	BOOL _alphaOnly;
	
    @public
    // values used in callback for speed we don't want to call a method, just access the data from the object pointer
    int _numComponents;
    CGFloat _colorArray[4];
    BOOL _flip;
	NTGradientType _type;
    CGFloat _amountChange;  // amount to lighten and darken
}

- (id)initWithType:(NTGradientType)type alphaOnly:(BOOL)alphaOnly flip:(BOOL)flip;
- (id)initWithType:(NTGradientType)type flip:(BOOL)flip;

- (void)fillRect:(NSRect)rect withColor:(NSColor*)color;
- (void)fillBezierPath:(NSBezierPath*)path withColor:(NSColor*)color;

@end
