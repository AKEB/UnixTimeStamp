#pragma once
#import <Foundation/Foundation.h>
#import "TSResponse.h"

@protocol TSPlatform<NSObject>
- (void)setPersistentFlagVal:(NSString*)key;
- (BOOL)getPersistentFlagVal:(NSString*)key;
- (BOOL) isFirstRun;
- (void) registerFirstRun;
- (NSString *)loadUuid;
- (NSMutableSet *)loadFiredEvents;
- (void)saveFiredEvents:(NSMutableSet *)firedEvents;
- (NSString *)getResolution;
- (NSString *)getManufacturer;
- (NSString *)getModel;
- (NSString *)getOs;
- (NSString *)getOsBuild;
- (NSString *)getLocale;
- (NSString *)getWifiMac;
- (NSString *)getAppName;
- (NSString *)getAppVersion;
- (NSString *)getPackageName;
- (TSResponse *)request:(NSString *)url data:(NSString *)data method:(NSString *)method timeout_ms:(int)timeout_ms;
- (NSString *)getComputerGUID;
- (NSString *)getBundleIdentifier;
- (NSString *)getBundleShortVersion;
@end
