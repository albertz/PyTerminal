//
//  NSCharacterSet-NTExtensions.h
//  CocoatechCore
//
//  Created by Steve Gehrman on 4/6/09.
//  Copyright 2009 Cocoatech. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSCharacterSet (NTExtensions)

+ (BOOL)isAlphaNum:(unichar)theCharacter;
+ (BOOL)isAlpha:(unichar)theCharacter;
+ (BOOL)isDigit:(unichar)theCharacter;
+ (BOOL)isPrint:(unichar)theCharacter;

@end
