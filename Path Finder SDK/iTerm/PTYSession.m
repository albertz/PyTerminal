/*
 **  PTYSession.m
 **
 **  Copyright (c) 2002, 2003
 **
 **  Author: Fabian, Ujwal S. Setlur
 **
 **  Project: iTerm
 **
 **  Description: Implements the model class for a terminal session.
 **
 */

#import "iTerm.h"
#import "PTYSession.h"
#import "PTYTask.h"
#import "PTYTextView.h"
#import "PTYScrollView.h"
#import "VT100Screen.h"
#import "VT100Terminal.h"
#import "PreferencePanel.h"
#import "ITTerminalView.h"
#import "iTermController.h"
#import "NSStringITerm.h"
#import "iTermKeyBindingMgr.h"
#import "ITAddressBookMgr.h"
#import "iTermTerminalProfileMgr.h"
#import "iTermDisplayProfileMgr.h"

#include <unistd.h>
#include <sys/wait.h>
#include <sys/time.h>

#define DEBUG_KEYDOWNDUMP     0

@interface PTYSession (Private)
- (void)_updateTimerTick:(NSTimer *)aTimer;
@end

@interface PTYSession (hidden)
- (void)setScrollView:(PTYScrollView *)theScrollView;
- (void)setTextView:(PTYTextView *)theTextView;
@end

@implementation PTYSession

static NSString *TERM_ENVNAME = @"TERM";
static NSString *PWD_ENVNAME = @"PWD";
static NSString *PWD_ENVVALUE = @"~";

// tab label attributes
static NSColor *normalStateColor;
static NSColor *chosenStateColor;
static NSColor *idleStateColor;
static NSColor *newOutputStateColor;
static NSColor *deadStateColor;

+ (void) initialize
{
	NTINITIALIZE;
	
    normalStateColor = [NSColor blackColor];
    chosenStateColor = [NSColor blackColor];
    idleStateColor = [NSColor redColor];
    newOutputStateColor = [NSColor purpleColor];
    deadStateColor = [NSColor grayColor];
}

// init/dealloc
- (id)init
{
    if ((self = [super init]) == nil)
        return (nil);
	
    gettimeofday(&lastInput, NULL);
    lastOutput = lastBlink = lastUpdate = lastInput;
    antiIdle=EXIT=NO;
    
    addressBookEntry=nil;
			
    // Allocate screen, shell, and terminal objects
    SHELL = [[PTYTask alloc] init];
    TERMINAL = [[VT100Terminal alloc] init];
    SCREEN = [[VT100Screen alloc] init];
    NSParameterAssert(SHELL != nil && TERMINAL != nil && SCREEN != nil);	
	
	// allocate a semaphore to coordinate UI update
	MPCreateBinarySemaphore(&updateSemaphore);
	
    return (self);
}

- (void)dealloc
{
	// release the data processing semaphore
	MPDeleteSemaphore(updateSemaphore);

	[icon release];
    [TERM_VALUE release];
    [name release];
    [windowTitle release];
    [addressBookEntry release];	
	
    [SHELL release];
    SHELL = nil;
	[SCREEN release];
    SCREEN = nil;
    [TERMINAL release];
    TERMINAL = nil;    
    
	[self setScrollView:nil];
    [self setTextView:nil];

	[[NSNotificationCenter defaultCenter] removeObserver: self];
	
    [super dealloc];    
}

- (NSImage*)warningImage;
{
	static NSImage *shared=nil;
	
	if (!shared)
	{
		NSBundle *thisBundle;
		NSString *imagePath;
		
		thisBundle = [NSBundle bundleForClass:[self class]];	
		imagePath = [thisBundle pathForResource:@"important" ofType:@"png"];
		shared = [[NSImage alloc] initByReferencingFile: imagePath];	
	}
	
	return shared;
}

- (NSNumber*)ttyPID;
{
	return [NSNumber numberWithInt:[[self SHELL] pid]];
}

// Session specific methods
- (void)initScreen: (NSRect) aRect width:(int)width height:(int) height
{
    NSSize aSize;
	
    [SCREEN setSession:self];
		
    // Allocate a scrollview
    [self setScrollView:[[[PTYScrollView alloc] initWithFrame: NSMakeRect(0, 0, aRect.size.width, aRect.size.height)] autorelease]];
    [[self scrollView] setHasVerticalScroller:YES];
    [[self scrollView] setAutoresizingMask: NSViewWidthSizable|NSViewHeightSizable];
		    
    // Allocate a text view
    aSize = [[self scrollView] contentSize];
    [self setTextView:[[[PTYTextView alloc] initWithFrame: NSMakeRect(0, 0, aSize.width, aSize.height)] autorelease]];
	[[self textView] setAutoresizingMask: NSViewWidthSizable | NSViewHeightSizable];
	
    // assign terminal and task objects
    [SCREEN setShellTask:SHELL];
    [SCREEN setTerminal:TERMINAL];
    [TERMINAL setScreen: SCREEN];
    [SHELL setDelegate:self];
	
    // initialize the screen
    [SCREEN initScreenWithWidth:width Height:height];
	[self setName:@"Shell"];
	[self setDefaultName:@"Shell"];
	
    [[self textView] setScreen: SCREEN];
    [[self textView] setDelegate: self];
    [[self scrollView] setDocumentView:[self textView]];
    [[self scrollView] setDocumentCursor: [PTYTextView textViewCursor]];

    ai_code=0;
    antiIdle = NO;
    newOutput = NO;
	
	// register for some notifications	
	[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(tabViewWillRedraw:)
                                                 name:@"iTermTabViewWillRedraw"
                                               object:nil];
}

- (BOOL) isActiveSession
{
    return ([[[self tabViewItem] tabView] selectedTabViewItem] == [self tabViewItem]);
}

