//
//  NSLayoutManager-NTExtensions.h
//  CocoatechCore
//
//  Created by Steve Gehrman on 11/24/08.
//  Copyright 2008 Cocoatech. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSLayoutManager (Undocumented)
- (void)setUsesFontLeading:(BOOL)flag;
@end

@interface NSLayoutManager (NTExtensions)
+ (CGFloat)defaultLineHeightForFont:(NSFont *)theFont;
@end
