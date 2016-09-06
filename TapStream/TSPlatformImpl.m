#import "TSPlatformImpl.h"
#import <sys/types.h>
#import <sys/sysctl.h>
#import <sys/socket.h>
#import <net/if.h>
#import <net/if_dl.h>

#if TEST_IOS || TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
#import <UIKit/UIKit.h>
#else
#import <AppKit/AppKit.h>
#import <IOKit/IOKitLib.h>
#endif

#import "TSHelpers.h"


#define kTSFiredEventsKey @"__tapstream_fired_events"
#define kTSUUIDKey @"__tapstream_uuid"
#define kTSHasRunKey @"__tapstream_has_run"

@implementation TSPlatformImpl

- (void)setPersistentFlagVal:(NSString*)key
{
	[[NSUserDefaults standardUserDefaults] setBool:true forKey:key];
}

- (BOOL)getPersistentFlagVal:(NSString*)key
{
	BOOL val = [[NSUserDefaults standardUserDefaults] boolForKey:key];
	return val;
}

- (BOOL) isFirstRun
{
	return ![self getPersistentFlagVal:kTSHasRunKey] || true;
}

- (void) registerFirstRun
{
	[self setPersistentFlagVal:kTSHasRunKey];
}

- (NSString *)loadUuid
{
	NSString *uuid = [[NSUserDefaults standardUserDefaults] objectForKey:kTSUUIDKey];
	if(!uuid)
	{
		CFUUIDRef uuidObject = CFUUIDCreate(kCFAllocatorDefault); 
		uuid = AUTORELEASE((BRIDGE_TRANSFER NSString *)CFUUIDCreateString(kCFAllocatorDefault, uuidObject));
		CFRelease(uuidObject);
		[[NSUserDefaults standardUserDefaults] setObject:uuid forKey:kTSUUIDKey];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
	return uuid;
}

- (NSMutableSet *)loadFiredEvents
{
	NSArray *fireList = [[NSUserDefaults standardUserDefaults] objectForKey:kTSFiredEventsKey];
	if(fireList)
	{
		return [NSMutableSet setWithArray:fireList];
	}
	return [NSMutableSet setWithCapacity:32];
}

- (void)saveFiredEvents:(NSMutableSet *)firedEvents
{
	[[NSUserDefaults standardUserDefaults] setObject:[firedEvents allObjects] forKey:kTSFiredEventsKey];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)getResolution
{
#if TEST_IOS || TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
	CGRect frame = [UIScreen mainScreen].bounds;
	float scale = (float)[UIScreen mainScreen].scale;
	return [NSString stringWithFormat:@"%dx%d", (int)(frame.size.width * scale), (int)(frame.size.height * scale)];
#else
	NSRect frame = [NSScreen mainScreen].frame;
	return [NSString stringWithFormat:@"%dx%d", (int)(frame.size.width), (int)(frame.size.height)];
#endif
}

- (NSString *)getManufacturer
{
	return @"Apple";
}

- (NSString *)getModel
{
	NSString *machine = [self systemInfoByName:@"hw.machine" default:@""];
#if TEST_IOS || TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
	return machine;
#else
        NSString *model = [self systemInfoByName:@"hw.model" default:@""];
	if(model != nil)
	{
		if(machine != nil)
		{
			model = [NSString stringWithFormat:@"%@ %@", model, machine];
		}
		return model;
	}
	return machine;
#endif
}

- (NSString *)getOsBuild
{
#if TARGET_IPHONE_SIMULATOR	
	return nil;  // Simulators lie.
#else
	return [self systemInfoByName:@"kern.osversion" default:@""];
#endif
}

- (NSString *)getOs
{
#if TEST_IOS || TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
	return [NSString stringWithFormat:@"%@ %@", [[UIDevice currentDevice] systemName], [[UIDevice currentDevice] systemVersion]];
#else

	// This "Gestalt" method is deprecated since OSX 10.8
	#if 0
	SInt32 major, minor, bugfix;
	Gestalt(gestaltSystemVersionMajor, &major);
	Gestalt(gestaltSystemVersionMinor, &minor);
	Gestalt(gestaltSystemVersionBugFix, &bugfix);
	NSString *version = [NSString stringWithFormat:@"%d.%d.%d", major, minor, bugfix];
	return [NSString stringWithFormat:@"Mac OS X %@", version];
	#else

	NSDictionary *sv = [NSDictionary dictionaryWithContentsOfFile:@"/System/Library/CoreServices/SystemVersion.plist"];
	return [sv objectForKey:@"ProductVersion"];
	
	#endif
#endif
}

- (NSString *)getLocale
{
	return [[NSLocale currentLocale] localeIdentifier];
}

- (NSString *)getWifiMac
{
	// Setup the management Information Base (mib)
	int mgmtInfoBase[6];
	mgmtInfoBase[0] = CTL_NET;        // Request network subsystem
	mgmtInfoBase[1] = AF_ROUTE;       // Routing table info
	mgmtInfoBase[2] = 0;              
	mgmtInfoBase[3] = AF_LINK;        // Request link layer information
	mgmtInfoBase[4] = NET_RT_IFLIST;  // Request all configured interfaces

	// With all configured interfaces requested, get handle index
	if((mgmtInfoBase[5] = if_nametoindex("en0")) == 0)
	{
		return nil;
	}

	// Get the size of the data available (store in len)
	size_t length;
	if(sysctl(mgmtInfoBase, 6, NULL, &length, NULL, 0) < 0)
	{
		return nil;
	}
		
	// Alloc memory based on above call
	char *msgBuffer = malloc(length);
	if(msgBuffer == NULL)
	{
		return nil;
	}

	// Get system information, store in buffer
	if(sysctl(mgmtInfoBase, 6, msgBuffer, &length, NULL, 0) < 0)
	{
		free(msgBuffer);
		return nil;
	}

	struct if_msghdr *interfaceMsgStruct = (struct if_msghdr *)msgBuffer;
	struct sockaddr_dl *socketStruct = (struct sockaddr_dl *) (interfaceMsgStruct + 1);

	unsigned char macAddress[6];
	memcpy(&macAddress, socketStruct->sdl_data + socketStruct->sdl_nlen, 6);
	NSString *macAddressString = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X", 
		macAddress[0], macAddress[1], macAddress[2],
		macAddress[3], macAddress[4], macAddress[5]];

	free(msgBuffer);
	return macAddressString;
}