- (void)startProgram:(NSString *)program
		   arguments:(NSArray *)prog_argv
		 environment:(NSDictionary *)prog_env
{
    NSString *path = program;
    NSMutableArray *argv = [NSMutableArray arrayWithArray:prog_argv];
    NSMutableDictionary *env = [NSMutableDictionary dictionaryWithDictionary:prog_env];
	
	if ([env objectForKey:TERM_ENVNAME] == nil)
        [env setObject:TERM_VALUE forKey:TERM_ENVNAME];
	
    if ([env objectForKey:PWD_ENVNAME] == nil)
        [env setObject:[PWD_ENVVALUE stringByExpandingTildeInPath] forKey:PWD_ENVNAME];
	
    [SHELL launchWithPath:path
				arguments:argv
			  environment:env
					width:[SCREEN width]
				   height:[SCREEN height]];
}

- (void)terminate
{
	// deregister from the notification center
	[[NSNotificationCenter defaultCenter] removeObserver:self];    
    
	EXIT = YES;
	[SHELL stop];	
	
	//stop the timer;
	if (updateTimer) {
		[updateTimer invalidate]; [updateTimer release]; updateTimer = nil;
	}
	// final update of display
	[self updateDisplay];
    
    [addressBookEntry release];
    addressBookEntry = nil;
	
    [[self textView] setScreen: nil];
	[[self textView] setDelegate: nil];
    [[self textView] removeFromSuperview];

    [SHELL setDelegate:nil];
    [SCREEN setShellTask:nil];
    [SCREEN setSession: nil];
    [SCREEN setTerminal: nil];
    [TERMINAL setScreen: nil];

    parent = nil;
	
}

- (void)writeTask:(NSData *)data
{
	// check if we want to send this input to all the sessions
    if ([parent sendInputToAllSessions] == NO)
    {
		if (!EXIT) {
			PTYScroller *ptys=(PTYScroller *)[[self scrollView] verticalScroller];
			
    		[SHELL writeTask: data];
			// Make sure we scroll down to the end
			//[[self textView] deselect];
			[[self textView] scrollEnd];
			[ptys setUserScroll: NO];		
		}
    }
    else
    {
		// send to all sessions
		[parent sendInputToAllSessions: data];
    }
}

- (void)readTask:(char *)buf length:(int)length
{
	if (buf == NULL || EXIT)
        return;
		
    [TERMINAL putStreamData:buf length:length];	
	
	VT100TCC token;
	
	// while loop to process all the tokens we can get
	while(!EXIT && TERMINAL && ((token = [TERMINAL getNextToken]),
								token.type != VT100_WAIT && token.type != VT100CC_NULL))
	{
		// process token
		if (token.type != VT100_SKIP)
		{
			if (token.type == VT100_NOTSUPPORT) {
				//NSLog(@"%s(%d):not support token", __FILE__ , __LINE__);
			}
			else {
				while ([SCREEN changeSize] != NO_CHANGE || [SCREEN printPending]) {
					MPWaitOnSemaphore(updateSemaphore, kDurationForever);
				}
				
				[SCREEN putToken:token];
				newOutput=YES;
				gettimeofday(&lastOutput, NULL);
			}
		}
	} // end token processing loop
}

- (void)brokenPipe
{
	EXIT = YES;
}

- (BOOL) hasKeyMappingForEvent: (NSEvent *) event highPriority: (BOOL) priority
{
    unsigned int modflag;
    NSString *unmodkeystr;
    unichar unmodunicode;
	int keyBindingAction;
	NSString *keyBindingText;
	BOOL keyBindingPriority;
        
    modflag = [event modifierFlags];
    unmodkeystr = [event charactersIgnoringModifiers];
	unmodunicode = [unmodkeystr length]>0?[unmodkeystr characterAtIndex:0]:0;
    	
	// Check if we have a custom key mapping for this event
	keyBindingAction = [[iTermKeyBindingMgr singleInstance] actionForKeyCode: unmodunicode 
																   modifiers: modflag 
																highPriority: &keyBindingPriority
																		text: &keyBindingText 
																	 profile: [[self addressBookEntry] objectForKey: KEY_KEYBOARD_PROFILE]];
	
	return (keyBindingAction >= 0 && keyBindingPriority >= priority);
}

