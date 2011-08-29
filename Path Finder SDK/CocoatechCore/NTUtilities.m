//
//  NTUtilities.m
//  CocoatechCore
//
//  Created by Steve Gehrman on Mon Dec 17 2001.
//  Copyright (c) 2001 CocoaTech. All rights reserved.
//

#import "NTUtilities.h"
#import "NSString-Utilities.h"
#import <AddressBook/AddressBook.h>
#import <sys/types.h>
#import <sys/sysctl.h>
#import <unistd.h>

#include <stdio.h>
#include <IOKit/IOKitLib.h>
#include <IOKit/network/IOEthernetInterface.h>
#include <IOKit/network/IONetworkInterface.h>
#include <IOKit/network/IOEthernetController.h>

// static methods
static kern_return_t FindEthernetInterfaces(io_iterator_t *matchingServices);
static kern_return_t GetMACAddress(io_iterator_t intfIterator, UInt8 *MACAddress, UInt8 bufferSize);

@implementation NTUtilities

+ (NSString*)OSVersionDescription;
{
    NSDictionary *systemVersion = [NSDictionary dictionaryWithContentsOfFile:@"/System/Library/CoreServices/SystemVersion.plist"];

    if (systemVersion != nil)
    {
        return [NSString stringWithFormat:@"%@ %@ (Build %@) %@",
            [systemVersion objectForKey:@"ProductName"],
            [systemVersion objectForKey:@"ProductVersion"],
            [systemVersion objectForKey:@"ProductBuildVersion"],
			(CFByteOrderGetCurrent() == CFByteOrderBigEndian) ? @"PPC" : @"i386"];
    }

    return @"Unknown";
}

+ (NSString*)OSVersionString;
{
    NSDictionary *systemVersion = [NSDictionary dictionaryWithContentsOfFile:@"/System/Library/CoreServices/SystemVersion.plist"];
	
	return [systemVersion objectForKey:@"ProductVersion"];
}

+ (unsigned)versionStringToInt:(NSString*)version;
{
	// 10.5, 10.4.10, 10.4.1
	NSArray* components = [version componentsSeparatedByString:@"."];
	
	if ([components count] == 2)  // 10.4 add a zero to end to be 10.4.0
		components = [components arrayByAddingObject:@"0"];
	
	NSEnumerator *enumerator = [components reverseObjectEnumerator];
	NSString* digit;
	unsigned result = 0;
	unsigned multiplier = 1;
	
	while (digit = [enumerator nextObject])
	{
		result += (multiplier * [digit intValue]);
		
		multiplier *= 100;  // 100, not 10 as expected. 10.4.10 = 100410
	}
	
	return result;
}

+ (NSNumber*)applicationVersionAsNumber;
{
	NSString* s = [self applicationVersion];
		
	return [NSNumber numberWithInt:[self versionStringToInt:s]];
}

+ (NSString*)applicationVersion;
{
    NSBundle *bundle = [NSBundle mainBundle];
	
    if (bundle)
    {
        NSDictionary *dict = [bundle infoDictionary];
        if (dict)
        {
            NSString* version = [dict objectForKey:@"CFBundleShortVersionString"];
			
            if (version && [version length])
                return version;
        }
    }
	
    return @"?.??";
}

+ (NSString*)applicationBuild;
{
    NSBundle *bundle = [NSBundle mainBundle];
	
    if (bundle)
    {
        NSDictionary *dict = [bundle infoDictionary];
        if (dict)
        {
            NSString* version = [dict objectForKey:@"CFBundleVersion"];
			
            if (version && [version length])
                return version;
        }
    }
	
    return @"";
}

// 0x1047 == 10.4.7
+ (BOOL)osVersionIsAtLeast:(unsigned)osVersion;
{
	// cache code
	static SInt32 code=0;
	if (!code)
		Gestalt(gestaltSystemVersion, &code);

	return (code >= osVersion);
}

+ (NSString *)computerName
{
	CFStringRef name;
	NSString *computerName = [NTLocalizedString localize:@"Computer"];
	
	name = SCDynamicStoreCopyComputerName(NULL,NULL);
	if (name)
	{
		computerName=[NSString stringWithString:(NSString*)name];
		CFRelease(name);
	}
	
	return computerName;
}

+ (NSString*)applicationName;
{
    NSDictionary* dict = [[NSBundle mainBundle] infoDictionary];
    id result;

    result = [dict objectForKey:@"CFBundleName"];

    if (!result)
        result = [[NSProcessInfo processInfo] processName];

    if (result)
        return result;

    return @"";
}

