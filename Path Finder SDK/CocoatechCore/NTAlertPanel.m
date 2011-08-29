//
//  NTAlertPanel.m
//  CocoatechCore
//
//  Created by Steve Gehrman on 12/5/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "NTAlertPanel.h"
#import "NTUtilities.h"

@interface NTAlertPanel (Private)
- (SEL)selector;
- (void)setSelector:(SEL)theSelector;

- (id)target;
- (void)setTarget:(id)theTarget;

- (void)setContextInfo:(id)theContextInfo;

- (NSAlert *)alert;
- (void)setAlert:(NSAlert *)theAlert;

- (void)setResultCode:(NSInteger)theResultCode;

- (void)start:(NSAlertStyle)style
		title:(NSString*)title 
	  message:(NSString*)message 
	   window:(NSWindow*)window
defaultButtonTitle:(NSString*)defaultButtonTitle
alternateButtonTitle:(NSString*)alternateButtonTitle
otherButtonTitle:(NSString*)otherButtonTitle
enableEscOnAlternate:(BOOL)enableEscOnAlternate
enableEscOnOther:(BOOL)enableEscOnOther;

@end

@implementation NTAlertPanel

- (id)initWithTarget:(id)target selector:(SEL)selector contextInfo:(id)contextInfo;
{
    self = [super init];
	
	[self setTarget:target];
	[self setSelector:selector];
	[self setContextInfo:contextInfo];
	
    return self;
}

//---------------------------------------------------------- 
// dealloc
//---------------------------------------------------------- 
- (void)dealloc
{
    [self setTarget:nil];
    [self setContextInfo:nil];
    [self setAlert:nil];
    [super dealloc];
}

+ (void)show:(NSAlertStyle)style
	  target:(id)target 
	selector:(SEL)selector
	   title:(NSString*)title
	 message:(NSString*)message
	 context:(id)context 
	  window:(NSWindow*)window;
{
	[self show:style
		target:target 
	  selector:selector
		 title:title
	   message:message
	   context:context 
		window:window
defaultButtonTitle:[NTLocalizedString localize:@"OK"]
alternateButtonTitle:[NTLocalizedString localize:@"Cancel"]];
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
{
	[self show:style
		target:target 
	  selector:selector
		 title:title
	   message:message
	   context:context 
		window:window
defaultButtonTitle:defaultButtonTitle
alternateButtonTitle:alternateButtonTitle
otherButtonTitle:nil];
}

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
{
	[self show:style
		target:target 
	  selector:selector
		 title:title
	   message:message
	   context:context 
		window:window
defaultButtonTitle:defaultButtonTitle
alternateButtonTitle:alternateButtonTitle
otherButtonTitle:otherButtonTitle
enableEscOnAlternate:YES
enableEscOnOther:NO
   defaultsKey:nil];
}

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
{
    // NTAlertPanel retains the target, so we will be retained until the sheet or panel is dismissed
    NTAlertPanel* sheet = [[NTAlertPanel alloc] initWithTarget:target selector:selector contextInfo:context];
	LEAKOK(sheet);

	if ([defaultsKey length])
	{
		// add our checkbox to the alerts window
		NSView* contentView = [[[sheet alert] window] contentView];
		NSButton* checkbox = [[[NSButton alloc] initWithFrame:NSMakeRect(10,5,300,20)] autorelease];
		[checkbox setButtonType:NSSwitchButton];
		[[checkbox cell] setControlSize:NSSmallControlSize];
		[checkbox setTitle:[NTLocalizedString localize:@"Do not ask me again"]];
		[[checkbox cell] bind:@"value" 
					 toObject:[NSUserDefaults standardUserDefaults]
				  withKeyPath:defaultsKey options:0];
		[contentView addSubview:checkbox];
	}
	
	[sheet start:style 
		   title:title
		 message:message
		  window:window
defaultButtonTitle:defaultButtonTitle 
alternateButtonTitle:alternateButtonTitle
otherButtonTitle:otherButtonTitle
enableEscOnAlternate:enableEscOnAlternate
enableEscOnOther:enableEscOnOther];
}

- (void)alertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo;
{
    // must hide the sheet before we send out the action, otherwise our window wont get the action
    [[alert window] orderOut:self];
	
    [self setResultCode:returnCode];
	
    // always call action, the target must call us and ask for the resultCode
	[NSApp sendAction:[self selector] to:[self target] from:self];
	
    // we release ourselves when the window goes away
    [self autorelease];
}

//---------------------------------------------------------- 
//  contextInfo 
//---------------------------------------------------------- 
- (id)contextInfo
{
    return mContextInfo; 
}

//---------------------------------------------------------- 
//  resultCode 
//---------------------------------------------------------- 
- (NSInteger)resultCode
{
    return mResultCode;
}

@end

@implementation NTAlertPanel (Private)

//---------------------------------------------------------- 
//  selector 
//---------------------------------------------------------- 
- (SEL)selector
{
    return mSelector;
}

- (void)setSelector:(SEL)theSelector
{
    mSelector = theSelector;
}

//---------------------------------------------------------- 
//  target 
//---------------------------------------------------------- 
- (id)target
{
    return mTarget; 
}

- (void)setTarget:(id)theTarget
{
    if (mTarget != theTarget) {
        [mTarget release];
        mTarget = [theTarget retain];
    }
}

- (void)setContextInfo:(id)theContextInfo
{
    if (mContextInfo != theContextInfo) {
        [mContextInfo release];
        mContextInfo = [theContextInfo retain];
    }
}

//---------------------------------------------------------- 
//  alert 
//---------------------------------------------------------- 
- (NSAlert *)alert
{
	if (!mAlert)
		[self setAlert:[[[NSAlert alloc] init] autorelease]];
	
    return mAlert; 
}

- (void)setAlert:(NSAlert *)theAlert
{
    if (mAlert != theAlert) {
        [mAlert release];
        mAlert = [theAlert retain];
    }
}

- (void)setResultCode:(NSInteger)theResultCode
{
    mResultCode = theResultCode;
}

- (void)start:(NSAlertStyle)style
		title:(NSString*)title 
	  message:(NSString*)message 
	   window:(NSWindow*)window
defaultButtonTitle:(NSString*)defaultButtonTitle
alternateButtonTitle:(NSString*)alternateButtonTitle
otherButtonTitle:(NSString*)otherButtonTitle
enableEscOnAlternate:(BOOL)enableEscOnAlternate
enableEscOnOther:(BOOL)enableEscOnOther;
{
	NSButton* button;
	
	[[self alert] setAlertStyle:style];
	[[self alert] setMessageText:title];
	[[self alert] setInformativeText:message];
	
	button = [[self alert] addButtonWithTitle:defaultButtonTitle];
	[button setKeyEquivalent:@"\r"];
	
	button = [[self alert] addButtonWithTitle:alternateButtonTitle];
	if (enableEscOnAlternate)
		[button setKeyEquivalent:@"\e"];
	
	if (otherButtonTitle)
	{
		button = [[self alert] addButtonWithTitle:otherButtonTitle];
		if (!enableEscOnAlternate && enableEscOnOther)
			[button setKeyEquivalent:@"\e"];
	}
	
	if (window)
		[[self alert] beginSheetModalForWindow:window modalDelegate:self didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:) contextInfo:[self contextInfo]];
    else
    {
        [self setResultCode:[[self alert] runModal]];
		
	    // always call action, the target must call us and ask for the resultCode
		[NSApp sendAction:[self selector] to:[self target] from:self];
		
        // we release ourselves when the window goes away
        [self autorelease];
	}
}

@end
