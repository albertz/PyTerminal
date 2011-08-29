//
//  NTAquaButtonCell.m
//  CocoatechCore
//
//  Created by Steve Gehrman on 4/10/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "NTAquaButtonCell.h"
#import "NTTableHeaderImages.h"

@interface NTAquaButtonCell (Private)
@end

@implementation NTAquaButtonCell

- (void)commonInit;
{
}

- (id)init
{
    self = [super init];
	
    [self commonInit];
	
    return self;
}

- (void)dealloc;
{
    [super dealloc];
}

- (id)initWithCoder:(NSCoder *)aDecoder;
{
    self = [super initWithCoder:aDecoder];
	
    [self commonInit];
	
    return self;
}

/*- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView;
{
	// draw background aqua
	cellFrame.origin.y -= NSHeight(cellFrame);
	[[NTTableHeaderImages sharedInstance] drawInFrame:cellFrame
										  highlighted:[self state] == NSOnState 
											 selected:[self state] != NSOnState
											  flipped:[controlView isFlipped]];
		
    [super drawInteriorWithFrame:cellFrame inView:controlView];
}
*/

@end

@implementation NTAquaButtonCell (Private)

@end
