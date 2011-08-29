//
//  NSNumber-NTExtensions.h
//  CocoatechCore
//
//  Created by Steve Gehrman on Thu Mar 06 2003.
//  Copyright (c) 2003 CocoaTech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSNumber (NTExtensions)

+ (NSNumber*)numberWithSize:(NSSize)size;
- (NSSize)sizeNumber;

+ (NSNumber*)unique;
@end
