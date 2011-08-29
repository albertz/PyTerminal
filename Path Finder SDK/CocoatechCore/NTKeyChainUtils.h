//
//  NTKeyChainUtils.h
//  CocoatechCore
//
//  Created by Steve Gehrman on Tue May 14 2002.
//  Copyright (c) 2002 CocoaTech. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NTKeyChainUtils : NSObject {

}

+ (NSString*)passwordForService:(NSString*)service accountName:(NSString*)accountName;

@end