// Screen for special keys
- (void)keyDown:(NSEvent *)event
{
    unsigned char *send_str = NULL;
    unsigned char *dataPtr = NULL;
    int dataLength = 0;
    size_t send_strlen = 0;
    int send_pchr = -1;
	int keyBindingAction;
	NSString *keyBindingText;
	BOOL priority;
    
    unsigned int modflag;
    NSString *keystr;
    NSString *unmodkeystr;
    unichar unicode, unmodunicode;
        
	if (EXIT) return;
	
    modflag = [event modifierFlags];
    keystr  = [event characters];
    unmodkeystr = [event charactersIgnoringModifiers];
    unicode = [keystr length]>0?[keystr characterAtIndex:0]:0;
	unmodunicode = [unmodkeystr length]>0?[unmodkeystr characterAtIndex:0]:0;
	
    gettimeofday(&lastInput, NULL);
        
    // Clear the bell
    [self setBell: NO];
	
	// Check if we have a custom key mapping for this event
	keyBindingAction = [[iTermKeyBindingMgr singleInstance] actionForKeyCode: unmodunicode 
																   modifiers: modflag 
																highPriority: &priority
																		text: &keyBindingText 
																	 profile: [[self addressBookEntry] objectForKey: KEY_KEYBOARD_PROFILE]];
	if (keyBindingAction >= 0)
	{
		NSString *aString;
		unsigned char hexCode;
		int hexCodeTmp;
		
		switch (keyBindingAction)
		{
			case KEY_ACTION_NEXT_SESSION:
				[parent nextSession: nil];
				break;
			case KEY_ACTION_NEXT_WINDOW:
				break;
			case KEY_ACTION_PREVIOUS_SESSION:
				[parent previousSession: nil];
				break;
			case KEY_ACTION_PREVIOUS_WINDOW:
				break;	
			case KEY_ACTION_SCROLL_END:
				[[self textView] scrollEnd];
				break;
			case KEY_ACTION_SCROLL_HOME:
				[[self textView] scrollHome];
				break;
			case KEY_ACTION_SCROLL_LINE_DOWN:
				[[self textView] scrollLineDown: self];
				[(PTYScrollView *)[[self textView] enclosingScrollView] detectUserScroll]; 
				break;
			case KEY_ACTION_SCROLL_LINE_UP:
				[[self textView] scrollLineUp: self];
				[(PTYScrollView *)[[self textView] enclosingScrollView] detectUserScroll]; 
				break;	
			case KEY_ACTION_SCROLL_PAGE_DOWN:
				[[self textView] scrollPageDown: self];
				[(PTYScrollView *)[[self textView] enclosingScrollView] detectUserScroll]; 
				break;
			case KEY_ACTION_SCROLL_PAGE_UP:
				[[self textView] scrollPageUp: self];
				[(PTYScrollView *)[[self textView] enclosingScrollView] detectUserScroll]; 
				break;	
			case KEY_ACTION_ESCAPE_SEQUENCE:
				if ([keyBindingText length] > 0)
				{
					aString = [NSString stringWithFormat:@"\e%@", keyBindingText];
					[self writeTask: [aString dataUsingEncoding: NSUTF8StringEncoding]];
				}
				break;
			case KEY_ACTION_HEX_CODE:
				if ([keyBindingText length] > 0 && sscanf([keyBindingText UTF8String], "%x", &hexCodeTmp) == 1)
				{
					hexCode = (unsigned char) hexCodeTmp;
					[self writeTask:[NSData dataWithBytes:&hexCode length: sizeof(hexCode)]];
				}
				break;
			case KEY_ACTION_IGNORE:
				break;
			default:
				NSLog(@"Unknown key action %d", keyBindingAction);
				break;
		}
	}
    // else do standard handling of event
    else 
    {
		if (modflag & NSFunctionKeyMask)
        {
			NSData *data = nil;
			
			switch(unicode) 
            {
                case NSUpArrowFunctionKey: data = [TERMINAL keyArrowUp:modflag]; break;
				case NSDownArrowFunctionKey: data = [TERMINAL keyArrowDown:modflag]; break;
				case NSLeftArrowFunctionKey: data = [TERMINAL keyArrowLeft:modflag]; break;
				case NSRightArrowFunctionKey: data = [TERMINAL keyArrowRight:modflag]; break;
					
				case NSInsertFunctionKey:
					// case NSHelpFunctionKey:
					data = [TERMINAL keyInsert]; break;
				case NSDeleteFunctionKey:
					data = [TERMINAL keyDelete]; break;
				case NSHomeFunctionKey: data = [TERMINAL keyHome]; break;
				case NSEndFunctionKey: data = [TERMINAL keyEnd]; break;
				case NSPageUpFunctionKey: data = [TERMINAL keyPageUp]; break;
				case NSPageDownFunctionKey: data = [TERMINAL keyPageDown]; break;
					
				case NSPrintScreenFunctionKey:
					break;
				case NSScrollLockFunctionKey:
				case NSPauseFunctionKey:
					break;
				case NSClearLineFunctionKey:
					if ([TERMINAL keypadMode])
						data = [TERMINAL keyPFn: 1];
					break;
			}
			
            if (NSF1FunctionKey<=unicode&&unicode<=NSF35FunctionKey)
                data = [TERMINAL keyFunction:unicode-NSF1FunctionKey+1];
			
			if (data != nil) {
				send_str = (unsigned char *)[data bytes];
				send_strlen = [data length];
			}
		}
		else if ((modflag & NSAlternateKeyMask) && 
				 ([self optionKey] != OPT_NORMAL))
		{
			NSData *keydat = ((modflag & NSControlKeyMask) && unicode>0)?
			[keystr dataUsingEncoding:NSUTF8StringEncoding]:
			[unmodkeystr dataUsingEncoding:NSUTF8StringEncoding];
			// META combination
			if (keydat != nil) {
				send_str = (unsigned char *)[keydat bytes];
				send_strlen = [keydat length];
			}
            if ([self optionKey] == OPT_ESC) {
				send_pchr = '\e';
            }
			else if ([self optionKey] == OPT_META && send_str != NULL) 
            {
				int i;
				for (i = 0; i < send_strlen; ++i)
					send_str[i] |= 0x80;
			}
		}
		else if (unicode == NSEnterCharacter && unmodunicode == NSEnterCharacter)
		{
			send_str = (unsigned char*)"\015";  // Enter key -> 0x0d
			send_strlen = 1;
		}
		else
		{
			int max = [keystr length];
			NSData *data=nil;
			
			if (max!=1||[keystr characterAtIndex:0] > 0x7f)
				data = [keystr dataUsingEncoding:[TERMINAL encoding]];
			else
				data = [keystr dataUsingEncoding:NSUTF8StringEncoding];
			
			// Check if we are in keypad mode
			if ((modflag & NSNumericPadKeyMask) && [TERMINAL keypadMode])
			{
				switch (unicode)
				{
					case '=':
						data = [TERMINAL keyPFn: 2];;
						break;
					case '/':
						data = [TERMINAL keyPFn: 3];
						break;
					case '*':
						data = [TERMINAL keyPFn: 4];
						break;
					default:
						data = [TERMINAL keypadData: unicode keystr: keystr];
						break;
				}
			}
			
			if (data != nil ) {
				send_str = (unsigned char *)[data bytes];
				send_strlen = [data length];
			}
			
			// NSLog(@"modflag = 0x%x; send_strlen = %d; send_str[0] = '%c (0x%x)'", modflag, send_strlen, send_str[0]);
			if (modflag & NSControlKeyMask &&
				send_strlen == 1 &&
				send_str[0] == '|')
			{
				send_str = (unsigned char*)"\034"; // control-backslash
				send_strlen = 1;
			}
			
			else if ((modflag & NSControlKeyMask) && 
				(modflag & NSShiftKeyMask) &&
				send_strlen == 1 &&
				send_str[0] == '/')
			{
				send_str = (unsigned char*)"\177"; // control-?
				send_strlen = 1;
			}						
			else if (modflag & NSControlKeyMask &&
					 send_strlen == 1 &&
					 send_str[0] == '/')
			{
				send_str = (unsigned char*)"\037"; // control-/
				send_strlen = 1;
			}
		}
				
		if (EXIT == NO ) 
        {
			if (send_pchr >= 0) {
				char c = send_pchr;
				dataPtr = (unsigned char*)&c;
				dataLength = 1;
				[self writeTask:[NSData dataWithBytes:dataPtr length:dataLength]];
			}

			if (send_str != NULL) {
				dataPtr = send_str;
				dataLength = send_strlen;
				[self writeTask:[NSData dataWithBytes:dataPtr length:dataLength]];
			}
		}
    }
	
	// let the update thred update display if a key is being held down
	if ([[self textView] keyIsARepeat] == NO)
		[self updateDisplay];
}


