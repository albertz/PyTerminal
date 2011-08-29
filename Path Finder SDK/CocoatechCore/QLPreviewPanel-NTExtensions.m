//
//  QLPreviewPanel-NTExtensions.m
//  CocoatechCore
//
//  Created by Steve Gehrman on 9/3/09.
//  Copyright 2009 Cocoatech. All rights reserved.
//

#import "QLPreviewPanel-NTExtensions.h"

@implementation QLPreviewPanel (NTExtensions)

+ (BOOL)isVisible;
{
	if (![QLPreviewPanel sharedPreviewPanelExists])
		return NO;
	
	return [[QLPreviewPanel sharedPreviewPanel] isVisible];
}

+ (void)close;
{
	if ([QLPreviewPanel sharedPreviewPanelExists])
		[[QLPreviewPanel sharedPreviewPanel] close];
}

+ (void)reloadIfNeeded;
{
	if ([QLPreviewPanel sharedPreviewPanelExists])
	{
		// only reload if there is a controller and we are visible
		if ([self isVisible] && [[QLPreviewPanel sharedPreviewPanel] dataSource] && [[QLPreviewPanel sharedPreviewPanel] delegate])
			[[QLPreviewPanel sharedPreviewPanel] reloadData];
	}
}

+ (void)toggle:(BOOL)fullScreen;
{
	if ([QLPreviewPanel isVisible])
		[QLPreviewPanel close];
	else
	{
		if (fullScreen)
			[[QLPreviewPanel sharedPreviewPanel] enterFullScreenMode:nil withOptions:nil];
		else
			[[QLPreviewPanel sharedPreviewPanel] makeKeyAndOrderFront:nil];
	}		
}

@end
