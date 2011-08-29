//
//  ITIconStore.h
//  iTerm
//
//  Created by Steve Gehrman on 2/2/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface ITIconStore : NSObject
{
	NSBundle * mCoreTypesBundle;
}

+ (ITIconStore*)sharedInstance;

// GenericPreferencesIcon for example
- (NSImage*)image:(NSString*)identifier;

- (NSImage*)popupArrowImage:(NSColor*)color 
					  small:(BOOL)small;

@end