- (BOOL)willHandleEvent: (NSEvent *) theEvent
{
    // Handle the option-click event
    return 0;
/*	return (([theEvent type] == NSLeftMouseDown) &&
			([theEvent modifierFlags] & NSAlternateKeyMask));   */
}

- (BOOL)handleEvent: (NSEvent *) theEvent
{
	return NO;
}

- (void)handleOptionClick: (NSEvent *) theEvent
{
	if (EXIT) return;
	
    // Here we will attempt to position the cursor to the mouse-click
	
    NSPoint locationInWindow, locationInTextView, locationInScrollView;
    int x, y;
	float w=[parent charWidth], h=[parent charHeight];
	
    locationInWindow = [theEvent locationInWindow];
    locationInTextView = [[self textView] convertPoint: locationInWindow fromView: nil];
    locationInScrollView = [[self scrollView] convertPoint: locationInWindow fromView: nil];
	
	x = locationInTextView.x/w;
    y = locationInScrollView.y/h + 1;
		
    if (x == [SCREEN cursorX] && y == [SCREEN cursorY])
		return;
	
    NSData *data;
    int i;
    // now move the cursor up or down
    for (i = 0; i < abs(y - [SCREEN cursorY]); i++)
    {
		if (y < [SCREEN cursorY])
            data = [TERMINAL keyArrowUp:0];
		else
            data = [TERMINAL keyArrowDown:0];
		[self writeTask:[NSData dataWithBytes:[data bytes] length:[data length]]];
    }
    // now move the cursor left or right    
    for (i = 0; i < abs(x - [SCREEN cursorX]); i++)
    {
		if (x < [SCREEN cursorX])
			data = [TERMINAL keyArrowLeft:0];
		else
			data = [TERMINAL keyArrowRight:0];
		[self writeTask:[NSData dataWithBytes:[data bytes] length:[data length]]];
    }
    
    // trigger an update of the display.
    [SCREEN updateScreen];
}

// do any idle tasks here
- (void)doIdleTasks
{
}

- (void)insertText:(NSString *)string
{
    NSData *data;
    NSMutableString *mstring;
    int i, max;
	
	if (EXIT) return;

	//    NSLog(@"insertText: %@",string);
    mstring = [NSMutableString stringWithString:string];
    max = [string length];
    for (i=0; i<max; i++) {
        if ([mstring characterAtIndex:i] == 0xa5) {
            [mstring replaceCharactersInRange:NSMakeRange(i, 1) withString:@"\\"];
        }
    }
		    
    data = [mstring dataUsingEncoding:[TERMINAL encoding]
				 allowLossyConversion:YES];

    if (data != nil) 
		[self writeTask:data];

	// let the update thred update display if a key is being held down
	if ([[self textView] keyIsARepeat] == NO)
		[self updateDisplay];
}

- (void)insertNewline:(id)sender
{
    [self insertText:@"\n"];
}

- (void)insertTab:(id)sender
{
    [self insertText:@"\t"];
}

- (void)moveUp:(id)sender
{
    [self writeTask:[TERMINAL keyArrowUp:0]];
}

- (void)moveDown:(id)sender
{
    [self writeTask:[TERMINAL keyArrowDown:0]];
}

- (void)moveLeft:(id)sender
{
    [self writeTask:[TERMINAL keyArrowLeft:0]];
}

- (void)moveRight:(id)sender
{
    [self writeTask:[TERMINAL keyArrowRight:0]];
}

- (void)pageUp:(id)sender
{
    [self writeTask:[TERMINAL keyPageUp]];
}

- (void)pageDown:(id)sender
{
    [self writeTask:[TERMINAL keyPageDown]];
}

- (void)paste:(id)sender
{
    NSPasteboard *board;
    NSMutableString *str;
		
    board = [NSPasteboard generalPasteboard];
    NSParameterAssert(board != nil );
    str = [[[NSMutableString alloc] initWithString:[board stringForType:NSStringPboardType]] autorelease];
	if ([sender tag]) // paste with escape;
	{
		[str replaceOccurrencesOfString:@"\\" withString:@"\\\\" options:NSLiteralSearch range:NSMakeRange(0, [str length])];
		[str replaceOccurrencesOfString:@"'" withString:@"\\'" options:NSLiteralSearch range:NSMakeRange(0, [str length])];
		[str replaceOccurrencesOfString:@"\"" withString:@"\\\"" options:NSLiteralSearch range:NSMakeRange(0, [str length])];
		[str replaceOccurrencesOfString:@" " withString:@"\\ " options:NSLiteralSearch range:NSMakeRange(0, [str length])];
	}
    [self pasteString: str];
}

