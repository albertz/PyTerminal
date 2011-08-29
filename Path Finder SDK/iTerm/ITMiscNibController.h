//
//  ITMiscNibController.h
//  iTerm
//
//  Created by Steve Gehrman on 1/23/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class ITTerminalView;

@interface ITMiscNibController : NSObject {
	ITTerminalView* mTerm;  // not retained
	
    IBOutlet id mCommandField;
    IBOutlet id mParameterName;
    IBOutlet id mParameterPanel;
    IBOutlet id mParameterPrompt;
    IBOutlet id mParameterValue;
    IBOutlet id mCommandView;
}

+ (ITMiscNibController*)controller:(ITTerminalView*)term;

- (NSString *)askUserForString:(NSString *)command window:(NSWindow*)window;

- (id)commandField;
- (void)setCommandField:(id)theCommandField;

- (id)parameterName;
- (void)setParameterName:(id)theParameterName;

- (id)parameterPanel;
- (void)setParameterPanel:(id)theParameterPanel;

- (id)parameterPrompt;
- (void)setParameterPrompt:(id)theParameterPrompt;

- (id)parameterValue;
- (void)setParameterValue:(id)theParameterValue;

@end
