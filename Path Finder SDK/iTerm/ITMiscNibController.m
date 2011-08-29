//
//  ITMiscNibController.m
//  iTerm
//
//  Created by Steve Gehrman on 1/23/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "ITMiscNibController.h"
#import "ITTerminalView.h"
#import "ITAddressBookMgr.h"

@interface ITMiscNibController (Private)
- (id)commandView;
- (void)setCommandView:(id)theCommandView;
@end

@implementation ITMiscNibController

- (id)init;
{
	self = [super init];
	
	// load nib
    if (![NSBundle loadNibNamed:@"Misc" owner:self])
    {
        NSLog(@"Failed to load Misc.nib");
        NSBeep();
    }	
	
	return self;
}

//---------------------------------------------------------- 
// dealloc
//---------------------------------------------------------- 
- (void)dealloc
{
    [self setCommandField:nil];
    [self setParameterName:nil];
    [self setParameterPanel:nil];
    [self setParameterPrompt:nil];
    [self setParameterValue:nil];
	[self setCommandView:nil];

    [super dealloc];
}

+ (ITMiscNibController*)controller:(ITTerminalView*)term;
{
	ITMiscNibController* result = [[ITMiscNibController alloc] init];
	
	result->mTerm = term; // not retained
	
	return [result autorelease];
}

- (IBAction)parameterPanelEnd:(id)sender
{
    [NSApp stopModal];
}

- (NSString *)askUserForString:(NSString *)command window:(NSWindow*)window;
{
	NSMutableString *completeCommand = [[[NSMutableString alloc] initWithString:command] autorelease];
	NSRange r1, r2, currentRange;
	
	while (1)
	{
		currentRange = NSMakeRange(0,[completeCommand length]);
		r1 = [completeCommand rangeOfString:@"$$" options:NSLiteralSearch range:currentRange];
		if (r1.location == NSNotFound)
			break;
		currentRange.location = r1.location + 2;
		currentRange.length -= r1.location + 2;
		r2 = [completeCommand rangeOfString:@"$$" options:NSLiteralSearch range:currentRange];
		if (r2.location == NSNotFound) 
			break;
		
		[[self parameterName] setStringValue: [completeCommand substringWithRange:NSMakeRange(r1.location+2, r2.location - r1.location-2)]];
		[[self parameterValue] setStringValue:@""];
		
		[NSApp beginSheet: [self parameterPanel]
		   modalForWindow: window
			modalDelegate: self
		   didEndSelector: nil
			  contextInfo: nil];
		
		[NSApp runModalForWindow:[self parameterPanel]];
		
		[NSApp endSheet:[self parameterPanel]];
		[[self parameterPanel] orderOut:self];
		
		[completeCommand replaceOccurrencesOfString:[completeCommand  substringWithRange:NSMakeRange(r1.location, r2.location - r1.location+2)] withString:[[self parameterValue] stringValue] options:NSLiteralSearch range:NSMakeRange(0,[completeCommand length])];
	}
	
	return completeCommand;
}

//---------------------------------------------------------- 
//  commandField 
//---------------------------------------------------------- 
- (id)commandField
{
    return mCommandField; 
}

- (void)setCommandField:(id)theCommandField
{
    if (mCommandField != theCommandField)
    {
        [mCommandField release];
        mCommandField = [theCommandField retain];
    }
}

//---------------------------------------------------------- 
//  parameterName 
//---------------------------------------------------------- 
- (id)parameterName
{
    return mParameterName; 
}

- (void)setParameterName:(id)theParameterName
{
    if (mParameterName != theParameterName)
    {
        [mParameterName release];
        mParameterName = [theParameterName retain];
    }
}

//---------------------------------------------------------- 
//  parameterPanel 
//---------------------------------------------------------- 
- (id)parameterPanel
{
    return mParameterPanel; 
}

- (void)setParameterPanel:(id)theParameterPanel
{
    if (mParameterPanel != theParameterPanel)
    {
        [mParameterPanel release];
        [mParameterPanel release];  // release twice, it's a top level nib object
		
        mParameterPanel = [theParameterPanel retain];
    }
}

//---------------------------------------------------------- 
//  parameterPrompt 
//---------------------------------------------------------- 
- (id)parameterPrompt
{
    return mParameterPrompt; 
}

- (void)setParameterPrompt:(id)theParameterPrompt
{
    if (mParameterPrompt != theParameterPrompt)
    {
        [mParameterPrompt release];
        mParameterPrompt = [theParameterPrompt retain];
    }
}

//---------------------------------------------------------- 
//  parameterValue 
//---------------------------------------------------------- 
- (id)parameterValue
{
    return mParameterValue; 
}

- (void)setParameterValue:(id)theParameterValue
{
    if (mParameterValue != theParameterValue)
    {
        [mParameterValue release];
        mParameterValue = [theParameterValue retain];
    }
}

- (void)controlTextDidEndEditing:(NSNotification *)aNotification
{
	int move = [[[aNotification userInfo] objectForKey:@"NSTextMovement"] intValue];
	
	NSString *command =  [[self commandField] stringValue];
	if (command == nil || [[command stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""])
		return;
				
	switch (move) 
	{
		case 16: // Return key
			[mTerm runCommand:command];
			break;
		case 17: // Tab key
			[mTerm addNewSession: [[ITAddressBookMgr sharedInstance] defaultBookmarkData] withCommand:[self commandField] withURL:nil];
			break;
		default:
			break;
	}
}

@end

@implementation ITMiscNibController (Private)

//---------------------------------------------------------- 
//  commandView 
//---------------------------------------------------------- 
- (id)commandView
{
    return mCommandView; 
}

- (void)setCommandView:(id)theCommandView
{
    if (mCommandView != theCommandView)
    {
        [mCommandView release];
        [mCommandView release];  // release twice, it's a top level nib object
		
        mCommandView = [theCommandView retain];
    }
}

@end


