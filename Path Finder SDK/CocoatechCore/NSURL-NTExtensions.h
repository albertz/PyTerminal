//
//  NSURL-NTExtensions.h
//  CocoatechCore
//
//  Created by Steve Gehrman on 11/4/09.
//  Copyright 2009 Cocoatech. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSURL (NTExtensions)
- (id)resourceForKey:(NSString*)resourceKey;
- (id)resourceForKey:(NSString*)resourceKey error:(NSError**)outError;
@end
