//
//  NTKVObserverProxy.h
//  SourceViewModulePlugin
//
//  Created by Steve Gehrman on 2/22/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class NTKVObserverProxy;

@protocol NTKVObserverProxyDelegateProtocol <NSObject>
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context;
@end

@interface NTKVObserverProxy : NSObject
{
	id<NTKVObserverProxyDelegateProtocol> delegate;
}

@property (assign) id<NTKVObserverProxyDelegateProtocol> delegate;  // owner must clear before release

+ (NTKVObserverProxy*)proxy:(id<NTKVObserverProxyDelegateProtocol>)delegate;

@end
