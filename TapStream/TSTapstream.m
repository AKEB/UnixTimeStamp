
#import "TSSafariViewControllerDelegate.h"
#import "TSTapstream.h"
#import "TSHelpers.h"
#import "TSPlatformImpl.h"
#import "TSCoreListenerImpl.h"
#import "TSAppEventSourceImpl.h"
#if TEST_IOS || TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
#import <UIKit/UIKit.h>
#endif


@interface TSDelegateImpl : NSObject<TSDelegate> {
	TSTapstream *ts;
}
@property(nonatomic, STRONG_OR_RETAIN) TSTapstream *ts;
- (id)initWithTapstream:(TSTapstream *)ts;
- (int)getDelay;
- (void)setDelay:(int)delay;
- (bool)isRetryAllowed;
@end
// DelegateImpl comes at the end of the file so it can access a private property of the Tapstream interface



static TSTapstream *instance = nil;


@interface TSTapstream()

@property(nonatomic, STRONG_OR_RETAIN) TSCore *core;

- (id)initWithAccountName:(NSString *)accountName developerSecret:(NSString *)developerSecret config:(TSConfig *)config;

// Word-of-mouth delegate
- (void)showedOffer:(NSUInteger)offerId;
- (void)showedSharing:(NSUInteger)offerId;
- (void)completedShare:(NSUInteger)offerId socialMedium:(NSString *)medium;

@end


@implementation TSTapstream

@synthesize core;

+ (void)createWithAccountName:(NSString *)accountName developerSecret:(NSString *)developerSecret config:(TSConfig *)config
{
	@synchronized(self)
	{
		if(instance == nil)
		{
			instance = [[TSTapstream alloc] initWithAccountName:accountName developerSecret:developerSecret config:config];
		}
		else
		{
			[TSLogging logAtLevel:kTSLoggingWarn format:@"Tapstream Warning: Tapstream already instantiated, it cannot be re-created."];
		}
	}
}

+ (id)instance
{
	@synchronized(self)
	{
		NSAssert(instance != nil, @"You must first call +createWithAccountName:developerSecret:config:");
		return instance;
	}
}

+ (id)wordOfMouthController
{
    return AUTORELEASE(((TSTapstream *)[TSTapstream instance])->wordOfMouthController);
}

- (id)initWithAccountName:(NSString *)accountName developerSecret:(NSString *)developerSecret config:(TSConfig *)config
{
	if((self = [super init]) != nil)
	{
		del = [[TSDelegateImpl alloc] initWithTapstream:self];
		platform = [[TSPlatformImpl alloc] init];
		listener = [[TSCoreListenerImpl alloc] init];
		appEventSource = [[TSAppEventSourceImpl alloc] init];

		self.core = AUTORELEASE([[TSCore alloc] initWithDelegate:del
			platform:platform
			listener:listener
			appEventSource:appEventSource
			accountName:accountName
			developerSecret:developerSecret
			config:config]);

		[core start];
		if(config.attemptCookieMatch){
			[self registerCookieMatchObserver];
		}
        
        // Dynamically instantiate TSWordOfMouthController, if the source files have been
        // included in the developer's project.
        Class wordOfMouthControllerClass = NSClassFromString(@"TSWordOfMouthController");
        if(wordOfMouthControllerClass)
        {
            id inst = [wordOfMouthControllerClass alloc];
            SEL sel = NSSelectorFromString(@"initWithSecret:uuid:bundle:");
            IMP imp = [inst methodForSelector:sel];
            wordOfMouthController = ((id (*)(id, SEL, NSString *, NSString *, NSString *))imp)(inst, sel, developerSecret, [platform loadUuid], [platform getBundleIdentifier]);
            
            sel = NSSelectorFromString(@"setDelegate:");
            imp = [wordOfMouthController methodForSelector:sel];
            ((void (*)(id, SEL, id))imp)(wordOfMouthController, sel, self);
        }
	}
	return self;
}

