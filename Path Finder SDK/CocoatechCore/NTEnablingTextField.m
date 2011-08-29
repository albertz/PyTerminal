//
//  NTEnablingTextField.m
//  CocoatechCore
//
//  Created by Steve Gehrman on 1/17/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "NTEnablingTextField.h"
#import "NTEnablingTextFieldCell.h"

@implementation NTEnablingTextField

+ (BOOL)useCellClassFromNib;
{
	return YES;
}

+ (Class)cellClass;
{
	// this only works because we added a poseAs to fix this "bug" in IB see: feed://www.mikeash.com/blog/rss.xml
	return [NTEnablingTextFieldCell class];
}

- (BOOL)isEnabled;
{
	return [[self cell] isEnabled];
}

- (void)setEnabled:(BOOL)enabled;
{
	[[self cell] setEnabled:enabled];
}

@end
