//
//  NTSavePanel.h
//  CocoatechCore
//
//  Created by Steve Gehrman on 3/2/09.
//  Copyright 2009 Cocoatech. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NTSavePanel : NSObject 
{
	id target;
	SEL selector;
	id contextInfo;
	BOOL userClickedOK;
	NSString* resultPath;
}

@property (retain) id target;
@property (assign) SEL selector;
@property (retain) id contextInfo;
@property (assign) BOOL userClickedOK;
@property (retain) NSString *resultPath;

+ (void)chooseSavePath:(NSString*)startPath sheetWindow:(NSWindow*)sheetWindow target:(id)target selector:(SEL)inSelector contextInfo:(id)contextInfo;

@end
