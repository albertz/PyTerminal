//
//  NTGradientFill.m
//  CocoatechCore
//
//  Created by Steve Gehrman on Tue Feb 10 2004.
//  Copyright (c) 2004 __MyCompanyName__. All rights reserved.
//

#import "NTGradientFill.h"
#import "NSGraphicsContext-NTExtensions.h"

static void standardGradient(void *info, const CGFloat *in, CGFloat *out);
static void headerGradient(void *info, const CGFloat *in, CGFloat *out);
static void alphaHeaderGradient(void *info, const CGFloat *in, CGFloat *out);
static void alphaGradient(void *info, const CGFloat *in, CGFloat *out);

@interface NTGradientFill (Private)
- (CGFunctionRef)newFunction:(NTGradientType)type;
- (void)drawGradientInRect:(NSRect)bounds;
- (void)setColor:(NSColor*)color;
- (void)modifyColorBeforeShading;
@end

@implementation NTGradientFill

- (id)initWithType:(NTGradientType)type alphaOnly:(BOOL)alphaOnly flip:(BOOL)flip;
{
    self = [super init];
    
    _flip = flip;
	_type = type;
	_alphaOnly = alphaOnly;
	
    switch (type)
    {
        case kNTLightGradient:
            _amountChange = .10;
            break;
        case kNTMediumGradient:
            _amountChange = .15;
            break;
        case kNTHeavyGradient:
			_amountChange = .20;
			break;
		case kHeaderGradient:
            _amountChange = .30;
			break;
        default:
            _amountChange = .20;
            break;
    }
	    
	_startPoint = CGPointMake(0, 0);
    _endPoint = CGPointMake(0, 1);
	
    _colorSpace = CGColorSpaceCreateDeviceRGB();
    _numComponents = CGColorSpaceGetNumberOfComponents(_colorSpace);
    
    _function = [self newFunction:type];	
	
    return self;
}

- (id)initWithType:(NTGradientType)type flip:(BOOL)flip;
{
	return [self initWithType:type alphaOnly:NO flip:flip];
}

- (id)init;
{
    return [self initWithType:kNTLightGradient flip:NO];
}

- (void)dealloc;
{
    if (_function)
        CGFunctionRelease(_function);
    
    if (_shading)
        CGShadingRelease(_shading);
    
    if (_colorSpace)
        CGColorSpaceRelease(_colorSpace);
    
    [_color release];
    
    [super dealloc];
}

- (void)fillRect:(NSRect)rect withColor:(NSColor*)color;
{
	SGS;
    [self setColor:color];
    
    [self drawGradientInRect:rect];
    RGS;
}

- (void)fillBezierPath:(NSBezierPath*)path withColor:(NSColor*)color;
{
    NSRect bounds = [path bounds];
    
    SGS;
    [path addClip];
    
    [self setColor:color];
    [self drawGradientInRect:bounds];
    
    RGS;
}

@end

@implementation NTGradientFill (Private)

- (void)setColor:(NSColor*)color
{
    BOOL setColor = NO;
    
    // for speed, we only change the color and shader if needed
    if (!_color)
        setColor = YES;
    else if (![color isEqualTo:_color])
        setColor = YES;
    
    if (setColor)
    {
        [_color release];
        _color = [color retain];

        // fill in the color array for the shading callback
        NSColor *rgbColor = [_color colorUsingColorSpaceName:NSDeviceRGBColorSpace];
        
        _colorArray[0] = [rgbColor redComponent];
        _colorArray[1] = [rgbColor greenComponent];
        _colorArray[2] = [rgbColor blueComponent];
        _colorArray[3] = [rgbColor alphaComponent];
        
		if (_type != kHeaderGradient && !_alphaOnly)
			[self modifyColorBeforeShading];

        // delete any existing shader
        if (_shading)
            CGShadingRelease(_shading);
        
        // create new shader
        _shading = CGShadingCreateAxial(_colorSpace, _startPoint, _endPoint, _function, false, false);
    }
}

- (CGFunctionRef)newFunction:(NTGradientType)type;
{
	CGFloat domain[2] = { 0, 1 };
    CGFloat range[10] = { 0, 1, 0, 1, 0, 1, 0, 1, 0, 1 };
	CGFunctionEvaluateCallback function;
	
	if (_alphaOnly)
	{
		if (type == kHeaderGradient)
			function = &alphaHeaderGradient;
		else
			function = &alphaGradient;
	}
	else
	{
		if (type == kHeaderGradient)
			function = &headerGradient;
		else
			function = &standardGradient;
	}
	
	CGFunctionCallbacks callbacks = { 0, function, NULL };
                
    // add one to _numComponents for the alpha
    return CGFunctionCreate((void*)self, 1, domain, _numComponents+1, range, &callbacks);
}