- (void)pasteString: (NSString *) aString
{
	
    if ([aString length] > 0)
    {
        NSData *strdata = [[aString stringReplaceSubstringFrom:@"\n" to:@"\r"]
                                    dataUsingEncoding:[TERMINAL encoding]
								 allowLossyConversion:YES];
		
		// Do this in a new thread since we do not want to block the read code.
		[NSThread detachNewThreadSelector:@selector(_processWriteDataThread:) toTarget:self withObject:strdata];
		PTYScroller *ptys=(PTYScroller *)[[self scrollView] verticalScroller];
		
		[[self textView] scrollEnd];
		[ptys setUserScroll: NO];				
    }
    else
		NSBeep();
}

- (void)deleteBackward:(id)sender
{
    unsigned char p = 0x08;	// Ctrl+H
		
    [self writeTask:[NSData dataWithBytes:&p length:1]];
}

- (void)deleteForward:(id)sender
{
    unsigned char p = 0x7F;	// DEL
	
    [self writeTask:[NSData dataWithBytes:&p length:1]];
}

- (void)textViewDidChangeSelection: (NSNotification *) aNotification
{
    if ([[PreferencePanel sharedInstance] copySelection])
		[[self textView] copy: self];
}

- (void)textViewResized: (NSNotification *) aNotification;
{
	int w, h;
		
	w = (int)(([[[self scrollView] contentView] frame].size.width - MARGIN * 2)/[parent charWidth]);
	h = (int)(([[[self scrollView] contentView] frame].size.height)/[parent charHeight]);
	
	[SCREEN resizeWidth:w height:h];
	[SHELL setWidth:w  height:h];
	
}

- (void)setLabelAttribute
{
    struct timeval now;
    
    gettimeofday(&now, NULL);
    if ([self exited])
	{
        // dead
        [parent setLabelColor: deadStateColor forTabViewItem: tabViewItem];
        if (isProcessing)
			[self setIsProcessing: NO];
	}
    else if ([[tabViewItem tabView] selectedTabViewItem] != tabViewItem) 
    {
        if (now.tv_sec - lastOutput.tv_sec > 2) {
            if (isProcessing)
                [self setIsProcessing: NO];

            if (newOutput)
			{
				// Idle after new output
                [parent setLabelColor: idleStateColor forTabViewItem: tabViewItem];
			}
            else
			{
				// normal state
                [parent setLabelColor: normalStateColor forTabViewItem: tabViewItem];
			}
        }
        else 
		{
            if (newOutput) {
                if (isProcessing == NO && ![[PreferencePanel sharedInstance] useCompactLabel])
                    [self setIsProcessing: YES];
                
                [parent setLabelColor: newOutputStateColor forTabViewItem: tabViewItem];
            }
        }
    }
    else {
        // front tab
        if (isProcessing)
			[self setIsProcessing: NO];
        newOutput = NO;
        [parent setLabelColor: chosenStateColor forTabViewItem: tabViewItem];
    }
    [self setBell:NO];
}

- (BOOL) bell
{
    return bell;
}

- (void)setBell: (BOOL) flag
{
	if (flag!=bell) {
        bell = flag;
        if (bell)
            [self setIcon: [self warningImage]];
        else
            [self setIcon: nil];
    }
}

- (BOOL) isProcessing
{
	return (isProcessing);
}

- (void)setIsProcessing: (BOOL) aFlag
{
	isProcessing = aFlag;
}

- (void)setPreferencesFromAddressBookEntry: (NSDictionary *) aePrefs
{    
    NSColor *colorTable[2][8];
    int i;
	NSString *displayProfile, *terminalProfile;
	NSDictionary *aDict;
	iTermTerminalProfileMgr *terminalProfileMgr;
	iTermDisplayProfileMgr *displayProfileMgr;
	ITAddressBookMgr *bookmarkManager;
	
	// get our shared managers
	terminalProfileMgr = [iTermTerminalProfileMgr singleInstance];
	displayProfileMgr = [iTermDisplayProfileMgr singleInstance];
	bookmarkManager = [ITAddressBookMgr sharedInstance];
	
	aDict = aePrefs;
	if (aDict == nil)
		aDict = [bookmarkManager defaultBookmarkData];
	
	// grab the profiles
	displayProfile = [aDict objectForKey: KEY_DISPLAY_PROFILE];
	if (displayProfile == nil || [[displayProfileMgr profiles] objectForKey: displayProfile] == nil)
		displayProfile = [displayProfileMgr defaultProfileName];
	terminalProfile = [aDict objectForKey: KEY_TERMINAL_PROFILE];
	if (terminalProfile == nil || [[terminalProfileMgr profiles] objectForKey: terminalProfile] == nil)
		terminalProfile = [terminalProfileMgr defaultProfileName];	
	
    // colors
    [self setForegroundColor: [displayProfileMgr color: TYPE_FOREGROUND_COLOR forProfile:displayProfile]];
    [self setBackgroundColor: [displayProfileMgr color: TYPE_BACKGROUND_COLOR forProfile:displayProfile]];
	[self setSelectionColor: [displayProfileMgr color: TYPE_SELECTION_COLOR forProfile:displayProfile]];
	[self setSelectedTextColor: [displayProfileMgr color: TYPE_SELECTED_TEXT_COLOR forProfile:displayProfile]];	
	[self setBoldColor: [displayProfileMgr color: TYPE_BOLD_COLOR forProfile:displayProfile]];
	[self setCursorColor: [displayProfileMgr color: TYPE_CURSOR_COLOR forProfile:displayProfile]];	
	[self setCursorTextColor: [displayProfileMgr color: TYPE_CURSOR_TEXT_COLOR forProfile:displayProfile]];	
	for (i = TYPE_ANSI_0_COLOR; i < TYPE_ANSI_8_COLOR; i++)
	{
		colorTable[0][i] = [displayProfileMgr color: i forProfile:displayProfile];
		colorTable[1][i] = [displayProfileMgr color: (i + TYPE_ANSI_8_COLOR)  forProfile:displayProfile];
	}	
    for (i=0;i<8;i++) {
        [self setColorTable:i highLight:NO color:colorTable[0][i]];
        [self setColorTable:i highLight:YES color:colorTable[1][i]];
    }
	
    // transparency
    [self setTransparency: [displayProfileMgr transparencyForProfile:displayProfile]];  
    [self setUseTransparency: [displayProfileMgr useTransparencyForProfile:displayProfile]];  
	
	// bold
	[self setDisableBold: [displayProfileMgr disableBoldForProfile:displayProfile]];
	
    // set up the rest of the preferences
    [SCREEN setPlayBellFlag: ![terminalProfileMgr silenceBellForProfile:terminalProfile]];
	[SCREEN setShowBellFlag: [terminalProfileMgr showBellForProfile:terminalProfile]];
	[SCREEN setBlinkingCursor: [terminalProfileMgr blinkCursorForProfile:terminalProfile]];
	[[self textView] setBlinkingCursor: [terminalProfileMgr blinkCursorForProfile:terminalProfile]];
    [self setEncoding: [terminalProfileMgr encodingForProfile:terminalProfile]];
    [self setTERM_VALUE: [terminalProfileMgr typeForProfile:terminalProfile]];
    [self setAntiCode: [terminalProfileMgr idleCharForProfile:terminalProfile]];
    [self setAntiIdle: [terminalProfileMgr sendIdleCharForProfile:terminalProfile]];
    [self setAutoClose: [terminalProfileMgr closeOnSessionEndForProfile:terminalProfile]];
    [self setDoubleWidth:[terminalProfileMgr doubleWidthForProfile:terminalProfile]];
	[self setXtermMouseReporting:[terminalProfileMgr xtermMouseReportingForProfile:terminalProfile]];
}

