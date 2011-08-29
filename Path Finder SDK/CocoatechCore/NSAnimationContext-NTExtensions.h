//
//  NSAnimationContext-NTExtensions.h
//  CocoatechCore
//
//  Created by Steve Gehrman on 2/22/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSAnimationContext (NTExtensions)
+ (void)begin:(BOOL)animate duration:(CGFloat)duration;
+ (void)end;
@end
