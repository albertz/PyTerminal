//
//  NSData-NTExtensions.h
//  CocoatechCore
//
//  Created by Steve Gehrman on 2/5/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSData (NTExtensions)

- (NSData *)inflate;
+ (NSData*)inflateFile:(NSString*)path;

+ (NSData*)dataWithCarbonHandle:(Handle)handle;
- (Handle)carbonHandle;

- (NSData*)encrypt;
- (NSData*)decrypt;

+ (id)dataWithBase64String:(NSString *)base64String;
- initWithBase64String:(NSString *)base64String;
- (NSString *)base64String;

@end