- (NSString *)getAppName
{
	return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"];
}

- (NSString *)getAppVersion
{
	return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
}

- (NSString *)getPackageName
{
	return [[NSBundle mainBundle] bundleIdentifier];
}

- (TSResponse *)request:(NSString *)url data:(NSString *)data method:(NSString *)method timeout_ms:(int)timeout_ms
{
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
	[request setHTTPMethod:method];
	[request setTimeoutInterval:timeout_ms / 1000.];
	if(data != nil)
	{
		[request setHTTPBody:[data dataUsingEncoding:NSUTF8StringEncoding]];
	}

	NSError *error = nil;
	NSHTTPURLResponse *response = nil;
	NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
	if(responseData == nil || !response)
	{
		if(error != nil)
		{
			NSString *msg = [NSString stringWithFormat:@"%@", error];
			return AUTORELEASE([[TSResponse alloc] initWithStatus:-1 message:msg data:nil]);
		}
		return AUTORELEASE([[TSResponse alloc] initWithStatus:-1 message:@"Unknown" data:nil]);
	}
	return AUTORELEASE([[TSResponse alloc] initWithStatus:(int)response.statusCode message:[NSHTTPURLResponse localizedStringForStatusCode:response.statusCode] data:responseData]);
}

- (NSString *)systemInfoByName:(NSString *)name default:(NSString *)def
{
	size_t size;
	int result;
	result = sysctlbyname( [name UTF8String], NULL, &size, NULL, 0);
	if(result != 0){
		// Handle an error value
		[TSLogging logAtLevel:kTSLoggingWarn format:@"Tapstream Warning: Failed to retrieve size of system value %@ (Error code: %d)", name, errno];
		return def;
	}

	char *pBuffer = malloc(size);
	if(pBuffer == NULL)
	{
		[TSLogging logAtLevel:kTSLoggingWarn format:@"Tapstream warning: failed to retrieve system value %@ (malloc failed)", name];
		return def;
	}

	NSString* value;

	result = sysctlbyname( [name UTF8String], pBuffer, &size, NULL, 0);

	if(result == 0){
		value = [NSString stringWithUTF8String:pBuffer];
	}else{
		[TSLogging logAtLevel:kTSLoggingWarn format:@"Tapstream Warning: Failed to retrieve system value %@ (Error code: %d)", name, errno];
		value = def;
	}

	free( pBuffer );

	return value;
}

- (NSString *)getComputerGUID
{
#if TEST_IOS || TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
	// Only need this value on ios 7 and up (for grand unified receipt validation)
	if(floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1)
	{
		return [[[[UIDevice currentDevice] identifierForVendor] UUIDString] stringByReplacingOccurrencesOfString:@"-" withString:@""];
	}
	else
	{
		return @"";
	}
#else

	// Adapted from Listing 1-3
	// https://developer.apple.com/library/mac/releasenotes/General/ValidateAppStoreReceipt/Chapters/ValidateLocally.html
	//
	// Requires the project to link against the IOKit framework
	
	kern_return_t kernResult;
	mach_port_t masterPort;
	CFMutableDictionaryRef matchingDict;
	io_iterator_t iterator;
	io_object_t service;
	
	CFDataRef macAddress = nil;
	
	kernResult = IOMasterPort(MACH_PORT_NULL, &masterPort);
	if (kernResult != KERN_SUCCESS) {
		return @"";
	}
	
	matchingDict = IOBSDNameMatching(masterPort, 0, "en0");
	if (!matchingDict) {
		return @"";
	}
	
	kernResult = IOServiceGetMatchingServices(masterPort, matchingDict, &iterator);
	if (kernResult != KERN_SUCCESS) {
		return @"";
	}
	
	while((service = IOIteratorNext(iterator)) != 0) {
		io_object_t parentService;
		kernResult = IORegistryEntryGetParentEntry(service, kIOServicePlane, &parentService);
		if (kernResult == KERN_SUCCESS) {
			if (macAddress) CFRelease(macAddress);
			macAddress = (CFDataRef) IORegistryEntryCreateCFProperty(parentService, CFSTR("IOMACAddress"), kCFAllocatorDefault, 0);
			IOObjectRelease(parentService);
		}
		IOObjectRelease(service);
	}
	IOObjectRelease(iterator);
	
	if(macAddress) {
		NSMutableString *addr = [NSMutableString stringWithCapacity:32];
		const unsigned char *bytes = CFDataGetBytePtr(macAddress);
		long len = CFDataGetLength(macAddress);
		for(long i = 0; i < len; i++) {
			[addr appendFormat:@"%02x", bytes[i]];
		}
		CFRelease(macAddress);
		return addr;
	}
	return @"";
	
#endif
}

- (NSString *)getBundleIdentifier
{
	return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
}

- (NSString *)getBundleShortVersion
{
	return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
}


@end

