//
//  NTBGHUDPopUpButton.m
//  CocoatechCore
//
//  Created by Steve Gehrman on 4/5/10.
//  Copyright 2010 Cocoatech. All rights reserved.
//

#import "NTBGHUDPopUpButton.h"
#import "BGHUDPopUpButtonCell.h"

@implementation NTBGHUDPopUpButton

+ (BOOL)useCellClassFromNib;
{
	return YES;
}

+ (Class)cellClass;
{
	return [BGHUDPopUpButtonCell class];
}

@end
