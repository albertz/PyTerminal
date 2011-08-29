//
//  NTStringView.h
//  CocoatechCore
//
//  Created by Steve Gehrman on 3/3/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NTStringView : NSTextField
{
	NSBackgroundStyle cellBackgroundStyle;
	NSSize cachedMinSizeToFit;
}

@property (assign) NSBackgroundStyle cellBackgroundStyle;
@property (assign) NSSize cachedMinSizeToFit;

+ (NTStringView*)stringView:(NSBackgroundStyle)theBackGroundStyle;

- (NSSize)minSizeToFit;

@end
