//
//  NTMessageProxy.h
//  CocoatechCore
//
//  Created by Steve Gehrman on 2/18/10.
//  Copyright 2010 Cocoatech. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class NTMessageProxy, NTProxy;

@protocol NTMessageProxyProtocol
- (void)messageProxy:(NTMessageProxy*)theProxy message:(id)theMessage;
@end

@interface NTMessageProxy : NSObject {
	NTProxy* targetProxy;
}

+ (NTMessageProxy*)proxy:(id<NTMessageProxyProtocol>)target;

- (void)notify:(id)theMessage; // nil is fine
- (void)invalidate;

@end
