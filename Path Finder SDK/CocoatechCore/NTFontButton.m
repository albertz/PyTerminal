//
//  NTFontButton.m
//  CocoatechCore
//
//  Created by Steve Gehrman on Sun Dec 29 2002.
//  Copyright (c) 2002 CocoaTech. All rights reserved.
//

#import "NTFontButton.h"
#import "NTFont.h"

@implementation NTFontButton

@synthesize delegate;
@synthesize displayedFont;

- (id)initWithFrame:(NSRect)frameRect
{
    self = [super initWithFrame:frameRect];

    [self setDisplayedFont:[NTFont fontWithFont:[NSFont userFontOfSize:0]]];

    return self;
}

//---------------------------------------------------------- 
// dealloc
//---------------------------------------------------------- 
- (void)dealloc
{
	// close font window 
	if ([NSFontPanel sharedFontPanelExists])  // toggles it out?
		[[NSFontPanel sharedFontPanel] orderOut:nil];

    self.delegate = nil;
    self.displayedFont = nil;
    [super dealloc];
}

// override
- (void)setDisplayedFont:(NTFont *)theDisplayedFont
{
    if (displayedFont != theDisplayedFont)
    {
        [displayedFont release];
        displayedFont = [theDisplayedFont retain];
		
		if (![self image])
			[self setTitle:[displayedFont displayString]];
    }
}

- (IBAction)setFontUsingFontPanel:(id)sender;
{
    if ([[self window] makeFirstResponder:self])
	{
		[[NSFontPanel sharedFontPanel] setPanelFont:[self.displayedFont normal] isMultiple:NO];

		[[NSFontPanel sharedFontPanel] orderFront:nil];
	}
}

- (void)changeFont:(id)sender;
{
    [self setDisplayedFont:[NTFont fontWithFont:[sender convertFont:[sender selectedFont]]]];

    if ([delegate respondsToSelector: @selector(fontButton:didChangeToFont:)])
        [delegate fontButton:self didChangeToFont:self.displayedFont];
}

- (void)drawRect:(NSRect)rect
{
    NSRect bounds;

    [super drawRect:rect];

    bounds = [self bounds];
		
    if ([NSGraphicsContext currentContextDrawingToScreen] && [[self window] isKeyWindow] && [[self window] firstResponder] == self)
	{
        [[NSColor keyboardFocusIndicatorColor] set];
        NSFrameRect(NSInsetRect(bounds, 1.0, 1.0));
    }
}

- (BOOL)isFlipped;
{
    return YES;
}

- (BOOL)acceptsFirstResponder;
{
    return YES;
}

- (BOOL)becomeFirstResponder;
{
	[[NSFontManager sharedFontManager] setSelectedFont:[self.displayedFont normal] isMultiple:NO];
	[self setNeedsDisplay:YES];
	
	return [super becomeFirstResponder];
}

- (BOOL)resignFirstResponder;
{
    [self setNeedsDisplay:YES];
	
    return [super resignFirstResponder];
}

@end
