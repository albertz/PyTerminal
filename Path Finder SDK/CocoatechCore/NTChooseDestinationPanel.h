//
//  NTChooseDestinationPanel.h
//  CocoatechCore
//
//  Created by sgehrman on Mon Aug 27 2001.
//  Copyright (c) 2001 CocoaTech. All rights reserved.
//

#import <Cocoa/Cocoa.h>

// this will autodelete itself when done.
@interface NTChooseDestinationPanel : NSObject
{
    NSString* path;
    id contextInfo;
    BOOL userClickedOK;
    
    SEL selector;
    id target;
}

@property (retain) NSString *path;
@property (retain) id contextInfo;
@property (assign) BOOL userClickedOK;
@property (assign) SEL selector;
@property (retain) id target;

// selector should be a normal action type selector, [sender path] to get path selected
+ (void)chooseDestination:(NSString*)startPath window:(NSWindow*)window target:(id)target selector:(SEL)inSelector contextInfo:(id)contextInfo;
+ (void)chooseDestination:(NSString*)startPath window:(NSWindow*)window target:(id)target selector:(SEL)inSelector contextInfo:(id)contextInfo showInvisibleFiles:(BOOL)showInvisibleFiles;

@end
