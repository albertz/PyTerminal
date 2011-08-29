//
//  CATextLayer-NTExtensions.h
//  CocoatechCore
//
//  Created by Steve Gehrman on 5/15/08.
//  Copyright 2008 Cocoatech. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface CATextLayer (NTExtensions)
+ (CATextLayer *)layerWithText:(NSString *)string;
+ (CATextLayer *)layerWithText:(NSString *)string fontSize:(CGFloat)size;
@end
