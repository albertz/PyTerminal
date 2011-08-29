//
//  NTStaticImageView.h
//  CocoatechCore
//
//  Created by Steve Gehrman on 3/7/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NTStaticImageView : NSImageView 
{
	NSBackgroundStyle cellBackgroundStyle;
}

@property (assign) NSBackgroundStyle cellBackgroundStyle;

+ (NTStaticImageView*)imageView:(NSBackgroundStyle)theBackGroundStyle;

@end
