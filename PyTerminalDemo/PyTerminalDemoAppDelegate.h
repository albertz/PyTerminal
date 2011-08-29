//
//  PyTerminalDemoAppDelegate.h
//  PyTerminalDemo
//
//  Created by Albert Zeyer on 29.08.11.
//  Copyright 2011 Albert Zeyer. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PyTerminalDemoAppDelegate : NSObject <NSApplicationDelegate> {
	NSWindow *window;
}

@property (assign) IBOutlet NSWindow *window;

@end