+ (NSString*)applicationBundleIdentifier;
{
	return [[NSBundle mainBundle] bundleIdentifier];
}

+ (NSString*)applicationCreatorCode;
{
	NSString* result=nil;
	ProcessSerialNumber psn;
	
	OSErr err = MacGetCurrentProcess(&psn);
	if (!err)
	{
		CFDictionaryRef dictRef = ProcessInformationCopyDictionary(&psn, kProcessDictionaryIncludeAllInformationMask);
		if (dictRef)
		{
			NSDictionary* dict = [[(NSDictionary*)dictRef copy] autorelease];
			
			if (dict)
				result = [NSString stringWithString:[dict objectForKey:@"FileCreator"]];
			
			CFRelease(dictRef);
		}
	}
	
	return result;
}

+ (NSString*)usersEmailAddress;
{
	NSString* emailAddress=nil;
	
	// look in address book
	ABPerson *me = [[ABAddressBook sharedAddressBook] me];
	if (me)
	{
		// Email Address
		ABMultiValue *emailAddresses = [me valueForProperty:kABEmailProperty];				
		unsigned valueIndex = [emailAddresses indexForIdentifier:[emailAddresses primaryIdentifier]];
		
		emailAddress = [emailAddresses valueAtIndex:valueIndex];
	}
		
	return emailAddress;
}

+ (BOOL)runningOnTiger;
{
	static int shared=-1;

	if (shared == -1)
		shared = ([self osVersionIsAtLeast:0x1040] && ![self runningOnLeopard]) ? 1:0;

	return (shared == 1);
}

+ (BOOL)runningOnLeopard;
{
	static int shared=-1;
	
	if (shared == -1)
		shared = ([self osVersionIsAtLeast:0x1050]) ? 1:0;
	
	return (shared == 1);
}

+ (BOOL)runningOnSnowLeopard;
{
	static int shared=-1;
	
	if (shared == -1)
		shared = ([self osVersionIsAtLeast:0x1060]) ? 1:0;
	
	return (shared == 1);
}

+ (NSString*)intToString:(unsigned int)intValue
{
	NSString* result = (NSString*) UTCreateStringForOSType((OSType) intValue);
	
	return [result autorelease];
}

+ (unsigned int)stringToInt:(NSString*)stringValue
{
	OSType result=0;

	// pad with spaces if less than 4
	int len = [stringValue length];
	if (len > 0)
	{
		while (len < 4)
		{	
			stringValue = [stringValue stringByAppendingString:@" "];
			
			len = [stringValue length];
		}
		
		result = UTGetOSTypeFromString((CFStringRef) stringValue);
	}
	
    return result;
}

#define kCGLRendererGeForceFXID      0x00022400 /* also for GeForce 6xxx, 7xxx */
+ (BOOL)compatibleWithLayerBackedViews;
{
	static int result=-1;
	if (result == -1)
	{
		result = 1;
		
		// hidden default to toggle this shait
		if ([[NSUserDefaults standardUserDefaults] boolForKey:@"disableCoreAnimation"])
			result = 0;
		else
		{
			NSOpenGLPixelFormatAttribute attributes[] = {NSOpenGLPFARendererID, kCGLRendererGeForceFXID, 0};
			NSOpenGLPixelFormat *pixelFormat = [[[NSOpenGLPixelFormat alloc] initWithAttributes:attributes] autorelease];
			if (pixelFormat != nil) 
			{
				// System has a card in that class.
				result = 0;
			}
		}		
	}
	
	return (result == 1);
}

+ (NSString*)MACAddress;
{
	static NSString* shared=nil;
	
	if (!shared)
	{
		kern_return_t	kernResult = KERN_SUCCESS; // on PowerPC this is an int (4 bytes)
		
		io_iterator_t	intfIterator;
		UInt8			MACAddress[kIOEthernetAddressSize];
		
		kernResult = FindEthernetInterfaces(&intfIterator);
		
		if (KERN_SUCCESS != kernResult) {
			NSLog(@"FindEthernetInterfaces returned 0x%08x\n", kernResult);
		}
		else {
			kernResult = GetMACAddress(intfIterator, MACAddress, sizeof(MACAddress));
			
			if (KERN_SUCCESS != kernResult) {
				NSLog(@"GetMACAddress returned 0x%08x\n", kernResult);
			}
			else {
				shared = [NSString stringWithFormat:@"%02x:%02x:%02x:%02x:%02x:%02x",
					MACAddress[0], MACAddress[1], MACAddress[2], MACAddress[3], MACAddress[4], MACAddress[5]];
			}
		}
		
		(void) IOObjectRelease(intfIterator);	// Release the iterator.
		
		// retain it
		shared = [shared retain];
	}
	
    return shared;
}

