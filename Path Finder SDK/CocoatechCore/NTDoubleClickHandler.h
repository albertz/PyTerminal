//
//  NTDoubleClickHandler.h
//  CocoatechCore
//
//  Created by Steve Gehrman on Fri Mar 07 2003.
//  Copyright (c) 2003 CocoaTech. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class NTRevealParameters;

@protocol NTDoubleClickDelegateProtocol <NSObject>
// object can be an array of NTFileDescs, a single NSString path, or a single NTFileDesc
- (void)handleDoubleClick:(id)object startRect:(NSRect)startRect window:(NSWindow*)window params:(NTRevealParameters*)params;
@end

@interface NTDoubleClickHandler : NSObject
{
    id <NTDoubleClickDelegateProtocol> mDelegate;
}

+ (NTDoubleClickHandler*)sharedInstance;

- (id <NTDoubleClickDelegateProtocol>)delegate;
- (void)setDelegate:(id <NTDoubleClickDelegateProtocol>)theDelegate;

- (void)handleDoubleClick:(id)object startRect:(NSRect)startRect window:(NSWindow*)window params:(NTRevealParameters*)params;

@end
