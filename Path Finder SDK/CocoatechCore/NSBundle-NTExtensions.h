//
//  NSBundle-NTExtensions.h
//  CocoatechCore
//
//  Created by Steve Gehrman on Fri May 16 2003.
//  Copyright (c) 2003 CocoaTech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSBundle (NTExtensions)

- (NSImage*)imageWithName:(NSString*)imageName;
- (NSImage*)imageWithName:(NSString*)imageName inDirectory:(NSString*)directory;

@end
