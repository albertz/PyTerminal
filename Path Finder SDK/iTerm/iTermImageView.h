/*
 **  iTermImageView.h
 **
 **  Copyright (c) 2002, 2003
 **
 **  Author: Ujwal S. Sathyam
 **
 **  Project: iTerm
 **
 **  Description: Header file for iTermImageView
 **
 **  This program is free software; you can redistribute it and/or modify
 **  it under the terms of the GNU General Public License as published by
 **  the Free Software Foundation; either version 2 of the License, or
 **  (at your option) any later version.
 **
 **  This program is distributed in the hope that it will be useful,
 **  but WITHOUT ANY WARRANTY; without even the implied warranty of
 **  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 **  GNU General Public License for more details.
 **
 **  You should have received a copy of the GNU General Public License
 **  along with this program; if not, write to the Free Software
 **  Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 */

#ifndef _ITERM_IMAGEVIEW_H
#define _ITERM_IMAGEVIEW_H

#import <AppKit/AppKit.h>


@interface iTermImageView : NSImageView
{
    float transparency;
}

- (id) initWithFrame:(NSRect)frame;
- (void) dealloc;

- (void)setImage:(NSImage *)image;

- (void) drawRect: (NSRect) rect;

- (float) transparency;
- (void) setTransparency: (float) theTransparency;

- (BOOL) isOpaque;
- (BOOL) acceptsFirstResponder;

@end


#endif // _ITERM_IMAGEVIEW_H