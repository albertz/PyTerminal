// -*- mode:objc -*-
// $Id: iTermApplication.h,v 1.4 2006/11/07 08:03:08 yfabian Exp $
//
/*
 **  iTermApplication.h
 **
 **  Copyright (c) 2002-2004
 **
 **  Author: Ujwal S. Setlur
 **
 **  Project: iTerm
 **
 **  Description: overrides sendEvent: so that key mappings with command mask  
 **				  are handled properly.
 **
 */

#import <Cocoa/Cocoa.h>


@interface iTermApplication : NSApplication {

}

- (void)sendEvent:(NSEvent *)anEvent;

@end
