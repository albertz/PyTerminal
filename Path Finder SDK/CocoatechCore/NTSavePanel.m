//
//  NTSavePanel.m
//  CocoatechCore
//
//  Created by Steve Gehrman on 3/2/09.
//  Copyright 2009 Cocoatech. All rights reserved.
//

#import "NTSavePanel.h"
#import "NSSavePanel-NTExtensions.h"
#import "NTUtilities.h"

@interface NTSavePanel (Private)
- (void)showSavePanel:(NSString*)startPath sheetWindow:(NSWindow*)sheetWindow;
- (void)handleResult:(NSSavePanel *)savePanel returnCode:(NSInteger)returnCode;
@end

@implementation NTSavePanel

@synthesize target;
@synthesize selector;
@synthesize contextInfo;
@synthesize userClickedOK;
@synthesize resultPath;

//---------------------------------------------------------- 
// dealloc
//---------------------------------------------------------- 
- (void) dealloc
{
    self.target = nil;
    self.contextInfo = nil;
    self.resultPath = nil;
    [super dealloc];
}

+ (void)chooseSavePath:(NSString*)startPath sheetWindow:(NSWindow*)sheetWindow target:(id)target selector:(SEL)inSelector contextInfo:(id)contextInfo;
{
	NTSavePanel* result = [[NTSavePanel alloc] init];  // autoreleases when done
	LEAKOK(result);

	result.target = target;
	result.selector = inSelector;
	result.contextInfo = contextInfo;
	
	[result showSavePanel:startPath sheetWindow:sheetWindow];
}

@end

@implementation NTSavePanel (Private)

- (void)showSavePanel:(NSString*)startPath sheetWindow:(NSWindow*)sheetWindow;
{
	NSSavePanel *sp = [NSSavePanel savePanel];
	
    [sp setCanSelectHiddenExtension:NO];  // SNG - add support for this if possible
    
    [sp setDirectory:startPath];
    
    // if the desktop, we need a modal dialog, not a sheet
    if (sheetWindow)
        [sp beginSheetForDirectory:[startPath stringByDeletingLastPathComponent] file:[startPath lastPathComponent] modalForWindow:sheetWindow modalDelegate:self didEndSelector:@selector(savePanelDidEnd:returnCode:contextInfo:) contextInfo:nil];
    else
    {
        NSInteger result = [sp runModalForDirectory:[startPath stringByDeletingLastPathComponent] file:[startPath lastPathComponent]];
        
        [self handleResult:sp returnCode:result];
    }
	
}

- (void)savePanelDidEnd:(NSSavePanel *)savePanel returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{
	[self handleResult:savePanel returnCode:returnCode];
}

- (void)handleResult:(NSSavePanel *)savePanel returnCode:(NSInteger)returnCode;
{
	if ([savePanel handleSavePanelOK:returnCode])
    {
		self.resultPath = [savePanel filename];
		self.userClickedOK = YES;
	}
	
	// must hide the sheet before we send out the action, otherwise our window wont get the action
    [savePanel orderOut:nil];

	[NSApp sendAction:self.selector to:self.target from:self];
	
	[self autorelease];
}

@end
