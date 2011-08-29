/*
 **  FindPanelWindowController.h
 **
 **  Copyright (c) 2002, 2003
 **
 **  Author: Fabian, Ujwal S. Setlur
 **
 **  Project: iTerm
 **
 **  Description: Implements the find functions.
 **
 */

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

@class PTYTextView;

@interface FindPanelWindowController : NSWindowController <NSWindowDelegate>
{
    IBOutlet NSTextField *searchStringField;
    IBOutlet NSButton *caseCheckBox;

    id delegate;
}

// init
+ (id)sharedInstance;

// NSWindow delegate methods
- (void)windowWillClose:(NSNotification *)aNotification;
- (void)windowDidLoad;

// action methods
- (IBAction)findNext:(id)sender;
- (IBAction)findPrevious:(id)sender;

// get/set methods
- (id)delegate;
- (void)setDelegate:(id)theDelegate;
- (NSString *) searchString;
- (void)setSearchString: (NSString *) aString;

@end

@interface FindCommandHandler : NSObject
{
    NSString* _searchString;
    BOOL _ignoresCase;
    
}

+ (id)sharedInstance;

- (IBAction)findNext;
- (IBAction)findPrevious;
- (IBAction)findWithSelection;
- (IBAction)jumpToSelection;
- (void)findSubString:(NSString *) subString forwardDirection: (BOOL) direction ignoringCase: (BOOL) caseCheck;
- (void)setSearchString:(NSString*)searchString;
- (NSString*)searchString;
- (BOOL)ignoresCase;
- (void)setIgnoresCase:(BOOL)set;

@end

