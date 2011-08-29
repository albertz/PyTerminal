//
//  NSBundle-NTExtensions.m
//  CocoatechCore
//
//  Created by Steve Gehrman on Fri May 16 2003.
//  Copyright (c) 2003 CocoaTech. All rights reserved.
//

#import "NSBundle-NTExtensions.h"


@implementation NSBundle (NTExtensions)

- (NSImage*)imageWithName:(NSString*)imageName;
{
    NSString* path = [self pathForImageResource:imageName];
	
    if (path)
        return [[[NSImage alloc] initWithContentsOfFile:path] autorelease];
	
    return nil;
}

- (NSImage*)imageWithName:(NSString*)imageName inDirectory:(NSString*)directory;
{
    NSString* path = [self pathForResource:[imageName stringByDeletingPathExtension] ofType:[imageName pathExtension] inDirectory:directory];
	
    if (path)
        return [[[NSImage alloc] initWithContentsOfFile:path] autorelease];
	
    return nil;
}

@end
