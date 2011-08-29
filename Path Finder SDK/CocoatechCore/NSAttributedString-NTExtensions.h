//
//  NSAttributedString-NTExtensions.h
//  CocoatechCore
//
//  Created by Steve Gehrman on 11/20/04.
//  Copyright 2004 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSAttributedString (NTExtensions)

+ (NSAttributedString*)stringWithString:(NSString*)inString attributes:(NSDictionary*)attributes;

@end