- (void)drawGradientInRect:(NSRect)bounds
{
    CGContextRef currentContext = (CGContextRef)[[NSGraphicsContext currentContext] graphicsPort];
        
    CGRect pageRect = CGRectMake( bounds.origin.x, bounds.origin.y, bounds.size.width, bounds.size.height );
    CGContextBeginPage(currentContext, &pageRect);
    {        
        CGContextSaveGState(currentContext);

        CGAffineTransform transform = CGAffineTransformIdentity;
        transform = CGAffineTransformTranslate(transform, bounds.origin.x, bounds.origin.y);
        transform = CGAffineTransformScale(transform, bounds.size.width, bounds.size.height);

        CGContextConcatCTM(currentContext, transform);
        CGContextClipToRect(currentContext, CGRectMake(0, 0, 1, 1));
        CGContextDrawShading(currentContext, _shading);
        
        CGContextRestoreGState(currentContext);
    }
    CGContextEndPage(currentContext);
}

- (void)modifyColorBeforeShading;
{
    CGFloat maxComponent=0.0;
    int i;
    CGFloat shift;
    
    for (i=0;i<_numComponents;i++)
    {
        if (_colorArray[i] > maxComponent)
            maxComponent = _colorArray[i];
    }
    
    // now verify that the color can be both lightened and darkened
    if (maxComponent > .5)
    {
        shift = (maxComponent + _amountChange);
        if (shift > 1.0)
        {
            shift = (shift - 1.0);
            _colorArray[0] -= shift;
            _colorArray[1] -= shift;
            _colorArray[2] -= shift;
        }
    }
    else
    {
        shift = (maxComponent - _amountChange);
        if (shift < 0.0)
        {
            _colorArray[0] -= shift;
            _colorArray[1] -= shift;
            _colorArray[2] -= shift;
        }
    }
}

@end

static void standardGradient(void *info, const CGFloat *in, CGFloat *out)
{    
    NTGradientFill* gradientObj = (NTGradientFill*)info;
    int numComponents = gradientObj->_numComponents;
    const CGFloat *c = gradientObj->_colorArray;
    CGFloat amountChange = gradientObj->_amountChange;
    
    CGFloat inValue = *in;
    if (gradientObj->_flip)
        inValue = 1.0 - inValue;
	
    int i;
    for (i=0;i<numComponents;i++)
    {
        CGFloat newV, multiplier;
        
        newV = c[i];
		
        if (inValue < .5)
        {
            multiplier = 1.0 - (inValue*2);
			
            newV += (multiplier * amountChange);
        }
        else if (inValue > .5)
        {
            multiplier = ((inValue - .5) * 2);
            
            newV -= (multiplier * amountChange);
        }
        
        *out++ = newV;
    }
    
    // set alpha
    *out = gradientObj->_colorArray[3];
}

static void headerGradient(void *info, const CGFloat *in, CGFloat *out)
{    
    NTGradientFill* gradientObj = (NTGradientFill*)info;
    int numComponents = gradientObj->_numComponents;
    const CGFloat *c = gradientObj->_colorArray;
    CGFloat multiplier, amountChange = gradientObj->_amountChange;
    
    CGFloat inValue = *in;
    if (gradientObj->_flip)
        inValue = 1.0 - inValue;
	
    int i;
    for (i=0;i<numComponents;i++)
    {
        CGFloat newV = c[i];
		
		if (inValue < .5)
			newV -= (inValue * .1);
		else
		{
			multiplier = 1.0 - inValue;
		
			newV -= (multiplier * amountChange);
        }
						
        *out++ = newV;
    }
    
    // set alpha
    *out = gradientObj->_colorArray[3];
}

static void alphaHeaderGradient(void *info, const CGFloat *in, CGFloat *out)
{    
    NTGradientFill* gradientObj = (NTGradientFill*)info;
    int numComponents = gradientObj->_numComponents;
    const CGFloat *c = gradientObj->_colorArray;
    CGFloat multiplier, amountChange = gradientObj->_amountChange;
    
    CGFloat inValue = *in;
    if (gradientObj->_flip)
        inValue = 1.0 - inValue;
	
    int i;
    for (i=0;i<numComponents;i++)
        *out++ = c[i];
    
    // set alpha
	CGFloat newA = gradientObj->_colorArray[3];
	if (inValue < .5)
		newA += (inValue * .1);
	else
	{
		multiplier = 1.0 - inValue;
		
		newA += (multiplier * amountChange);
	}
	
    *out = newA;
}

static void alphaGradient(void *info, const CGFloat *in, CGFloat *out)
{    
    NTGradientFill* gradientObj = (NTGradientFill*)info;
    int numComponents = gradientObj->_numComponents;
    const CGFloat *c = gradientObj->_colorArray;
    CGFloat multiplier, amountChange = gradientObj->_amountChange;
    
    CGFloat inValue = *in;
    if (gradientObj->_flip)
        inValue = 1.0 - inValue;
	
    int i;
    for (i=0;i<numComponents;i++)
        *out++ = c[i];
    
    // set alpha
	CGFloat newA = gradientObj->_colorArray[3];
	
	if (inValue < .5)
	{
		multiplier = 1.0 - (inValue*2);
		
		newA += (multiplier * amountChange);
	}
	else if (inValue > .5)
	{
		multiplier = ((inValue - .5) * 2);
		
		newA -= (multiplier * amountChange);
	}
	
	*out = newA;
}
