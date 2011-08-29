//
//  NTGradient.m
//  CocoatechCore
//
//  Created by Steve Gehrman on 8/26/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "NTGradient.h"
#import "NSGraphicsContext-NTExtensions.h"
#import "NTImageMaker.h"

static void buttonGradientFunction(void *info, const CGFloat *in, CGFloat *out);
static void smoothGradientFunction(void *info, const CGFloat *in, CGFloat *out);
static void tubeGradientFunction(void *info, const CGFloat *in, CGFloat *out);
static void labelGradientFunction(void *info, const CGFloat *in, CGFloat *out);

typedef enum NTGradientFunctionID
{
	NTGradient_buttonFunctionID,
	NTGradient_smoothFunctionID,
	NTGradient_tubeFunctionID,
	NTGradient_labelFunctionID
} NTGradientFunctionID;

@interface NTGradient (Private)
- (CGFunctionRef)newFunction:(NTGradientFunctionID)functionID;
- (void)drawGradientInRect:(NSRect)bounds;
- (void)setColor:(NSColor*)color;
@end

@implementation NTGradient

- (id)init:(BOOL)flip buttonGradient:(NTGradientFunctionID)functionID;
{
    self = [super init];
    
    _flip = flip;
		    
	_startPoint = CGPointMake(0, 0);
    _endPoint = CGPointMake(0, 1);
	
    _colorSpace = CGColorSpaceCreateDeviceRGB();
    _numComponents = CGColorSpaceGetNumberOfComponents(_colorSpace);
    
    _function = [self newFunction:functionID];	
	
    return self;
}

+ (NTGradient*)buttonGradient:(BOOL)flip;
{
	NTGradient *result = [[NTGradient alloc] init:flip buttonGradient:NTGradient_buttonFunctionID];
	
	return [result autorelease];
}

+ (NTGradient*)labelGradient:(BOOL)flip;
{
	NTGradient *result = [[NTGradient alloc] init:flip buttonGradient:NTGradient_labelFunctionID];
	
	return [result autorelease];
}

+ (NTGradient*)smoothGradient:(BOOL)flip;
{
	NTGradient *result = [[NTGradient alloc] init:flip buttonGradient:NTGradient_smoothFunctionID];
	
	return [result autorelease];
}

+ (NTGradient*)tubeGradient:(BOOL)flip;
{
	NTGradient *result = [[NTGradient alloc] init:flip buttonGradient:NTGradient_tubeFunctionID];
	
	return [result autorelease];
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

// create an image using the gradient as a fill
- (NSImage*)imageWithSize:(NSSize)size color:(NSColor*)color;
{
	return [self imageWithSize:size color:color backColor:nil];
}

- (NSImage*)imageWithSize:(NSSize)size color:(NSColor*)color backColor:(NSColor*)backColor;
{	
	if ((size.height) > 0 && (size.width > 0))
	{
		NTImageMaker *image = [NTImageMaker maker:size];
		NSRect imageRect = NSZeroRect;
		imageRect.size = size;
		
		[image lockFocus];
		
		if (backColor)
		{
			[backColor set];
			[NSBezierPath fillRect:imageRect];
		}
		
		[self fillRect:imageRect withColor:color];
		
		return [image unlockFocus];
	}
	
	return nil;
}

@end

@implementation NTGradient (Private)

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
        
        // delete any existing shader
        if (_shading)
            CGShadingRelease(_shading);
        
        // create new shader
        _shading = CGShadingCreateAxial(_colorSpace, _startPoint, _endPoint, _function, false, false);
    }
}

- (CGFunctionRef)newFunction:(NTGradientFunctionID)functionID;
{
	CGFloat domain[2] = { 0, 1 };
    CGFloat range[10] = { 0, 1, 0, 1, 0, 1, 0, 1, 0, 1 };
	CGFunctionEvaluateCallback function;
	
	switch (functionID)
	{
		case NTGradient_buttonFunctionID:
			function = &buttonGradientFunction;
			break;
		case NTGradient_tubeFunctionID:
			function = &tubeGradientFunction;
			break;
		case NTGradient_labelFunctionID:
			function = &labelGradientFunction;
			break;
		case NTGradient_smoothFunctionID:
		default:
			function = &smoothGradientFunction;
			break;			
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

@end

static void smoothGradientFunction(void *info, const CGFloat *in, CGFloat *out)
{    
    NTGradient* gradientObj = (NTGradient*)info;
    int numComponents = gradientObj->_numComponents;
    const float *c = gradientObj->_colorArray;
    
	int i;
    for (i=0;i<numComponents;i++)
        *out++ = c[i];
	
    double inValue = *in;
    if (gradientObj->_flip)
        inValue = 1.0 - inValue;
	
    // set alpha
	double newA = gradientObj->_colorArray[3];
		
	newA = (newA * inValue);
	
	*out = newA;
}

static void tubeGradientFunction(void *info, const CGFloat *in, CGFloat *out)
{    
    NTGradient* gradientObj = (NTGradient*)info;
    int numComponents = gradientObj->_numComponents;
    const float *c = gradientObj->_colorArray;
    
	int i;
    for (i=0;i<numComponents;i++)
        *out++ = c[i];
	
    double inValue = *in;
    if (gradientObj->_flip)
        inValue = 1.0 - inValue;
	
    // set alpha
	double newA = gradientObj->_colorArray[3];
	
	if (inValue <= .3)
		inValue = .3 + (.7 - ((inValue/.3) * .7));
	
	newA = (newA * inValue);
	
	*out = newA;
}

static void buttonGradientFunction(void *info, const CGFloat *in, CGFloat *out)
{    
    NTGradient* gradientObj = (NTGradient*)info;
    int numComponents = gradientObj->_numComponents;
    const float *c = gradientObj->_colorArray;
    
	int i;
    for (i=0;i<numComponents;i++)
        *out++ = c[i];
	
    double inValue = *in;
    if (gradientObj->_flip)
        inValue = 1.0 - inValue;
	
    // set alpha
	double newA = gradientObj->_colorArray[3];
	
	if (inValue < .5)
		newA = (newA * (inValue * .9));
	else 
		newA = (newA * (inValue * 1.1));
	
	*out = newA;
}

static void labelGradientFunction(void *info, const CGFloat *in, CGFloat *out)
{    
    NTGradient* gradientObj = (NTGradient*)info;
    int numComponents = gradientObj->_numComponents;
    const float *c = gradientObj->_colorArray;
    
	int i;
    for (i=0;i<numComponents;i++)
        *out++ = c[i];
	
    double inValue = *in;
    if (gradientObj->_flip)
        inValue = 1.0 - inValue;
	
    // set alpha
	double newA = gradientObj->_colorArray[3];
	
	if (inValue < .4) // determines the point when the gradient goes white, the bottom (appr. 1/3)
		newA = (newA * (inValue * .0)); // .9 // lower value gives a more saturated (less white) bottom edge
	else if (inValue >.4 && inValue <.7) // determines the point when the gradient goes white, lower
		newA = (newA * (inValue * .4)); // .9 // lower value gives a more saturated (less white) middle part 
	else if (inValue >.7 && inValue <.85) // determines the point when the gradient goes white, now - appr. 1/3 upper edge is white
		newA = (newA * (inValue * .55)); // .9 // lower value gives a more saturated (less white) middle part 
	else 
		newA = (newA * (inValue * .7)); // 1.1 // higher value gives a more white-saturated upper edge
	
	*out = newA;
}

