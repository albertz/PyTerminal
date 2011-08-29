//
//  NSMutableAttributedString-Extensions.h
//  CocoatechCore
//
//  Created by Steve Gehrman on Sun Jul 06 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSMutableAttributedString (NTExtensions)
- (void)detectURLs:(NSColor*)linkColor;
- (void)appendImage:(NSImage*)image;

+ (NSMutableAttributedString*)stringWithString:(NSString*)inString attributes:(NSDictionary*)attributes;

	// empty mutable string
+ (NSMutableAttributedString*)string;
+ (NSMutableAttributedString*)stringWithURL:(NSURL*)theURL;

- (void)appendString:(NSString *)string attributes:(NSDictionary *)attributes;
- (void)appendString:(NSString *)string;

@end
