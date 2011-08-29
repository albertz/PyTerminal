//
//  NTPasteboardHelper.h
//  CocoatechCore
//
//  Created by Steve Gehrman on 11/10/08.
//  Copyright 2008 Cocoatech. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol NTPasteboardHelperOwnerProtocol <NSObject>
- (void)pasteboard:(NSPasteboard *)sender provideDataForType:(NSString *)type;
@end

@interface NTPasteboardHelper : NSObject
{
    NSMutableDictionary *typeToOwner;
    NSUInteger responsible;
    NSPasteboard *pasteboard;
	NSString* notificationName;  // sends when owner changes
}

@property (nonatomic, retain) NSMutableDictionary *typeToOwner;
@property (nonatomic, assign) NSUInteger responsible;
@property (nonatomic, retain) NSPasteboard *pasteboard;
@property (nonatomic, retain) NSString* notificationName;  // notifies before being deleted

+ (NTPasteboardHelper *)helperWithPasteboard:(NSPasteboard *)newPasteboard;

- (void)declareTypes:(NSArray *)someTypes owner:(id<NTPasteboardHelperOwnerProtocol>)anOwner;
- (void)addTypes:(NSArray *)someTypes owner:(id<NTPasteboardHelperOwnerProtocol>)anOwner;

@end
