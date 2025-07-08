//
//  KochavaTracker (Cordova)
//
//  Copyright (c) 2013 - 2023 Kochava, Inc. All rights reserved.
//

#pragma mark - Import

#import <Cordova/CDV.h>
#import <KochavaTracker/KochavaTracker.h>

#pragma mark - Interface

@interface KochavaTrackerPlugin : CDVPlugin
    
#pragma mark - Methods

- (void)executeAdvancedInstruction:(nonnull CDVInvokedUrlCommand *)invokedUrlCommand;

- (void)setLogLevel:(nonnull CDVInvokedUrlCommand *)invokedUrlCommand;
      
- (void)setSleep:(nonnull CDVInvokedUrlCommand *)invokedUrlCommand;
    
- (void)setAppLimitAdTracking:(nonnull CDVInvokedUrlCommand *)invokedUrlCommand;
    
- (void)registerCustomDeviceIdentifier:(nonnull CDVInvokedUrlCommand *)invokedUrlCommand;

- (void)registerCustomStringValue:(nonnull CDVInvokedUrlCommand *)invokedUrlCommand;

- (void)registerCustomBoolValue:(nonnull CDVInvokedUrlCommand *)invokedUrlCommand;

- (void)registerCustomNumberValue:(nonnull CDVInvokedUrlCommand *)invokedUrlCommand;
    
- (void)registerIdentityLink:(nonnull CDVInvokedUrlCommand *)invokedUrlCommand;
    
- (void)enableAndroidInstantApps:(nonnull CDVInvokedUrlCommand *)invokedUrlCommand;
    
- (void)enableIosAppClips:(nonnull CDVInvokedUrlCommand *)invokedUrlCommand;

- (void)enableIosAtt:(nonnull CDVInvokedUrlCommand *)invokedUrlCommand;

- (void)setIosAttAuthorizationWaitTime:(nonnull CDVInvokedUrlCommand *)invokedUrlCommand;
    
- (void)setIosAttAuthorizationAutoRequest:(nonnull CDVInvokedUrlCommand *)invokedUrlCommand;
    
- (void)registerPrivacyProfile:(nonnull CDVInvokedUrlCommand *)invokedUrlCommand;

- (void)setPrivacyProfileEnabled:(nonnull CDVInvokedUrlCommand *)invokedUrlCommand;

- (void)setInitCompletedListener:(nonnull CDVInvokedUrlCommand *)invokedUrlCommand;

- (void)setIntelligentConsentGranted:(nonnull CDVInvokedUrlCommand *)invokedUrlCommand;

- (void)getStarted:(nonnull CDVInvokedUrlCommand *)invokedUrlCommand;

- (void)start:(nonnull CDVInvokedUrlCommand *)invokedUrlCommand;
    
- (void)shutdown:(nonnull CDVInvokedUrlCommand *)invokedUrlCommand;

- (void)getDeviceId:(nonnull CDVInvokedUrlCommand *)invokedUrlCommand;

- (void)getInstallAttribution:(nonnull CDVInvokedUrlCommand *)invokedUrlCommand;

- (void)retrieveInstallAttribution:(nonnull CDVInvokedUrlCommand *)invokedUrlCommand;

- (void)processDeeplink:(nonnull CDVInvokedUrlCommand *)invokedUrlCommand;

- (void)processDeeplinkWithOverrideTimeout:(nonnull CDVInvokedUrlCommand *)invokedUrlCommand;

- (void)registerPushToken:(nonnull CDVInvokedUrlCommand *)invokedUrlCommand;

- (void)setPushEnabled:(nonnull CDVInvokedUrlCommand *)invokedUrlCommand;

- (void)registerDefaultEventStringParameter:(nonnull CDVInvokedUrlCommand *)invokedUrlCommand;

- (void)registerDefaultEventBoolParameter:(nonnull CDVInvokedUrlCommand *)invokedUrlCommand;

- (void)registerDefaultEventNumberParameter:(nonnull CDVInvokedUrlCommand *)invokedUrlCommand;

- (void)registerDefaultEventUserId:(nonnull CDVInvokedUrlCommand *)invokedUrlCommand;

- (void)sendEvent:(nonnull CDVInvokedUrlCommand *)invokedUrlCommand;

- (void)sendEventWithString:(nonnull CDVInvokedUrlCommand *)invokedUrlCommand;

- (void)sendEventWithDictionary:(nonnull CDVInvokedUrlCommand *)invokedUrlCommand;

- (void)sendEventWithEvent:(nonnull CDVInvokedUrlCommand *)invokedUrlCommand;

@end