// Contextual menu
- (void)menuForEvent:(NSEvent *)theEvent menu: (NSMenu *) theMenu
{
    NSMenuItem *aMenuItem;
	
    // Clear buffer
    aMenuItem = [[NSMenuItem alloc] initWithTitle:NTLocalizedStringFromTableInBundle(@"Clear Buffer",@"iTerm", [NSBundle bundleForClass: [self class]], @"Context menu") action:@selector(clearBuffer:) keyEquivalent:@""];
    [aMenuItem setTarget: [self parent]];
    [theMenu addItem: aMenuItem];
    [aMenuItem release];
    
    // Ask the parent if it has anything to add
    if ([[self parent] respondsToSelector:@selector(menuForEvent: menu:)])
		[[self parent] menuForEvent:theEvent menu: theMenu];    
}

- (ITTerminalView *) parent
{
    return (parent);
}

- (void)setParent: (ITTerminalView *) theParent
{
    parent = theParent; // don't retain parent. parent retains self.
}

- (NSTabViewItem *) tabViewItem
{
    return (tabViewItem);
}

- (void)setTabViewItem: (NSTabViewItem *) theTabViewItem
{
    tabViewItem = theTabViewItem;
}

- (NSString *) uniqueID
{
    return ([self tty]);
}

- (void)setUniqueID: (NSString *)uniqueID
{
    NSLog(@"Not allowed to set unique ID");
}

- (NSString *) defaultName
{
    return (defaultName);
}

- (void)setDefaultName: (NSString *) theName
{
    if ([defaultName isEqualToString: theName])
		return;
    
    if (defaultName)
    {		
		// clear the window title if it is not different
		if ([self windowTitle] == nil || [name isEqualToString: [self windowTitle]])
			[self setWindowTitle: nil];
        [defaultName release];
        defaultName = nil;
    }
    if (!theName)
		theName = NTLocalizedStringFromTableInBundle(@"Untitled",@"iTerm", [NSBundle bundleForClass: [self class]], @"Profiles");
	
	defaultName = [theName retain];
}

- (NSString *) name
{
    return (name);
}

- (void)setName: (NSString *) theName
{
    if ([name isEqualToString: theName])
		return;
    
    if (name)
    {		
		// clear the window title if it is not different
		if ([self windowTitle] == nil || [name isEqualToString: [self windowTitle]])
			[self setWindowTitle: nil];
        [name release];
        name = nil;
    }
    if (!theName)
		theName = NTLocalizedStringFromTableInBundle(@"Untitled",@"iTerm", [NSBundle bundleForClass: [self class]], @"Profiles");
	
	name = [theName retain];
	// sync the window title if it is not set to something else
	if ([self windowTitle] == nil)
		[self setWindowTitle: theName];
   
	
	[tabViewItem setLabel: name];
	[self setBell: NO];
}

- (NSString *) windowTitle
{
    return (windowTitle);
}

- (void)setWindowTitle: (NSString *) theTitle
{
	if ([theTitle isEqualToString:windowTitle]) return;
	
    [windowTitle autorelease];
    windowTitle = nil;
    
    if (theTitle != nil)
    {
		windowTitle = [theTitle retain];
		if ([[self parent] currentSession] == self)
            [[self parent] setWindowTitle: theTitle];
    }
}

- (PTYTask *) SHELL
{
    return (SHELL);
}

- (void)setSHELL: (PTYTask *) theSHELL
{
    [SHELL autorelease];
    SHELL = [theSHELL retain];
}

- (VT100Terminal *) TERMINAL
{
    return (TERMINAL);
}

- (void)setTERMINAL: (VT100Terminal *) theTERMINAL
{
    [TERMINAL autorelease];
    TERMINAL = [theTERMINAL retain];
}

- (NSString *) TERM_VALUE
{
    return (TERM_VALUE);
}

- (void)setTERM_VALUE: (NSString *) theTERM_VALUE
{
    [TERM_VALUE autorelease];
    TERM_VALUE = [theTERM_VALUE retain];
    [TERMINAL setTermType: theTERM_VALUE];
}

- (VT100Screen *) SCREEN
{
    return (SCREEN);
}

- (void)setSCREEN: (VT100Screen *) theSCREEN
{
    [SCREEN autorelease];
    SCREEN = [theSCREEN retain];
}

- (NSView *) view
{
    return [self scrollView];
}

- (NSStringEncoding) encoding
{
	return [TERMINAL encoding];
}

- (void)setEncoding:(NSStringEncoding)encoding
{
    [TERMINAL setEncoding:encoding];
}

