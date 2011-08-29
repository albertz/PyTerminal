//
//  NTAlertPanel.h
//  CocoatechCore
//
//  Created by Steve Gehrman on 12/5/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NTAlertPanel : NSObject
{
	SEL mSelector;
	id mTarget;
	id mContextInfo;
	NSAlert *mAlert;
	
	NSInteger mResultCode;
}

+ (void)show:(NSAlertStyle)style
	  target:(id)target 
	selector:(SEL)selector
	   title:(NSString*)title
	 message:(NSString*)message
	 context:(id)context 
	  window:(NSWindow*)window
defaultButtonTitle:(NSString*)defaultButtonTitle
alternateButtonTitle:(NSString*)alternateButtonTitle;

+ (void)show:(NSAlertStyle)style
	  target:(id)target 
	selector:(SEL)selector
	   title:(NSString*)title
	 message:(NSString*)message
	 context:(id)context 
	  window:(NSWindow*)window
defaultButtonTitle:(NSString*)defaultButtonTitle
alternateButtonTitle:(NSString*)alternateButtonTitle
otherButtonTitle:(NSString*)otherButtonTitle;

+ (void)show:(NSAlertStyle)style
	  target:(id)target 
	selector:(SEL)selector
	   title:(NSString*)title
	 message:(NSString*)message
	 context:(id)context 
	  window:(NSWindow*)window
defaultButtonTitle:(NSString*)defaultButtonTitle
alternateButtonTitle:(NSString*)alternateButtonTitle
otherButtonTitle:(NSString*)otherButtonTitle
enableEscOnAlternate:(BOOL)enableEscOnAlternate
enableEscOnOther:(BOOL)enableEscOnOther
 defaultsKey:(NSString*)defaultsKey;

+ (void)show:(NSAlertStyle)style
	  target:(id)target 
	selector:(SEL)selector
	   title:(NSString*)title
	 message:(NSString*)message
	 context:(id)context 
	  window:(NSWindow*)window; // buttons default to OK/Cancel

	// NSAlertFirstButtonReturn, NSAlertSecondButtonReturn, NSAlertThirdButtonReturn
- (NSInteger)resultCode;

	// when your action gets called, the sender of the action is a NTAlertPanel, get your context info here
- (id)contextInfo;

@end

