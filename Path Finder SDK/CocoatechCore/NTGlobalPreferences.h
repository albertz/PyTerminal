//
//  NTGlobalPreferences.h
//  CocoatechCore
//
//  Created by sgehrman on Wed Jul 25 2001.
//  Copyright (c) 2001 CocoaTech. All rights reserved.
//

#import "NTSingletonObject.h"

@interface NTGlobalPreferences : NTSingletonObject
{
    UInt32 mSystemColorVersion;
    NSString* _timeFormatString;
}

- (UInt32)systemColorVersion;

- (BOOL)useGraphiteAppearance;

- (NSTimeInterval)doubleClickTime;

- (BOOL)finderDesktopEnabled;

// returns YES if changed
- (BOOL)setFinderDesktopEnabled:(BOOL)set;

// sets NSFileViewer pref to "com.cocoatech.pathfinder"
- (BOOL)fileViewerPrefForBundleID:(NSString*)bundleID;
- (void)setFileViewerPref:(BOOL)set forBundleID:(NSString*)bundleID;

- (NSArray*)finderToolbarItems;
- (void)setFinderToolbarItems:(NSArray*)items;

@end