- (NSString *) tty
{
    return ([SHELL tty]);
}

// I think Applescript needs this method; need to check
- (int) number
{
    return ([[tabViewItem tabView] indexOfTabViewItem: tabViewItem]);
}

- (int) objectCount
{
    return ([[PreferencePanel sharedInstance] useCompactLabel]?0:objectCount);
}

// This one is for purposes other than PSMTabBarControl
- (int) realObjectCount
{
    return (objectCount);
}

- (void)setObjectCount:(int)value
{
    objectCount = value;
}

- (NSImage *) icon
{
	return (icon);
}

- (void)setIcon: (NSImage *) anIcon
{
	[anIcon retain];
	[icon release];
	icon = anIcon;
}

- (NSString *) contents
{
	return ([[self textView] content]);
}

- (NSColor *) foregroundColor
{
    return ([[self textView] defaultFGColor]);
}

- (void)setForegroundColor:(NSColor*) color
{
    if (color == nil)
        return;
    
    if (([[self textView] defaultFGColor] != color) || 
	   ([[[self textView] defaultFGColor] alphaComponent] != [color alphaComponent]))
    {
        // Change the fg color for future stuff
        [[self textView] setFGColor: color];
    }
}

- (NSColor *) backgroundColor
{
    return ([[self textView] defaultBGColor]);
}

- (void)setBackgroundColor:(NSColor*) color
{
    if (color == nil)
        return;
	
    if (([[self textView] defaultBGColor] != color) || 
	   ([[[self textView] defaultBGColor] alphaComponent] != [color alphaComponent]))
    {
        // Change the bg color for future stuff
        [[self textView] setBGColor: color];
    }
    
    [[self scrollView] setBackgroundColor: color];
}

- (NSColor *) boldColor
{
    return ([[self textView] defaultBoldColor]);
}

- (void)setBoldColor:(NSColor*) color
{
    [[self textView] setBoldColor: color];
}

- (NSColor *) cursorColor
{
    return ([[self textView] defaultCursorColor]);
}

- (void)setCursorColor:(NSColor*) color
{
    [[self textView] setCursorColor: color];
}

- (NSColor *) selectionColor
{
    return ([[self textView] selectionColor]);
}

- (void)setSelectionColor: (NSColor *) color
{
    [[self textView] setSelectionColor: color];
}

- (NSColor *) selectedTextColor
{
	return ([[self textView] selectedTextColor]);
}

- (void)setSelectedTextColor: (NSColor *) aColor
{
	[[self textView] setSelectedTextColor: aColor];
}

- (NSColor *) cursorTextColor
{
	return ([[self textView] cursorTextColor]);
}

- (void)setCursorTextColor: (NSColor *) aColor
{
	[[self textView] setCursorTextColor: aColor];
}

// Changes transparency

- (float)transparency
{
    return ([[self textView] transparency]);
}

- (void)setTransparency:(float)transparency
{
    // set transparency of background image
    [[self scrollView] setTransparency: transparency];
	[[self textView] setTransparency: transparency];
}

- (BOOL)useTransparency
{
    return ([[self textView] useTransparency]);
}

- (void)setUseTransparency:(BOOL)useTransparency
{
    // set transparency of background image
	[[self textView] setUseTransparency:useTransparency];
}

- (void)setColorTable:(int) index highLight:(BOOL)hili color:(NSColor *) c
{
    [[self textView] setColorTable:index highLight:hili color:c];
}

- (BOOL) antiIdle
{
    return antiIdle;
}

- (int) antiCode
{
    return ai_code;
}

- (void)setAntiIdle:(BOOL)set
{
    antiIdle=set;
}

- (void)setAntiCode:(int)code
{
    ai_code=code;
}

- (BOOL) autoClose
{
    return autoClose;
}

- (void)setAutoClose:(BOOL)set
{
    autoClose=set;
}

- (BOOL) disableBold
{
	return ([[self textView] disableBold]);
}

- (void)setDisableBold: (BOOL) boldFlag
{
	[[self textView] setDisableBold: boldFlag];
}

- (BOOL) doubleWidth
{
    return doubleWidth;
}

- (void)setDoubleWidth:(BOOL)set
{
    doubleWidth=set;
}

- (BOOL) xtermMouseReporting
{
	return xtermMouseReporting;
}

- (void)setXtermMouseReporting:(BOOL)set
{
	xtermMouseReporting = set;
}

- (BOOL) logging
{
    return ([SHELL logging]);
}

- (void)logStart
{
    NSSavePanel *panel;
    int sts;
	
    panel = [NSSavePanel savePanel];
    sts = [panel runModalForDirectory:NSHomeDirectory() file:@""];
    if (sts == NSOKButton) {
        BOOL logsts = [SHELL loggingStartWithPath:[panel filename]];
        if (logsts == NO)
            NSBeep();
    }
}

- (void)logStop
{
    [SHELL loggingStop];
}

- (void)clearBuffer
{	
    [SCREEN clearBuffer];
}

- (void)clearScrollbackBuffer
{
    [SCREEN clearScrollbackBuffer];
}

- (void)resetStatus;
{
    newOutput = NO;
}

- (BOOL)exited
{
    return EXIT;
}

- (int) optionKey
{
	NSString *kbProfile;
	
	// Grab our keyboard profile
	kbProfile = [[self addressBookEntry] objectForKey: @"Keyboard Profile"];
	
	return ([[iTermKeyBindingMgr singleInstance] optionKeyForProfile:kbProfile]);
}

- (void)setAddressBookEntry:(NSDictionary*) entry
{
    [addressBookEntry release];
    addressBookEntry = [entry retain];
}

- (NSDictionary *)addressBookEntry
{
    return addressBookEntry;
}

- (void)runCommand: (NSString *)command
{
    NSData *data = nil;
    NSString *aString = nil;
	
    if (command != nil)
    {
		aString = [NSString stringWithFormat:@"%@\n", command];
		data = [aString dataUsingEncoding: [TERMINAL encoding]];
    }
	
    if (data != nil)
    {
		[self writeTask:data];
    }
}

