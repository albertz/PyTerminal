//
//  NTFont.h
//  CocoatechCore
//
//  Created by Steve Gehrman on Fri Dec 28 2001.
//  Copyright (c) 2001 CocoaTech. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NTFont : NSObject <NSCoding>
{
    NSFont* normal;
    NSFont* bold;
    NSFont* italic;
    NSFont* boldItalic;
}

@property (retain) NSFont* normal;
@property (retain) NSFont* bold;
@property (retain) NSFont* italic;
@property (retain) NSFont* boldItalic;

+ (id)fontWithFont:(NSFont*)font;

// Helvetica Bold - 12pt
- (NSString*)displayString;

@end
