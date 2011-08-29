//
//  ITPopUpButton.h
//  iTerm
//
//  Created by Steve Gehrman on 2/2/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ITPopUpButton : NSPopUpButton <NSCoding>
{
	NSString* mContentImageID;
	NSImage* mContentImage;
	NSImage* mArrowImage;
}

- (NSString *)contentImageID;
- (void)setContentImageID:(NSString *)theContentImageID;

@end
