//
//  NTSimpleAlert.h
//  CocoatechCore
//
//  Created by sgehrman on Thu Aug 30 2001.
//  Copyright (c) 2001 CocoaTech. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NTSimpleAlert : NSObject {

}

// sheets (if window nil, it calls the panel variants)
+ (void)alertSheet:(NSWindow*)window message:(NSString*)message subMessage:(NSString*)subMessage;
+ (void)criticalAlertSheet:(NSWindow*)window message:(NSString*)message subMessage:(NSString*)subMessage;
+ (void)infoSheet:(NSWindow*)window message:(NSString*)message subMessage:(NSString*)subMessage;

// panels
+ (void)alertPanel:(NSString*)message subMessage:(NSString*)subMessage;
+ (void)criticalAlertPanel:(NSString*)message subMessage:(NSString*)subMessage;
+ (void)infoPanel:(NSString*)message subMessage:(NSString*)subMessage;

@end
