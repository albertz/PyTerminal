//
//  NTNameAndID.h
//  CocoatechCore
//
//  Created by Steve Gehrman on 6/24/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NTNameAndID : NSObject
{
    NSNumber* mIdentifierNumber;
    NSString *mName;
}

+ (NTNameAndID*)nameAndID:(NSString*)name identifier:(NSInteger)identifier;

- (NSInteger)identifier;
- (NSNumber*)identifierNumber;
- (NSString*)name;

@end

@interface NTNameAndID (Utilities)

+ (NSArray*)names:(NSArray*)nameIDArray;
+ (NSArray*)identifiers:(NSArray*)nameIDArray;

@end
