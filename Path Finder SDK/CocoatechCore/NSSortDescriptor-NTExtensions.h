//
//  NSSortDescriptor-NTExtensions.h
//  CocoatechCore
//
//  Created by Steve Gehrman on 12/14/04.
//  Copyright 2004 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSSortDescriptor (NTExtensions)

+ (BOOL)sortAscending:(NSArray*)sortDescriptors;
+ (SEL)sortSelector:(NSArray*)sortDescriptors;
+ (NSString*)sortKey:(NSArray*)sortDescriptors;

+ (NSArray*)sortDescriptors:(NSArray*)sortDescriptors ascending:(BOOL)ascending;

@end
