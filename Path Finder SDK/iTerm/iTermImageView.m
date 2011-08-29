/*
 **  iTermImageView.m
 **
 **  Copyright (c) 2002, 2003
 **
 **  Author: Ujwal S. Sathyam
 **
 **  Project: iTerm
 **
 **  Description: handles image background for iTerm.
 **
 **  This program is free software; you can redistribute it and/or modify
 **  it under the terms of the GNU General Public License as published by
 **  the Free Software Foundation; either version 2 of the License, or
 **  (at your option) any later version.
 **
 **  This program is distributed in the hope that it will be useful,
 **  but WITHOUT ANY WARRANTY; without even the implied warranty of
 **  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 **  GNU General Public License for more details.
 **
 **  You should have received a copy of the GNU General Public License
 **  along with this program; if not, write to the Free Software
 **  Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 */

#import <iTerm/iTerm.h>
#import <iTerm/iTermImageView.h>

#define DEBUG_ALLOC		0

@implementation iTermImageView

- (id) initWithFrame:(NSRect)frame
{
#if DEBUG_ALLOC
    NSLog(@"iTermImageView: initWithFrame");
#endif
    self = [super initWithFrame: frame];
    return (self);
}

- (void) dealloc
{
#if DEBUG_ALLOC
    NSLog(@"iTermImageView: dealloc");
#endif
    [super dealloc];
}

- (void)setImage:(NSImage *)image
{
	// rotate the image 180 degrees
	NSImage *targetImage = [[NSImage alloc] initWithSize: [image size]];
	NSAffineTransform *trans = [NSAffineTransform transform];
	
	[targetImage lockFocus];
	[trans translateXBy:[image size].width/2 yBy:[image size].height/2];
	[trans rotateByDegrees: 180];
	[trans translateXBy:-[image size].width/2 yBy:-[image size].height/2];
	[trans set];
	[image drawInRect:NSMakeRect(0,0,[image size].width,[image size].height) 
			 fromRect:NSMakeRect(0,0,[image size].width,[image size].height) 
			operation:NSCompositeSourceOver
			 fraction:1];
	[targetImage unlockFocus];
	[targetImage setScalesWhenResized: YES];
	
	// set the image
	[super setImage: targetImage];
	[targetImage release];
}

- (BOOL) isFlipped
{
	return YES;
}

-(void)drawRect:(NSRect)rect
{		
    if([self image] == nil)
		return;
	
	if([[self image] size].width != [self bounds].size.width ||
       [[self image] size].height != [self bounds].size.height)
		[[self image] setSize: [self bounds].size];
	
	[[NSColor redColor] set];
	NSFrameRect([self bounds]);
	return;
	
    [[self image] drawInRect: rect fromRect: rect operation: NSCompositeSourceOver fraction: (1.0 - [self transparency])];
}


- (float) transparency
{
    return (transparency);
}

- (void) setTransparency: (float) theTransparency
{
    if(theTransparency >= 0 && theTransparency <= 1)
    {
	transparency = theTransparency;
	[self setNeedsDisplay: YES];
    }
}



- (BOOL) isOpaque
{
    return (YES);
}

- (BOOL) acceptsFirstResponder
{
    return (NO);
}

@end
