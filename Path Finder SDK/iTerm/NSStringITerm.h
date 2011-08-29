// $Id: NSStringITerm.h,v 1.2 2006/11/13 06:57:47 yfabian Exp $
//
//  NSStringJTerminal.h
//
//  Additional fucntion to NSString Class by Category
//  2001.11.13 by Y.Hanahara
//  2002.05.18 by Kiichi Kusama
/*
 **  NSStringIterm.h
 **
 **  Copyright (c) 2002, 2003
 **
 **  Author: Fabian
 **	     Initial code by Kiichi Kusama
 **
 **  Project: iTerm
 **
 **  Description: Implements NSString extensions.
 **
 */

#import <Foundation/Foundation.h>


@interface NSString (iTerm)

+ (NSString *)stringWithInt:(int)num;
+ (BOOL)isDoubleWidthCharacter:(unichar)unicode encoding:(NSStringEncoding) e;

- (NSMutableString *) stringReplaceSubstringFrom:(NSString *)oldSubstring to:(NSString *)newSubstring;

@end
