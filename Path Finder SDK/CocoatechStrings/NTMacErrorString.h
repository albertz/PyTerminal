//
//  NTMacErrorString.h
//  CocoatechStrings
//
//  Created by Steve Gehrman on Fri Oct 17 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NTMacErrorString : NSObject
{
}

+ (NSString*)macErrorString:(NSInteger)err;

@end
