//
//  NTPopUpButton.h
//  CocoatechCore
//
//  Created by Steve Gehrman on 6/14/08.
//  Copyright 2008 Cocoatech. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NTPopUpButton : NSPopUpButton 
{
	NSMenu* alternateMenu;
	BOOL drawDragDropFrame;
}

@property (retain) NSMenu* alternateMenu;
@property (assign) BOOL drawDragDropFrame;

+ (id)button:(NSImage*)image title:(NSString*)title;

@end
