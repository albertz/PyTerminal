//
//  ITPopUpButton.m
//  iTerm
//
//  Created by Steve Gehrman on 2/2/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "ITPopUpButton.h"
#import "ITIconStore.h"
#import "ITIconStore.h"

@interface ITPopUpButton (Private)
- (NSImage *)arrowImage;
- (void)setArrowImage:(NSImage *)theArrowImage;

- (NSImage *)contentImage;
- (void)setContentImage:(NSImage *)theContentImage;
@end

@implementation ITPopUpButton

- (void)sizeToFit;
{
}

//---------------------------------------------------------- 
// dealloc
//---------------------------------------------------------- 
- (void)dealloc
{
    [self setArrowImage:nil];
	[self setContentImage:nil];
	[self setContentImageID:nil];
	
    [super dealloc];
}

- (void)encodeWithCoder:(NSCoder *)coder 
{
    [coder encodeObject:[self contentImageID] forKey:@"imageID"];
}

- (id)initWithCoder:(NSCoder *)coder 
{
	if (self = [super initWithCoder:coder])
		[self setContentImageID:[coder decodeObjectForKey:@"imageID"]];

	return self;
}

//---------------------------------------------------------- 
//  contentImageID 
//---------------------------------------------------------- 
- (NSString *)contentImageID
{
    return mContentImageID; 
}

- (void)setContentImageID:(NSString *)theContentImageID
{
    if (mContentImageID != theContentImageID)
    {
        [mContentImageID release];
        mContentImageID = [theContentImageID retain];
    }
}

- (void)drawRect:(NSRect)rect;
{
	NSRect toRect = [self bounds];
	NSRect fromRect = [self bounds];
	fromRect.origin = NSZeroPoint;
	
	toRect.origin.x += 2;
	[[self contentImage] drawInRect:toRect fromRect:fromRect operation:NSCompositeSourceOver fraction:1];
	
	NSRect arrowRect = [self bounds];
	NSSize arrowSize = [[self arrowImage] size];
	arrowRect.origin.y = NSMaxY(arrowRect) - arrowSize.height;
	arrowRect.origin.x = NSMaxX(arrowRect) - arrowSize.width;
	arrowRect.size = arrowSize;
	
	fromRect = arrowRect;
	fromRect.origin = NSZeroPoint;
	[[self arrowImage] drawInRect:arrowRect fromRect:fromRect operation:NSCompositeSourceOver fraction:1];
}

@end

@implementation ITPopUpButton (Private)

//---------------------------------------------------------- 
//  contentImage 
//---------------------------------------------------------- 
- (NSImage *)contentImage
{
	if (!mContentImage)
	{
		NSImage* image=nil;
		
		if ([[self contentImageID] isEqualToString:@"newwin"])
		{
			NSBundle *thisBundle = [NSBundle bundleForClass: [self class]];

			NSString* imagePath = [thisBundle pathForResource:@"newwin"
											 ofType:@"icns"];
			image = [[[NSImage alloc] initByReferencingFile: imagePath] autorelease];
		}
		else
			image = [[ITIconStore sharedInstance] image:@"GenericPreferencesIcon"];
		
		[self setContentImage:image];
	}
	
    return mContentImage; 
}

- (void)setContentImage:(NSImage *)theContentImage
{
    if (mContentImage != theContentImage)
    {
        [mContentImage release];
        mContentImage = [theContentImage retain];
		
		[mContentImage setScalesWhenResized:YES];
		[mContentImage setFlipped:YES];
		[mContentImage setSize:[self bounds].size];
    }
}

//---------------------------------------------------------- 
//  arrowImage 
//---------------------------------------------------------- 
- (NSImage *)arrowImage
{
	if (!mArrowImage)
		[self setArrowImage:[[ITIconStore sharedInstance] popupArrowImage:[NSColor blackColor] small:YES]];
	
    return mArrowImage; 
}

- (void)setArrowImage:(NSImage *)theArrowImage
{
    if (mArrowImage != theArrowImage)
    {
        [mArrowImage release];
        mArrowImage = [theArrowImage retain];
    }
}

@end
