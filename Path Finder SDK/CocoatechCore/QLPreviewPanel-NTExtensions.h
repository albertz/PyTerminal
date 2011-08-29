//
//  QLPreviewPanel-NTExtensions.h
//  CocoatechCore
//
//  Created by Steve Gehrman on 9/3/09.
//  Copyright 2009 Cocoatech. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface QLPreviewPanel (NTExtensions)

+ (void)toggle:(BOOL)fullScreen;

+ (BOOL)isVisible;
+ (void)close;

+ (void)reloadIfNeeded;
@end