+ (NSString*)ipAddress:(NSString**)outInterface;
{
	NSString* interface = nil;
	NSString* ipAddress = nil;
    NSArray *interfaces=nil;
	CFPropertyListRef dictRef;
	
    SCDynamicStoreRef store = SCDynamicStoreCreate(NULL, (CFStringRef)[[NSProcessInfo processInfo] processName], NULL, NULL);
	if (store)
	{
		CFStringRef interfacesKey = SCDynamicStoreKeyCreateNetworkInterface(NULL, kSCDynamicStoreDomainState);
		if (interfacesKey)
		{
			dictRef = SCDynamicStoreCopyValue(store, interfacesKey);
			
			if (dictRef)
			{
				interfaces = [[[(NSDictionary*)dictRef objectForKey:(NSString *)kSCDynamicStorePropNetInterfaces] retain] autorelease];
				CFRelease(dictRef);
			}
			
			CFRelease(interfacesKey);
		}
				
		for (NSString* interfaceName in interfaces) 
		{			
			CFStringRef stringRef = SCDynamicStoreKeyCreateNetworkInterfaceEntity(NULL, kSCDynamicStoreDomainState, (CFStringRef)interfaceName, kSCEntNetLink);
			NSString* linkKey = nil;
			
			if (stringRef)
			{
				linkKey = [NSString stringWithString:(NSString*)stringRef];
				CFRelease(stringRef);
			}
				
			NSNumber *activeValue = nil;
			dictRef = SCDynamicStoreCopyValue(store, (CFStringRef)linkKey);
			if (dictRef)
			{
				activeValue = [[[(NSDictionary*)dictRef objectForKey:(NSString *)kSCPropNetLinkActive] retain] autorelease];
				CFRelease(dictRef);
			}
			
			if ([activeValue boolValue])
			{			
				NSArray* ipAddresses = nil;

				stringRef = SCDynamicStoreKeyCreateNetworkInterfaceEntity(NULL, kSCDynamicStoreDomainState, (CFStringRef)interfaceName, kSCEntNetIPv4);
				
				if (stringRef)
				{
					dictRef = SCDynamicStoreCopyValue(store, stringRef);
					
					if (dictRef)
					{
						ipAddresses = [[[(NSDictionary*)dictRef objectForKey:(NSString *)kSCPropNetIPv4Addresses] retain] autorelease];
						
						CFRelease(dictRef);
					}
					
					CFRelease(stringRef);
				}
				
				if ([ipAddresses count] != 0)
					ipAddress = [ipAddresses objectAtIndex:0];
				
				interface = interfaceName;
				break;
			}
		}
		
		CFRelease(store);
	}
	
	if (!interface)
		interface = @"en0";
	if (!ipAddress)
		ipAddress = @"127.0.0.1";
	
	if (outInterface)
		*outInterface = interface;
	
	return ipAddress;
}

+ (void)moveToTrash:(NSString*)path;
{
	NSInteger tag=0;
	
	if ([[NSFileManager defaultManager] fileExistsAtPath:path])
	{		
		[[NSWorkspace sharedWorkspace] performFileOperation:NSWorkspaceRecycleOperation
													 source:[path stringByDeletingLastPathComponent] 
												destination:@"" 
													  files:[NSArray arrayWithObject:[path lastPathComponent]] 
														tag:&tag];	
		
		if (tag < 0)
			NSLog(@"move to trash failed: %d path: %@", tag, path);
	}
}

+ (void)moveContentsToTrash:(NSString*)folder;
{
	NSEnumerator *enumerator = [[[NSFileManager defaultManager] contentsOfDirectoryAtPath:folder error:nil] objectEnumerator];
	NSString* name;
	
	while (name = [enumerator nextObject])
		[self moveToTrash:[folder stringByAppendingPathComponent:name]];
}

