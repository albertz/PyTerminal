// -*- mode:objc -*-
// $Id: iTermController.h,v 1.26 2007/01/23 04:46:14 yfabian Exp $
/*
 **  iTermController.h
 **
 **  Copyright (c) 2002, 2003
 **
 **  Author: Fabian, Ujwal S. Setlur
 **	     Initial code by Kiichi Kusama
 **
 **  Project: iTerm
 **
 **  Description: Implements the main application delegate and handles the addressbook functions.
 **
 */

#import <Cocoa/Cocoa.h>

@class ITTerminalView;
@class PTYTextView;
@class TreeNode;

@interface iTermController : NSObject
{
}

+ (iTermController*)sharedInstance;

// this only looks at terminal windows, not embedded views, should probably look at first responders, but doesn't do that now
- (ITTerminalView *)currentTerminal;

- (void)newWindowWithDirectory:(NSString*)path;

// actions are forwarded form application
- (IBAction)newWindow:(id)sender;
- (IBAction)newSession:(id)sender;

- (NSArray *)sortedEncodingList;
- (void)alternativeMenu: (NSMenu *)aMenu forNode: (TreeNode *) theNode target:(id)aTarget;

- (PTYTextView *) frontTextView;

- (ITTerminalView*)launchBookmark:(NSDictionary *)bookmarkData
					   inTerminal:(ITTerminalView *)theTerm;
- (ITTerminalView*)launchBookmark:(NSDictionary *)bookmarkData
					   inTerminal:(ITTerminalView *)theTerm 
						  withURL:(NSString *)url;
- (ITTerminalView*)launchBookmark:(NSDictionary *)bookmarkData
					   inTerminal:(ITTerminalView *)theTerm 
					  withCommand:(NSString *)command;
@end
