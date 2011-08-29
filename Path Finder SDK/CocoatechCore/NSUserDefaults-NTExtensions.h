//
//  NSUserDefaults-NTExtensions.h
//  CocoaTechBase
//
//  Created by Steve Gehrman on 11/16/04.
//  Copyright 2004 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class NTFont;

@interface NSUserDefaults (NTExtensions)

- (NSInteger)intForKey:(NSString*)key defaultValue:(NSInteger)defaultValue;
- (NSUInteger)unsignedIntForKey:(NSString*)key defaultValue:(NSUInteger)defaultValue;
- (float)floatForKey:(NSString*)key defaultValue:(CGFloat)defaultValue;
- (double)doubleForKey:(NSString*)key defaultValue:(double)defaultValue;
- (NSString*)stringForKey:(NSString*)key defaultValue:(NSString*)defaultValue;
- (BOOL)boolForKey:(NSString*)key defaultValue:(BOOL)defaultValue;
- (NSNumber*)numberForKey:(NSString*)key defaultValue:(NSNumber*)defaultValue;
- (NSRect)rectForKey:(NSString*)key defaultValue:(NSRect)defaultValue;
- (NTFont*)fontForKey:(NSString*)key defaultValue:(NTFont*)defaultValue;
- (NSColor*)colorForKey:(NSString*)key defaultValue:(NSColor*)defaultValue;

- (void)setInt:(NSInteger)value forKey:(NSString*)key;
- (void)setUnsignedInt:(NSUInteger)value forKey:(NSString*)key;
- (void)setFloat:(float)value forKey:(NSString*)key;
- (void)setDouble:(double)value forKey:(NSString*)key;
- (void)setString:(NSString*)value forKey:(NSString*)key;
- (void)setNumber:(NSNumber*)value forKey:(NSString*)key;
- (void)setRect:(NSRect)value forKey:(NSString*)key;
- (void)setFont:(NTFont*)value forKey:(NSString*)key;
- (void)setColor:(NSColor*)value forKey:(NSString*)key;

- (void)delayedSynchronize;  // synchronize after a few seconds, improve launch time?
@end

@interface NSUserDefaults (NTExtensionsArchived)

// if dictionaries or arrays don't contain the allowed strings, data, dates and numbers, we must archive them and store as data
// Docs: A default’s value can be only property list objects: NSData, NSString, NSNumber, NSDate, NSArray, or NSDictionary.
- (NSDictionary*)archivedDictionaryForKey:(NSString*)key defaultValue:(NSDictionary*)defaultValue;
- (void)setArchivedDictionary:(NSDictionary*)value forKey:(NSString*)key;

- (NSArray*)archivedArrayForKey:(NSString*)key defaultValue:(NSArray*)defaultValue;
- (void)setArchivedArray:(NSArray*)value forKey:(NSString*)key;

@end
