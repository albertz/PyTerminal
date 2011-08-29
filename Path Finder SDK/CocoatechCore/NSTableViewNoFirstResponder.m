#import "NSTableViewNoFirstResponder.h"

@implementation NSTableViewNoFirstResponder

- (BOOL)acceptsFirstResponder;
{
	return NO;
}

- (BOOL)becomeFirstResponder;
{
	return NO;
}

- (void)drawRect:(NSRect)rect;
{
	if ([[self window] respondsToSelector:@selector(setFakeFirstResponder:)])
	{
		// forces the selection to draw "selected"
		[[self window] setFakeFirstResponder:self];
		
		[super drawRect:rect];
		
		[[self window] setFakeFirstResponder:nil];
	}
	else
		[super drawRect:rect];
}

@end
