//
//  ITIconStore.m
//  iTerm
//
//  Created by Steve Gehrman on 2/2/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "ITIconStore.h"

@interface ITIconStore (Private)
- (NSString*)iconFromSystemIconsBundleWithName:(NSString*)iconName;

- (NSBundle *)coreTypesBundle;
- (void)setCoreTypesBundle:(NSBundle *)theCoreTypesBundle;
@end

@implementation ITIconStore

+ (ITIconStore*)sharedInstance;
{
	static ITIconStore* shared = nil;
	
	if (!shared)
		shared = [[ITIconStore alloc] init];
	
	return shared;
}

- (NSImage*)image:(NSString*)identifier;
{
	NSString* path = [self iconFromSystemIconsBundleWithName:identifier];
	
	return [[[NSImage alloc] initWithContentsOfFile:path] autorelease];
}

- (void)dealloc;
{
	[self setCoreTypesBundle:nil];
	
    [super dealloc];
}

- (NSImage*)popupArrowImage:(NSColor*)color 
					  small:(BOOL)small;
{
    NSImage *result;
	NSBezierPath *linePath;
	int height=0, width=0;
	
	if (small)
	{
		height = 4;
		width = 6;
	}
	else
	{
		height = 5;
		width = 7;
	}
	
	NSRect arrowRect=NSMakeRect(0,0, width, height);
	
	NSSize arrowSize = arrowRect.size;
	
    result = [[[NSImage alloc] initWithSize:arrowSize] autorelease];
    [result setFlipped:NO];
    
    [result lockFocus];
	{
		linePath = [NSBezierPath bezierPath];
		[linePath moveToPoint:NSMakePoint(NSMinX(arrowRect), NSMinY(arrowRect))];
		[linePath lineToPoint:NSMakePoint(NSMidX(arrowRect), NSMaxY(arrowRect))];
		[linePath lineToPoint:NSMakePoint(NSMaxX(arrowRect), NSMinY(arrowRect))];			
		[linePath closePath];
		
		[color set];
		
		[linePath fill];
	}
	[result unlockFocus];
    
    return result;    
}

@end

@implementation ITIconStore (Private)

//---------------------------------------------------------- 
//  coreTypesBundle 
//---------------------------------------------------------- 
- (NSBundle *)coreTypesBundle
{
	if (!mCoreTypesBundle)
		[self setCoreTypesBundle:[NSBundle bundleWithPath:@"/System/Library/CoreServices/CoreTypes.bundle"]];
	
    return mCoreTypesBundle; 
}

- (void)setCoreTypesBundle:(NSBundle *)theCoreTypesBundle
{
    if (mCoreTypesBundle != theCoreTypesBundle) {
        [mCoreTypesBundle release];
        mCoreTypesBundle = [theCoreTypesBundle retain];
    }
}

- (NSString*)iconFromSystemIconsBundleWithName:(NSString*)iconName;
{
	NSString* path = [[self coreTypesBundle] pathForImageResource:iconName];
	
    return path;
}

@end
