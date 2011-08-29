//
//  NTPopUpButton.m
//  CocoatechCore
//
//  Created by Steve Gehrman on 6/14/08.
//  Copyright 2008 Cocoatech. All rights reserved.
//

#import "NTPopUpButton.h"
#import "NSView-CoreExtensions.h"
#import "NSMenu-NTExtensions.h"

@interface NTPopUpButtonCell : NSPopUpButtonCell {}
- (void)popUpMenu:(NSRect)cellFrame controlView:(NSView*)controlView;
@end

@implementation NTPopUpButton

@synthesize alternateMenu, drawDragDropFrame;

+ (Class)cellClass;
{
    return [NTPopUpButtonCell class];
}

+ (id)button:(NSImage*)image title:(NSString*)title;
{
    NTPopUpButton* result = [[self alloc] initWithFrame:NSZeroRect];
	
	[result setBezelStyle:NSRecessedBezelStyle];
	[result setPullsDown:YES];
 	[result setShowsBorderOnlyWhileMouseInside:YES];
	[result setFont:[NSFont boldSystemFontOfSize:11]]; 
	[[result cell] setArrowPosition:NSPopUpArrowAtBottom];
		
	if (image)
	{
		NSMenu* menu = [[[NSMenu alloc] init] autorelease];
		NSMenuItem* menuItem = [[[NSMenuItem alloc] initWithTitle:@"" action:0 keyEquivalent:@""] autorelease];
		
		[menuItem setImage:image];
		
		[menu addItem:menuItem];
		[result setMenu:menu];
	}
	else if (title)
		[result addItemWithTitle:title];
	
    return [result autorelease];
}

//---------------------------------------------------------- 
// dealloc
//---------------------------------------------------------- 
- (void)dealloc
{
	self.alternateMenu = nil;
	
    [super dealloc];
}

- (BOOL)mouseDownCanMoveWindow;
{
    return NO;
}

- (BOOL)acceptsFirstMouse:(NSEvent *)theEvent;
{
    return YES;
}

- (void)drawRect:(NSRect)rect;
{
	[self askParentToDrawBackground];
	
	[super drawRect:rect]; 
}

- (void)rightMouseDown:(NSEvent*)event;
{
	[[self cell] setHighlighted:YES];
	[self setNeedsDisplayInRect:[self bounds]];
	
	[[self cell] popUpMenu:[self bounds] controlView:self];
	[[self cell] setHighlighted:NO];
}

- (void)sizeToFit;
{
	NSSize result = [self.cell cellSize];
	
	result.width -= 16;
	
    [self setFrameSize:result];
}

@end

// ==========================================================================================

@implementation NTPopUpButtonCell

- (void)popUpMenu:(NSRect)cellFrame controlView:(NSView*)controlView;
{	
	[[(NTPopUpButton*)controlView alternateMenu] popupMenuBelowRect:cellFrame inView:controlView];
}

- (BOOL)trackMouse:(NSEvent *)theEvent inRect:(NSRect)cellFrame ofView:(NSView *)controlView untilMouseUp:(BOOL)flag;
{   
	BOOL result = YES;
	
	[self highlight:YES withFrame:cellFrame inView:controlView];
	
	[self popUpMenu:cellFrame controlView:controlView];
	
	[self  highlight:NO withFrame:cellFrame inView:controlView];
	
    return result;
}

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView;
{	
	[(NTPopUpButton*)controlView askParentToDrawBackground];
	
	[super drawWithFrame:cellFrame inView:controlView];
}

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView;
{	
	cellFrame.size.width += 4;
	[super drawInteriorWithFrame:cellFrame inView:controlView];
}

@end


