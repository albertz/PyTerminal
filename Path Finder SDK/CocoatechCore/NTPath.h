//
//  NTPath.h
//  CocoatechCore
//
//  Created by Steve Gehrman on Wed Oct 09 2002.
//  Copyright (c) 2002 CocoaTech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NTPath : NSObject
{
    NSString* mv_path;
	NSString* mv_name;
	
    char* mv_fileSystemPath;
    UInt8* mv_UTF8Path;
}

- (id)initWithPath:(NSString*)path;
- (id)initWithFileSystemPath:(const char*)fileSystemPath length:(NSInteger)length;

+ (id)pathWithPath:(NSString*)path;

- (NSString*)path;
- (const char *)fileSystemPath;
- (const UInt8 *)UTF8Path;

- (NSString*)name;
- (NSString*)parentPath;

@end