+ (BOOL)machineIdleForMinutes:(int)inMinutes;
{
	/*
	 * Uses IOKit to figure out the idle time of the system. The idle time
	 * is stored as a property of the IOHIDSystem class; the name is
	 * HIDIdleTime. Stored as a 64-bit int, measured in ns. 
	 */
	
	BOOL result = NO;
	mach_port_t masterPort;
	io_iterator_t iter;
	
	IOMasterPort(MACH_PORT_NULL, &masterPort);
	
	/* Get IOHIDSystem */
	IOServiceGetMatchingServices(masterPort,
								 IOServiceMatching("IOHIDSystem"),
								 &iter);
	if (iter) 
	{
		io_registry_entry_t curObj;
		
		curObj = IOIteratorNext(iter);
		
		if (curObj) 
		{
			CFMutableDictionaryRef properties = 0;
			
			if (IORegistryEntryCreateCFProperties(curObj, &properties, kCFAllocatorDefault, 0) == KERN_SUCCESS && properties)
			{
				CFTypeRef obj = CFDictionaryGetValue(properties, CFSTR("HIDIdleTime"));
				CFRetain(obj);
				
				if (obj)
				{
					uint64_t timeInNanoSeconds=0;
					
					CFTypeID type = CFGetTypeID(obj);
					if (type == CFDataGetTypeID())
					{
						CFDataGetBytes((CFDataRef) obj,
									   CFRangeMake(0, sizeof(timeInNanoSeconds)), 
									   (UInt8*) &timeInNanoSeconds);   
					}  
					else if (type == CFNumberGetTypeID())
					{
						CFNumberGetValue((CFNumberRef)obj,
										 kCFNumberSInt64Type,
										 &timeInNanoSeconds);
					}
					else
						NSLog(@"%d: unsupported typen", (int)type);
					
					CFRelease(obj);    
					
					// essentially divides by 10^9
					// timeInNanoSeconds /= 1000000000;
					// converts to seconds
					timeInNanoSeconds >>= 30;
					
					if (timeInNanoSeconds > inMinutes*60)  
						result = YES;
				}
				else 
					NSLog(@"Can't find idle timen");
				
				CFRelease((CFTypeRef)properties);
			}
			
			// release curObj
			IOObjectRelease(curObj);
		}
		
		// release iterator
		IOObjectRelease(iter);
	}
	
	return result;
}

@end

void NSLogRect(NSString* title, NSRect rect)
{
    NSLog(@"%@: %@", title, NSStringFromRect(rect));
}

void NSLogErr(NSString* title, int err)
{
	NSLog(@"%@: %d, %s, %s", title, err, GetMacOSStatusErrorString(err), GetMacOSStatusCommentString(err));
}

NSString* NSErrorString(OSStatus err)
{	
	const char* errStr;
	NSString *result = @"";
	
	errStr = GetMacOSStatusErrorString(err);
	if (errStr && strlen(errStr))
		result = [result stringByAppendingString:[NSString stringWithFormat:@"%s.  ", errStr]];
	
	errStr = GetMacOSStatusCommentString(err);
	if (errStr && strlen(errStr))
		result = [result stringByAppendingString:[NSString stringWithFormat:@"%s.", errStr]];
	
	return result;
}

// Use this to easily disable an NSLog
void NSLogNULL(NSString *format, ...)
{
    va_list vargs;
	
    va_start(vargs, format);
	
	// NSLogv(format, vargs);
	
	va_end(vargs);
}

