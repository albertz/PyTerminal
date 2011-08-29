//
//  NTObjcRuntimeTools.h
//  CocoatechCore
//
//  Created by Steve Gehrman on 11/10/08.
//  Copyright 2008 Cocoatech. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NTObjcRuntimeTools : NSObject 
{
}

+ (IMP)replaceClassMethodImplementationWithSelectorOnClass:(Class)oldClass
											   oldSelector:(SEL)oldSelector
												  newClass:(Class)newClass 
											   newSelector:(SEL)newSelector;

+ (IMP)replaceMethodImplementationWithSelectorOnClass:(Class)oldClass
										  oldSelector:(SEL)oldSelector
											 newClass:(Class)newClass 
										  newSelector:(SEL)newSelector;

@end

// ====================================================
// undocumented cocoa runtime stuff

id objc_getProperty(id self, SEL _cmd, ptrdiff_t offset, BOOL atomic);
void objc_setProperty(id self, SEL _cmd, ptrdiff_t offset, id newValue, BOOL atomic,
					  BOOL shouldCopy);
void objc_copyStruct(void *dest, const void *src, ptrdiff_t size, BOOL atomic,
					 BOOL hasStrong);


#define AtomicRetainedSetToFrom(dest, source) \
objc_setProperty(self, _cmd, (ptrdiff_t)(&dest) - (ptrdiff_t)(self), source, YES, NO)

#define AtomicCopiedSetToFrom(dest, source) \
objc_setProperty(self, _cmd, (ptrdiff_t)(&dest) - (ptrdiff_t)(self), source, YES, YES)

#define AtomicAutoreleasedGet(source) \
objc_getProperty(self, _cmd, (ptrdiff_t)(&source) - (ptrdiff_t)(self), YES)

#define AtomicStructToFrom(dest, source) \
objc_copyStruct(&dest, &source, sizeof(__typeof__(source)), YES, NO)

// non atomic
#define NonatomicRetainedSetToFrom(a, b) do{if(a!=b){[a release];a=[b retain];}}while(0)
#define NonatomicCopySetToFrom(a, b) do{if(a!=b){[a release];a=[b copy];}}while(0)

// ====================================================

/* Examples
- (NSRect)someRect
{
    NSRect result;
    AtomicStructToFrom(result, someRect);
    return result;
}

- (void)setSomeRect:(NSRect)aRect
{
    AtomicStructToFrom(someRect, aRect);
}

- (NSString *)someString
{
    return AtomicAutoreleasedGet(someString);
}

- (void)setSomeString:(NSString *)aString
{
    AtomicCopiedSetToFrom(someString, aString);
}

*/