//
//  NTObjcRuntimeTools.m
//  CocoatechCore
//
//  Created by Steve Gehrman on 11/10/08.
//  Copyright 2008 Cocoatech. All rights reserved.
//

#import "NTObjcRuntimeTools.h"
#import <objc/objc-runtime.h>

static IMP NTReplaceMethodImplementation(Class aClass, SEL oldSelector, IMP newImp);
static IMP NTReplaceClassMethodImplementation(Class aClass, SEL oldSelector, IMP newImp);

@implementation NTObjcRuntimeTools

+ (IMP)replaceClassMethodImplementationWithSelectorOnClass:(Class)oldClass
											  oldSelector:(SEL)oldSelector
											   newClass:(Class)newClass 
											newSelector:(SEL)newSelector;
{	
    Method newMethod = class_getClassMethod(newClass, newSelector);
	
    return NTReplaceClassMethodImplementation(oldClass, oldSelector, method_getImplementation(newMethod));
}

+ (IMP)replaceMethodImplementationWithSelectorOnClass:(Class)oldClass
										  oldSelector:(SEL)oldSelector
										  newClass:(Class)newClass 
										  newSelector:(SEL)newSelector;
{	
    Method newMethod = class_getInstanceMethod(newClass, newSelector);
	
    return NTReplaceMethodImplementation(oldClass, oldSelector, method_getImplementation(newMethod));
}

@end

static BOOL NTRegisterMethod(IMP imp, Class cls, const char *types, SEL name)
{
    return class_addMethod(cls, name, imp, types);
}

static IMP NTReplaceClassMethodImplementation(Class aClass, SEL oldSelector, IMP newImp)
{
    Method localMethod, superMethod;
    IMP oldImp = NULL;
    extern void _objc_flush_caches(Class);
	
    if ((localMethod = class_getClassMethod(aClass, oldSelector)))
	{
		oldImp = method_getImplementation(localMethod);
        Class superCls = class_getSuperclass(aClass);
		superMethod = superCls ? class_getInstanceMethod(superCls, oldSelector) : NULL;
		
		if (superMethod == localMethod)
		{
			// We are inheriting this method from the superclass.  We do *not* want to clobber the superclass's Method as that would replace the implementation on a greater scope than the caller wanted.  In this case, install a new method at this class and return the superclass's implementation as the old implementation (which it is).
			NTRegisterMethod(newImp, aClass, method_getTypeEncoding(localMethod), oldSelector);
		} 
		else 
		{
			// Replace the method in place
            method_setImplementation(localMethod, newImp);
		}
	}
	
    return oldImp;
}

static IMP NTReplaceMethodImplementation(Class aClass, SEL oldSelector, IMP newImp)
{
    Method localMethod, superMethod;
    IMP oldImp = NULL;
    extern void _objc_flush_caches(Class);
	
    if ((localMethod = class_getInstanceMethod(aClass, oldSelector))) 
	{
		oldImp = method_getImplementation(localMethod);
        Class superCls = class_getSuperclass(aClass);
		superMethod = superCls ? class_getInstanceMethod(superCls, oldSelector) : NULL;
		
		if (superMethod == localMethod) {
			// We are inheriting this method from the superclass.  We do *not* want to clobber the superclass's Method as that would replace the implementation on a greater scope than the caller wanted.  In this case, install a new method at this class and return the superclass's implementation as the old implementation (which it is).
			NTRegisterMethod(newImp, aClass, method_getTypeEncoding(localMethod), oldSelector);
		} else {
			// Replace the method in place
            method_setImplementation(localMethod, newImp);
		}
    }
	
    return oldImp;
}