// Returns an iterator containing the primary (built-in) Ethernet interface. The caller is responsible for
// releasing the iterator after the caller is done with it.
static kern_return_t FindEthernetInterfaces(io_iterator_t *matchingServices)
{
    kern_return_t		kernResult; 
    CFMutableDictionaryRef	matchingDict;
    CFMutableDictionaryRef	propertyMatchDict;
    
    // Ethernet interfaces are instances of class kIOEthernetInterfaceClass. 
    // IOServiceMatching is a convenience function to create a dictionary with the key kIOProviderClassKey and 
    // the specified value.
    matchingDict = IOServiceMatching(kIOEthernetInterfaceClass);
	
    // Note that another option here would be:
    // matchingDict = IOBSDMatching("en0");
	
    if (NULL == matchingDict) {
        NSLog(@"IOServiceMatching returned a NULL dictionary.\n");
    }
    else {
        // Each IONetworkInterface object has a Boolean property with the key kIOPrimaryInterface. Only the
        // primary (built-in) interface has this property set to TRUE.
        
        // IOServiceGetMatchingServices uses the default matching criteria defined by IOService. This considers
        // only the following properties plus any family-specific matching in this order of precedence 
        // (see IOService::passiveMatch):
        //
        // kIOProviderClassKey (IOServiceMatching)
        // kIONameMatchKey (IOServiceNameMatching)
        // kIOPropertyMatchKey
        // kIOPathMatchKey
        // kIOMatchedServiceCountKey
        // family-specific matching
        // kIOBSDNameKey (IOBSDNameMatching)
        // kIOLocationMatchKey
        
        // The IONetworkingFamily does not define any family-specific matching. This means that in            
        // order to have IOServiceGetMatchingServices consider the kIOPrimaryInterface property, we must
        // add that property to a separate dictionary and then add that to our matching dictionary
        // specifying kIOPropertyMatchKey.
		
        propertyMatchDict = CFDictionaryCreateMutable(kCFAllocatorDefault, 0,
													  &kCFTypeDictionaryKeyCallBacks,
													  &kCFTypeDictionaryValueCallBacks);
		
        if (NULL == propertyMatchDict) {
            NSLog(@"CFDictionaryCreateMutable returned a NULL dictionary.\n");
        }
        else {
            // Set the value in the dictionary of the property with the given key, or add the key 
            // to the dictionary if it doesn't exist. This call retains the value object passed in.
            CFDictionarySetValue(propertyMatchDict, CFSTR(kIOPrimaryInterface), kCFBooleanTrue); 
            
            // Now add the dictionary containing the matching value for kIOPrimaryInterface to our main
            // matching dictionary. This call will retain propertyMatchDict, so we can release our reference 
            // on propertyMatchDict after adding it to matchingDict.
            CFDictionarySetValue(matchingDict, CFSTR(kIOPropertyMatchKey), propertyMatchDict);
            CFRelease(propertyMatchDict);
        }
    }
    
    // IOServiceGetMatchingServices retains the returned iterator, so release the iterator when we're done with it.
    // IOServiceGetMatchingServices also consumes a reference on the matching dictionary so we don't need to release
    // the dictionary explicitly.
    kernResult = IOServiceGetMatchingServices(kIOMasterPortDefault, matchingDict, matchingServices);    
    if (KERN_SUCCESS != kernResult) {
        NSLog(@"IOServiceGetMatchingServices returned 0x%08x\n", kernResult);
    }
	
    return kernResult;
}

// Given an iterator across a set of Ethernet interfaces, return the MAC address of the last one.
// If no interfaces are found the MAC address is set to an empty string.
// In this sample the iterator should contain just the primary interface.
static kern_return_t GetMACAddress(io_iterator_t intfIterator, UInt8 *MACAddress, UInt8 bufferSize)
{
    io_object_t		intfService;
    io_object_t		controllerService;
    kern_return_t	kernResult = KERN_FAILURE;
    
    // Make sure the caller provided enough buffer space. Protect against buffer overflow problems.
	if (bufferSize < kIOEthernetAddressSize) {
		return kernResult;
	}
	
	// Initialize the returned address
    bzero(MACAddress, bufferSize);
    
    // IOIteratorNext retains the returned object, so release it when we're done with it.
    while (intfService = IOIteratorNext(intfIterator))
    {
        CFTypeRef	MACAddressAsCFData;        
		
        // IONetworkControllers can't be found directly by the IOServiceGetMatchingServices call, 
        // since they are hardware nubs and do not participate in driver matching. In other words,
        // registerService() is never called on them. So we've found the IONetworkInterface and will 
        // get its parent controller by asking for it specifically.
        
        // IORegistryEntryGetParentEntry retains the returned object, so release it when we're done with it.
        kernResult = IORegistryEntryGetParentEntry(intfService,
												   kIOServicePlane,
												   &controllerService);
		
        if (KERN_SUCCESS != kernResult) {
            NSLog(@"IORegistryEntryGetParentEntry returned 0x%08x\n", kernResult);
        }
        else {
            // Retrieve the MAC address property from the I/O Registry in the form of a CFData
            MACAddressAsCFData = IORegistryEntryCreateCFProperty(controllerService,
																 CFSTR(kIOMACAddress),
																 kCFAllocatorDefault,
																 0);
            if (MACAddressAsCFData) {
                CFShow(MACAddressAsCFData); // for display purposes only; output goes to stderr
                
                // Get the raw bytes of the MAC address from the CFData
                CFDataGetBytes(MACAddressAsCFData, CFRangeMake(0, kIOEthernetAddressSize), MACAddress);
                CFRelease(MACAddressAsCFData);
            }
			
            // Done with the parent Ethernet controller object so we release it.
            (void) IOObjectRelease(controllerService);
        }
        
        // Done with the Ethernet interface object so we release it.
        (void) IOObjectRelease(intfService);
    }
	
    return kernResult;
}

@implementation NSObject (LEAKOK)

// #define LEAKOK(x) [[x autorelease] hold]
- (id)hold;
{
	return [self retain];
}

@end