- (void)updateDisplay
{
    struct timeval now;
	int i;
    	
    gettimeofday(&now, NULL);

    if (antiIdle && now.tv_sec >= lastInput.tv_sec + 60) {
        [self writeTask:[NSData dataWithBytes:&ai_code length:1]];
        lastInput = now;
    }
	
	if ([[tabViewItem tabView] selectedTabViewItem] != tabViewItem) 
		[self setLabelAttribute];
	
	if ([[[self textView] window] isKeyWindow] && now.tv_sec*10+now.tv_usec/100000 >= lastBlink.tv_sec*10+lastBlink.tv_usec/100000+7) {
        [[self textView] refresh];
		lastUpdate = lastBlink = now;
	}
	else if (lastOutput.tv_sec > lastUpdate.tv_sec || (lastOutput.tv_sec == lastUpdate.tv_sec &&lastOutput.tv_usec > lastUpdate.tv_usec) ) {
        [[self textView] refresh];
		lastUpdate = now;
    }
	
	for (i=0; i<[SCREEN scrollUpLines]; i++) {
		[[self textView] scrollLineUp:nil];
	}
	
	updateCount = 0;
	[SCREEN resetScrollUpLines];
}

- (void)setTimerMode:(int)mode
{	
	//stop the timer;
	if (updateTimer || EXIT) {
		[updateTimer invalidate]; [updateTimer release]; updateTimer = nil;
		if (EXIT) return;
	}

	switch (mode) {
		case FAST_MODE:
			updateTimer = [[NSTimer scheduledTimerWithTimeInterval:0.002 * [[PreferencePanel sharedInstance] refreshRate]
															target:self
														  selector:@selector(_updateTimerTick:)
														  userInfo:nil
														   repeats:YES] retain]; 
			
			break;
		case SLOW_MODE:
			updateTimer = [[NSTimer scheduledTimerWithTimeInterval:0.25
															target:self
														  selector:@selector(_updateTimerTick:)
														  userInfo:nil
														   repeats:YES] retain]; 
			
			break;
	}
	updateCount = 0;
}

- (void)signalUpdateSemaphore
{
	MPSignalSemaphore(updateSemaphore);
}

// Notification
- (void)tabViewWillRedraw: (NSNotification *) aNotification
{
	if ([aNotification object] == [[self tabViewItem] tabView])
		[[self textView] setForceUpdate: YES];
}

//---------------------------------------------------------- 
//  scrollView 
//---------------------------------------------------------- 
- (PTYScrollView *)scrollView
{
    return mScrollView; 
}

- (void)setScrollView:(PTYScrollView *)theScrollView
{
    if (mScrollView != theScrollView)
    {
        [mScrollView release];
        mScrollView = [theScrollView retain];
    }
}

//---------------------------------------------------------- 
//  textView 
//---------------------------------------------------------- 
- (PTYTextView *)textView
{
    return mTextView; 
}

- (void)setTextView:(PTYTextView *)theTextView
{
    if (mTextView != theTextView)
    {
        [mTextView release];
        mTextView = [theTextView retain];
    }
}

@end

@implementation PTYSession (Private)

// this is only used for non keyboard events
- (void)_processWriteDataThread: (NSData *) data
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
    // check if we want to send this input to all the sessions
    if ([parent sendInputToAllSessions] == NO)
    {
		if (!EXIT)
			[SHELL writeTask: data];
    }
    else
    {
		// send to all sessions
		[parent sendInputToAllSessions: data];
    }
	
	[pool release];
}


//Update the display if necessary
- (void)_updateTimerTick:(NSTimer *)aTimer
{   
	if (EXIT) {				
		[self setLabelAttribute];
		
		if ([self autoClose]) {
			[parent closeSession: self];
		}
		else
		{
			[updateTimer invalidate]; [updateTimer release]; updateTimer = nil;
			[self updateDisplay];
		}
	}
	else {
		if ([SCREEN printPending]) {
			[SCREEN doPrint];
			MPSignalSemaphore(updateSemaphore);
		}
		
		[SCREEN acquireLock];
		NSString *newTitle;
		if (newTitle=[SCREEN winTitle]) 
		{
			//NSLog(@"setting window title to %@", token.u.string);
			if ([[iTermTerminalProfileMgr singleInstance] appendTitleForProfile:[addressBookEntry objectForKey: @"Terminal Profile"]]) 
				newTitle = [NSString stringWithFormat:@"%@: %@", defaultName, newTitle];
			[self setWindowTitle: newTitle];
		}
		if (newTitle=[SCREEN iconTitle])
		{
			//NSLog(@"setting session title to %@", token.u.string);
			if ([[iTermTerminalProfileMgr singleInstance] appendTitleForProfile:[addressBookEntry objectForKey: @"Terminal Profile"]]) 
				newTitle = [NSString stringWithFormat:@"%@: %@", defaultName, newTitle];
			[self setName: newTitle];
		}
		[SCREEN resetChangeTitle];
		[SCREEN releaseLock];
	
		[SCREEN updateBell];
		
		switch ([SCREEN changeSize]) {
			case CHANGE:
				// [parent resizeWindow:[SCREEN newWidth] height:[SCREEN newHeight]];
				[SCREEN resetChangeSize];
				// signal the UI updating thread
				MPSignalSemaphore(updateSemaphore);
				break;
			case CHANGE_PIXEL:
				// [parent resizeWindowToPixelsWidth:[SCREEN newWidth] height:[SCREEN newHeight]];
				[SCREEN resetChangeSize];
				// signal the UI updating thread
				MPSignalSemaphore(updateSemaphore);
				break;
		}
		
		if ([[[self textView] window] isKeyWindow] && [parent currentSession] == self)
			[self updateDisplay];
		else if (!(updateCount%2))
			[self updateDisplay];

		updateCount++;
	}
}

@end
