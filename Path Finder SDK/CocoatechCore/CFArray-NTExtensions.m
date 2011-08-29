//
//  CFArray-NTExtensions.m
//  CocoatechCore
//
//  Created by Steve Gehrman on 11/10/08.
//  Copyright 2008 Cocoatech. All rights reserved.
//

#import "CFArray-NTExtensions.h"

const void * NTNSObjectRetain(CFAllocatorRef allocator, const void *value)
{
    return [(id)value retain];
}

void NTNSObjectRelease(CFAllocatorRef allocator, const void *value)
{
    [(id)value release];
}

CFStringRef NTNSObjectCopyDescription(const void *value)
{
    return (CFStringRef)[[(id)value description] retain];
}

Boolean NTNSObjectIsEqual(const void *value1, const void *value2)
{
    return [(id)value1 isEqual: (id)value2];
}

CFStringRef NTPointerCopyDescription(const void *ptr)
{
    return (CFStringRef)[[NSString alloc] initWithFormat: @"<0x%08x>", ptr];
}

CFStringRef NTIntegerCopyDescription(const void *ptr)
{
    NSInteger i = (NSInteger)ptr;
    assert(sizeof(ptr) >= sizeof(i));
    return (CFStringRef)[[NSString alloc] initWithFormat: @"%d", i];
}

const CFArrayCallBacks NTNonOwnedPointerArrayCallbacks = {
0,     // version;
NULL,  // retain;
NULL,  // release;
NTPointerCopyDescription, // copyDescription
NULL,  // equal
};

const CFArrayCallBacks NTNSObjectArrayCallbacks = {
0,     // version;
NTNSObjectRetain,
NTNSObjectRelease,
NTNSObjectCopyDescription,
NTNSObjectIsEqual,
};

const CFArrayCallBacks NTIntegerArrayCallbacks = {
0,     // version;
NULL,  // retain;
NULL,  // release;
NTIntegerCopyDescription, // copyDescription
NULL,  // equal
};


NSMutableArray *NTCreateNonOwnedPointerArray(void)
{
    return (NSMutableArray *)CFArrayCreateMutable(kCFAllocatorDefault, 0, &NTNonOwnedPointerArrayCallbacks);
}

NSMutableArray *NTCreateIntegerArray(void)
{
    return (NSMutableArray *)CFArrayCreateMutable(kCFAllocatorDefault, 0, &NTIntegerArrayCallbacks);
}

