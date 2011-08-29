//
//  iTermOutlineView.m
//  iTerm
//
//  Created by Tianming Yang on 10/23/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "iTermOutlineView.h"


@implementation iTermOutlineView

- (id)init
{
	_lock = [[NSLock alloc] init];
	return [super init];
}
	
- (void)reloadData
{
	[_lock lock];
	[super reloadData];
	[_lock unlock];
}

- (void)dealloc
{
	[_lock release];
	[super dealloc];
}

@end
