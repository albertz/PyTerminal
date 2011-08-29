//
//  NTHotKeyManager.m
//  CocoatechCore
//
//  Created by Steve Gehrman on 5/16/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "NTHotKeyManager.h"

pascal OSStatus MyHotKeyHandler(EventHandlerCallRef nextHandler,EventRef theEvent,void *userData);
static OSType kHotKeySignature = 'HKmR';

enum {
	kHotKeyID = 12
};

@interface NTHotKeyManager (Private)
- (UInt32)unicharToKeyCode:(unichar)character;
@end

@implementation NTHotKeyManager

@synthesize eventHandlerRef;
@synthesize appHotKeyFunction;

NTSINGLETON_INITIALIZE;
NTSINGLETONOBJECT_STORAGE;

- (id)init;
{
    self = [super init];

    self.appHotKeyFunction = NewEventHandlerUPP(MyHotKeyHandler);

    // install hot key event handler
    EventTypeSpec eventType;
	
    eventType.eventClass = kEventClassKeyboard;
    eventType.eventKind = kEventHotKeyPressed;
	
	EventHandlerRef ref;
    InstallApplicationEventHandler(self.appHotKeyFunction, 1, &eventType, NULL, &ref);
	self.eventHandlerRef = ref;
	
    return self;
}

- (void)dealloc;
{    
    RemoveEventHandler(self.eventHandlerRef);
    DisposeEventHandlerUPP(self.appHotKeyFunction);

    [super dealloc];
}

- (void)removeHotKey:(EventHotKeyRef)hotKeyRef;
{
    // unregister a previous
    if (hotKeyRef)
        UnregisterEventHotKey(hotKeyRef);
}

- (EventHotKeyRef)setHotKey:(unichar)hotKey identifier:(NSInteger)identifier modifierFlags:(NSInteger)modifierFlags
{
    UInt32 hotKeyCode = [self unicharToKeyCode:hotKey];
	EventHotKeyRef result = nil;
	
    if (hotKeyCode)
    {		
        EventHotKeyID hotKeyID;
		
        hotKeyID.signature = kHotKeySignature;
        hotKeyID.id = identifier;
		
		NSInteger modifier = 0;
        if ((modifierFlags & NSCommandKeyMask) == NSCommandKeyMask)
            modifier = cmdKey;		
        
        RegisterEventHotKey(hotKeyCode, modifier, hotKeyID, GetApplicationEventTarget(), kEventHotKeyNoOptions, &result);
    }
	
	return result;
}

@end

@implementation NTHotKeyManager (Private)

- (UInt32)unicharToKeyCode:(unichar)character;
{
    UInt32 result = 0;
    
    // 36 is the return key
    // 122 is the f1 key

    switch (character)
    {
		case 0x20:
			result = 49;
			break;
        case NSF1FunctionKey:
            result = 122;
            break;
        case NSF2FunctionKey:
            result = 120;
            break;
        case NSF3FunctionKey:
            result = 99;
            break;
        case NSF4FunctionKey:
            result = 118;
            break;
        case NSF5FunctionKey:
            result = 96;
            break;
        case NSF6FunctionKey:
            result = 97;
            break;
        case NSF7FunctionKey:
            result = 98;
            break;
        case NSF8FunctionKey:
            result = 100;
            break;
        case NSF9FunctionKey:
            result = 101;
            break;
        case NSF10FunctionKey:
            result = 109;
            break;
        case NSF11FunctionKey:
            result = 103;
            break;
        case NSF12FunctionKey:
            result = 111;
            break;
        case NSF13FunctionKey:
            result = 105;
            break;
        case NSF14FunctionKey:
            result = 107;
            break;
        case NSF15FunctionKey:
            result = 113;
            break;
        default:
            break;
    }
    
    return result;
}

@end

// This routine is called when the command-return hotkey is pressed.  It means it's time to change modes for the blue selection box overlay window.
pascal OSStatus MyHotKeyHandler(EventHandlerCallRef nextHandler, EventRef theEvent, void *userData)
{
    UInt32 eventKind = GetEventKind(theEvent);

    if (eventKind == kEventHotKeyPressed)
    {
        OSStatus err;
        EventHotKeyID hotKeyID;
 
        err = GetEventParameter(theEvent,
                                kEventParamDirectObject,
                                typeEventHotKeyID,
                                NULL,
                                sizeof(EventHotKeyID),
                                NULL,
                                &hotKeyID);

        if (err == noErr)
        {
			if (hotKeyID.signature == kHotKeySignature)			
				[[NSNotificationCenter defaultCenter] postNotificationName:kNTHotKeyManagerNotification object:[NTHotKeyManager sharedInstance] userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:hotKeyID.id], @"identifier", nil]];
        }
    }
	
	return(CallNextEventHandler(nextHandler, theEvent));
}

