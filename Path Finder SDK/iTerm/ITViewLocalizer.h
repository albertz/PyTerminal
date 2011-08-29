/*
 **  ITViewLocalizer.h
 **
 **  Copyright (c) 2002, 2003
 **
 **  Author: Fabian, Ujwal S. Setlur
 **	     Initial code by Kiichi Kusama
 **
 **  Project: iTerm
 **
 **  Description: localizes a view.
 **
 */

#import <Cocoa/Cocoa.h>

@interface ITViewLocalizer : NSObject
{
    NSString* _table;
    NSBundle* _bundle;
}

+ (void)localizeWindow:(NSWindow*)window table:(NSString*)table bundle:(NSBundle*)bundle;
+ (void)localizeView:(NSView*)view table:(NSString*)table bundle:(NSBundle*)bundle;

@end
