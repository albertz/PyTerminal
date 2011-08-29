//
//  NTAnimations.h
//  CocoatechCore
//
//  Created by Steve Gehrman on Sat Aug 02 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import "NTSingletonObject.h"

@class NTAnimationsWindow;

@interface NTAnimations : NTSingletonObject
{
    NTAnimationsWindow *mWindow;
}

- (void)zoomIcon:(NSImage*)image atPoint:(NSPoint)globalPoint;

+ (void)shakeWindow:(NSWindow*)theWindow;
+ (void)setupWindowFadeAnimation:(NSWindowController*)windowController;
@end
