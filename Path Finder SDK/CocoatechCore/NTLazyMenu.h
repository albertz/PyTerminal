//
//  NTLazyMenu.h
//  CocoatechCore
//
//  Created by Steve Gehrman on 12/20/04.
//  Copyright 2004 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NTLazyMenu : NSMenu <NSCopying>
{
	id target;
	SEL action;
	
	NSUInteger buildID;
	
	// can be used by subclasses when building menu
	NSInteger fontSize;
	NSInteger iconSize;
}

+ (NTLazyMenu*)lazyMenu:(NSString*)title target:(id)target action:(SEL)action;

@property (nonatomic, assign) id target;  // not retained
@property (nonatomic, assign) SEL action;
@property (nonatomic, assign) NSUInteger buildID;
@property (nonatomic, assign) NSInteger fontSize;
@property (nonatomic, assign) NSInteger iconSize;

@end

@interface NTLazyMenu (Protocols) <NSMenuDelegate>
// subclass to build your menu
// - (void)menuNeedsUpdate:(NSMenu*)menu;
@end