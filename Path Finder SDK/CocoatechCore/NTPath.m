//
//  NTPath.m
//  CocoatechCore
//
//  Created by Steve Gehrman on Wed Oct 09 2002.
//  Copyright (c) 2002 CocoaTech. All rights reserved.
//

#import "NTPath.h"
#import "NSString-Utilities.h"

@interface NTPath (Private)
- (void)setUTF8Path:(const char *)cstr length:(NSInteger)length;
- (void)setFileSystemPath:(const char *)cstr length:(NSInteger)length;
- (void)setPath:(NSString *)thePath;
- (void)setName:(NSString *)theName;
@end

@implementation NTPath

- (id)initWithPath:(NSString*)path;
{
    self = [super init];

    [self setPath:path];

    return self;
}

- (id)initWithFileSystemPath:(const char*)fileSystemPath length:(NSInteger)length;
{
	self = [self initWithPath:nil];
	
	[self setFileSystemPath:fileSystemPath length:length];
	
	return self;
}

+ (id)pathWithPath:(NSString*)path;
{
    NTPath* result = [[NTPath alloc] initWithPath:path];

    return [result autorelease];
}

- (void)dealloc;
{
	[self setPath:nil];
	[self setName:nil];
	    
	[self setUTF8Path:nil length:0];
	[self setFileSystemPath:nil length:0];
	
	[super dealloc];
}

- (NSString*)path;
{
	@synchronized(self) {
		if (!mv_path)
		{
			if (mv_UTF8Path)
				[self setPath:[NSString stringWithUTF8String:(const char *)mv_UTF8Path]];
			else if (mv_fileSystemPath)
				[self setPath:[NSString stringWithFileSystemRepresentation:mv_fileSystemPath]];
		}
	}
	
    return mv_path;
}

- (NSString*)parentPath;
{
    return [[self path] stringByDeletingLastPathComponent];
}

- (const char *)fileSystemPath;
{
	@synchronized(self) {
		if (!mv_fileSystemPath)
		{
			if ([[self path] length])
			{
				const char *cstr = [[self path] fileSystemRepresentation];
				
				if (cstr)
					[self setFileSystemPath:cstr length:strlen(cstr)];
			}
		}
	}
    
    return mv_fileSystemPath;
}

// this is not the same as fileSystemPath.  Had a japanese volume fail because I was using filesystem and not UTF8 when calling FSPathMakeRef
- (const UInt8 *)UTF8Path;
{
	@synchronized(self) {
		if (!mv_UTF8Path)
		{
			if ([[self path] length])
			{        
				const char *cstr = [[self path] UTF8String];
				
				if (cstr)
					[self setUTF8Path:cstr length:strlen(cstr)];
			}
		}    
    }
    return mv_UTF8Path;
}

- (NSString *)name
{
	@synchronized(self) {
		if (!mv_name)
			[self setName:[[self path] lastPathComponent]];
	}
	
    return mv_name; 
}

@end

@implementation NTPath (Private)

- (void)setUTF8Path:(const char *)cstr length:(NSInteger)length;
{
	if (mv_UTF8Path)
	{
		free(mv_UTF8Path);
		mv_UTF8Path = nil;
	}
	
	if (cstr)
	{		
		mv_UTF8Path = malloc(length+1);
		memcpy(mv_UTF8Path, cstr, length);
		mv_UTF8Path[length] = 0;
	}
}

- (void)setFileSystemPath:(const char *)cstr length:(NSInteger)length;
{
	if (mv_fileSystemPath)
	{
		free(mv_fileSystemPath);
		mv_fileSystemPath = nil;
	}
	
	if (cstr)
	{
		mv_fileSystemPath = malloc(length+1);
		memcpy(mv_fileSystemPath, cstr, length);
		mv_fileSystemPath[length] = 0;
	}
}

- (void)setName:(NSString *)theName
{
    if (mv_name != theName) {
        [mv_name release];
        mv_name = [theName retain];
    }
}

- (void)setPath:(NSString *)thePath
{
    if (mv_path != thePath) {
		
		// to avoid problems in comparing paths, we don't want to store paths with trailing a "/"
		if ([thePath length] > 1) // make sure the path is not just a "/"
		{
			if ([thePath characterAtIndex:([thePath length]-1)] == '/')
				thePath = [thePath substringToIndex:([thePath length]-1)];
		}
		
        [mv_path release];
        mv_path = [thePath retain];
    }
}


@end

