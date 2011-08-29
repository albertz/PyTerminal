//
//  NTCoordinate.m
//  CocoatechCore
//
//  Created by Steve Gehrman on Mon Jul 14 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import "NTCoordinate.h"

static NSString* sKeyFormat = @"%ld, %ld";

// global
const NTCoordinate NTInvalidCoordinate = {-1, -1};

@implementation NTCoordinateUtilities

+ (NSString *)keyForCoordinate:(NTCoordinate)coordinate;
{
    return [NSString stringWithFormat:sKeyFormat, (NSInteger) coordinate.x, (NSInteger) coordinate.y];
}

+ (NTCoordinate)coordinateForKey:(NSString*)key;
{
    NTCoordinate result;
    NSInteger x, y;
    
    sscanf([key UTF8String], [sKeyFormat UTF8String] , &x, &y);
    
    result.y  = y;
    result.x = x;
    
    return result;
}

@end
