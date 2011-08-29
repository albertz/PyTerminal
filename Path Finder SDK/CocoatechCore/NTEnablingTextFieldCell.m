//
//  NTEnablingTextFieldCell.m
//  CocoatechCore
//
//  Created by Steve Gehrman on 1/17/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "NTEnablingTextFieldCell.h"

// had to subclass NSTextField so our control labels would draw enabled and disabled along with their controls

@implementation NTEnablingTextFieldCell

- (void)setEnabled:(BOOL)enabled;
{
    [super setEnabled:enabled];
	
	[self setStringValue:[self stringValue]];
}

- (void)setStringValue:(NSString*)value;
{
	[super setStringValue:value];
	
	NSMutableAttributedString* mString = [[[NSMutableAttributedString alloc] initWithAttributedString:[self attributedStringValue]] autorelease];
	[mString addAttribute:NSForegroundColorAttributeName value:(([self isEnabled]) ? [NSColor controlTextColor] : [NSColor disabledControlTextColor]) range:NSMakeRange(0, [mString length])];
	[self setAttributedStringValue:mString];
}

@end
