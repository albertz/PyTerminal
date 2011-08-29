/*
 *  NTViewOptionConstants.h
 *  CocoatechCoreData
 *
 *  Created by Steve Gehrman on 7/30/07.
 *  Copyright 2007 __MyCompanyName__. All rights reserved.
 *
 */

// move this file to PathFinderModels framework when coredata is deleted.

typedef enum NTBrowserViewStyle
{
	kBrowserViewStyle_undefined,
	kBrowserViewStyle_list,
	kBrowserViewStyle_icon,
	kBrowserViewStyle_desktop,
	kBrowserViewStyle_column,
	kBrowserViewStyle_coverflow,
} NTBrowserViewStyle;

#define kViewOptions_icon @"iconViewOptions"
#define kViewOptions_list @"listViewOptions"
#define kViewOptions_coverflow @"coverflowViewOptions"
#define kViewOptions_column @"columnViewOptions"
#define kViewOptions_desktop @"desktopViewOptions"
