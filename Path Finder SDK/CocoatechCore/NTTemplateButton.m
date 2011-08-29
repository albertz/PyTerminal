//
//  NTTemplateButton.m
//  CocoatechCore
//
//  Created by Steve Gehrman on 4/4/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "NTTemplateButton.h"
#import "NSWindow-NTExtensions.h"
#import "NSView-CoreExtensions.h"
#import "NSMenu-NTExtensions.h"

@interface NTTemplateButtonCell : NSButtonCell
{
	BOOL blockStateChange;
}

@property (assign) BOOL blockStateChange;
- (void)setTheState:(NSInteger)value;
@end

@interface NTTemplateButton ()
@property (nonatomic, assign) BOOL mouseOver;
@property (nonatomic, retain) NSTrackingArea* trackingArea;
@end

@interface NTTemplateButton (Private)
- (void)installMouseTracker;
- (void)displayMenu;
- (void)postMouseDownNotification;
@end

@implementation NTTemplateButton

@synthesize mouseOver;
@synthesize menu, mouseDownNotification, trackingArea;

+ (Class)cellClass;
{
	return [NTTemplateButtonCell class];
}

+ (NTTemplateButton*)button:(NSImage*)image;
{
	return [self button:image toggleButton:NO];
}

+ (NTTemplateButton*)button:(NSImage*)image toggleButton:(BOOL)toggleButton;
{
	NSRect buttonBounds = NSZeroRect;
	buttonBounds.size = [image size];
    NTTemplateButton *result = [[self alloc] initWithFrame:buttonBounds];
	
	[result setImage:image];
	
	if (toggleButton)
		[result setButtonType:NSToggleButton];
	else
	{
		[(NTTemplateButtonCell*)result.cell setBlockStateChange:YES];
		[result setButtonType:NSMomentaryChangeButton];
    }
	
	[result setImagePosition:NSImageOnly];
	[result.cell setImageScaling:NSImageScaleProportionallyDown];
	
    [result setBordered:NO];
	
	[result.cell setTitle:nil];
	[result.cell setAlternateTitle:nil];
	[result.cell setAttributedTitle:nil];
	[result.cell setAttributedAlternateTitle:nil];
		
	[result setEnabled:YES];
	
	[result installMouseTracker];

	[[NSNotificationCenter defaultCenter] addObserver:result
											 selector:@selector(windowStateChangedNotification:)
												 name:NSWindowDidResignMainNotification
											   object:nil];        
	[[NSNotificationCenter defaultCenter] addObserver:result
											 selector:@selector(windowStateChangedNotification:)
												 name:NSWindowDidBecomeMainNotification
											   object:nil];     
	
    return [result autorelease];
}

- (void)dealloc;
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];

	[self removeTrackingArea:self.trackingArea];
	self.trackingArea = nil;
	
	self.menu = nil;
	self.mouseDownNotification = nil;
	
	[super dealloc];
}
	
- (void)drawRect:(NSRect)rect;
{
	if ([[self window] dimControls])
		[self setEnabled:NO];
	else
		[self setEnabled:YES];
	
	NSUInteger savedState = [(NSCell*)[self cell] state];
	NSUInteger savedShowsStateBy = [[self cell] showsStateBy];
	if (self.mouseOver)
	{
		[(NTTemplateButtonCell*)[self cell] setTheState:(savedState == NSOnState) ? NSOffState : NSOnState];
		[[self cell] setShowsStateBy:NSContentsCellMask];
	}
	
	[[self cell] setBackgroundStyle:NSBackgroundStyleRaised];
	[[self cell] drawWithFrame:[self bounds] inView:self];
	
	if (self.mouseOver)
	{
		[(NTTemplateButtonCell*)[self cell] setTheState:savedState];
		[[self cell] setShowsStateBy:savedShowsStateBy];
	}
}

- (void)mouseDown:(NSEvent*)event;
{	
	[self postMouseDownNotification];
	
	if ([self menu])
		[self displayMenu];
	else
		[super mouseDown:event];
	
	// reset this if the click moved the view
	[self setMouseOver:NO];
}

- (void)rightMouseDown:(NSEvent*)event;
{
	[self postMouseDownNotification];

	if ([self menu])
		[self displayMenu];
	else
		[super rightMouseDown:event];
}

- (NSSize)size;
{
    return [[self image] size];
}

@end

@implementation NTTemplateButton (Private)

- (void)postMouseDownNotification;
{
	if (self.mouseDownNotification)
		[[NSNotificationCenter defaultCenter] postNotificationName:self.mouseDownNotification object:nil];
}

- (void)displayMenu;
{
	// a menu item could delete us (see hide path navigator), make sure we don't go away while processing click
	[[self retain] autorelease];

	[[self cell] setHighlighted:YES];
	[[self menu] popupMenuBelowRect:[self bounds] inView:self];
	[[self cell] setHighlighted:NO];
}	

- (BOOL)acceptsFirstMouse:(NSEvent *)theEvent;
{
    return YES;
}

- (BOOL)mouseDownCanMoveWindow;
{
	return NO;
}

- (void)windowStateChangedNotification:(NSNotification*)notification;
{
    // make sure the window is our window
    if ([notification object] == [self contentWindow])        
        [self setNeedsDisplay:YES];
}

- (void)installMouseTracker;
{    
	NSUInteger options = NSTrackingMouseEnteredAndExited | NSTrackingActiveInActiveApp | NSTrackingActiveInKeyWindow | NSTrackingInVisibleRect;
	
	if ([self mouseInRectNow])
	{
		options |= NSTrackingAssumeInside;
		[self setMouseOver:YES];
	}
	
    self.trackingArea = [[[NSTrackingArea alloc] initWithRect:NSZeroRect 
														options:options
														  owner:self
													   userInfo:nil] autorelease];
	
    [self addTrackingArea:self.trackingArea];
}

- (void)mouseEntered:(NSEvent *)event
{	
	[self setMouseOver:YES];
	[self setNeedsDisplay:YES];
}

- (void)mouseExited:(NSEvent *)event 
{
	[self setMouseOver:NO];
	[self setNeedsDisplay:YES];
}

@end

@implementation NTTemplateButtonCell

@synthesize blockStateChange;

- (void)setState:(NSInteger)value;
{
	if (self.blockStateChange)
		return;
	
	[super setState:value];
}

- (void)setTheState:(NSInteger)value;
{
	[super setState:value];
}

@end