- (void)dealloc
{
	RELEASE(del);
	RELEASE(platform);
	RELEASE(listener);
	RELEASE(appEventSource);
    RELEASE(wordOfMouthController);
	RELEASE(core);
	SUPER_DEALLOC;
}

#if TEST_IOS || TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
- (void)registerCookieMatchObserver
{
	if([platform isFirstRun]){
		[[NSNotificationCenter defaultCenter]
		 addObserver:self
			selector:@selector(handleNotification:)
		 name:UIApplicationDidBecomeActiveNotification
		 object:nil];
	}else{
		// Already sent, let core know
		[core fireCookieMatch];
	}
}

- (void)handleNotification:(NSNotification*)notification
{
	[[NSNotificationCenter defaultCenter]
	 removeObserver:self
	 name:UIApplicationDidBecomeActiveNotification
	 object:nil];

	UIViewController* rootViewController = [UIApplication sharedApplication].delegate.window.rootViewController;
	[self fireCookieMatch:rootViewController completion:nil];
}

- (void)fireCookieMatch:(UIViewController*)controller completion:(void(^)(void))completion
{
	if ([platform isFirstRun]){ // Only fires once.
		NSURL* url = [core getCookieMatchURL];

		[TSSafariViewControllerDelegate
		 presentSafariViewControllerWithURLAndCompletion:url
		 completion:^{
			if(completion != nil){
				completion();
			}
			[core fireCookieMatch];
		  }];
	}
}
#else
- (void)registerCookieMatchObserver {}
#endif

- (void)fireEvent:(TSEvent *)event
{
	[core fireEvent:event];
}

- (void)fireHit:(TSHit *)hit completion:(void(^)(TSResponse *))completion
{
	[core fireHit:hit completion:completion];
}

- (void)getConversionData:(void(^)(NSData *))completion
{
	[core getConversionData:completion];
}


- (NSData*)getConversionDataBlocking:(int)timeout_ms;
{
	return [core getConversionDataBlocking:timeout_ms];
}


// Word-of-mouth delegate
- (void)showedOffer:(NSUInteger)offerId
{
    NSString *appName = [platform getAppName];
    TSEvent *event = [TSEvent eventWithName:[NSString stringWithFormat:@"%@-%@-showed-offer_%u", appName ? appName : @"", [kTSPlatform lowercaseString], (unsigned int)offerId] oneTimeOnly:NO];
    [self fireEvent:event];
}

- (void)dismissedOffer:(BOOL)accepted
{
}

- (void)showedSharing:(NSUInteger)offerId
{
    NSString *appName = [platform getAppName];
    TSEvent *event = [TSEvent eventWithName:[NSString stringWithFormat:@"%@-%@-showed-sharing_%u", appName ? appName : @"", [kTSPlatform lowercaseString], (unsigned int)offerId] oneTimeOnly:NO];
    [self fireEvent:event];
}

- (void)dismissedSharing
{
}

- (void)completedShare:(NSUInteger)offerId socialMedium:(NSString *)medium
{
    NSString *appName = [platform getAppName];
    TSEvent *event = [TSEvent eventWithName:[NSString stringWithFormat:@"%@-%@-sharing-completed_%u", appName ? appName : @"", [kTSPlatform lowercaseString], (unsigned int)offerId] oneTimeOnly:NO];
    [event addValue:medium forKey:@"medium"];
    [self fireEvent:event];
}

@end





@implementation TSDelegateImpl
@synthesize ts;

- (id)initWithTapstream:(TSTapstream *)tsVal
{
	if((self = [super init]) != nil)
	{
		self.ts = tsVal;
	}
	return self;
}

- (void)dealloc
{
	RELEASE(ts);
	SUPER_DEALLOC;
}

- (int)getDelay
{
	return [ts.core getDelay];
}

- (void)setDelay:(int)delay
{
}

- (bool)isRetryAllowed
{
	return true;
}
@end


