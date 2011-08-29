//
//  NTMailDelivery.h
//  CocoatechCore
//
//  Created by Steve Gehrman on 2/12/10.
//  Copyright 2010 Cocoatech. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NTMailDelivery : NSObject {
}

+ (BOOL)deliverMessage:(NSString*)message subject:(NSString*)subject to:(NSString*)to;

@end
