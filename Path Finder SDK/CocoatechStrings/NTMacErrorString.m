//
//  NTMacErrorString.m
//  CocoatechStrings
//
//  Created by Steve Gehrman on Fri Oct 17 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import "NTMacErrorString.h"
#import "NTLocalizedString.h"

@implementation NTMacErrorString

+ (NSString*)macErrorString:(NSInteger)err;
{
    switch (err)
    {
        case fBsyErr:
            return [NTLocalizedString localize:@"The operation could not be completed because the disk is in use" table:@"macErrors"];
            break;
        default:
            break;
    }
    
    return nil;
}

@end
