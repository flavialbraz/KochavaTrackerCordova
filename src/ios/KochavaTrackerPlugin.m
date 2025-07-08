//
//  KochavaTracker (Cordova)
//
//  Copyright (c) 2013 - 2023 Kochava, Inc. All rights reserved.
//

#pragma mark - Import

#import "KochavaTrackerPlugin.h"
#import <WebKit/WebKit.h>

#pragma mark - Util

// Interface for the kochavaTrackerUtil
@interface KochavaTrackerUtil : NSObject

@end

// Common utility functions used by all of the wrappers.
// Any changes to the methods in here must be propagated to the other wrappers.
@implementation KochavaTrackerUtil

// Log a message to the console.
+ (void)log:(nonnull NSString *)message {
    NSLog(@"KVA/Tracker: %@", message);
}

// Attempts to read an NSDictionary and returns nil if not one.
+ (nullable NSDictionary *)readNSDictionary:(nullable id)valueId {
    return [[NSDictionary class] performSelector:@selector(kva_from:) withObject:valueId];
}

// Attempts to read an NSArray and returns nil if not one.
+ (nullable NSArray *)readNSArray:(nullable id)valueId {
    return [[NSArray class] performSelector:@selector(kva_from:) withObject:valueId];
}

// Attempts to read an NSNumber and returns nil if not one.
+ (nullable NSNumber *)readNSNumber:(nullable id)valueId {
    return [[NSNumber class] performSelector:@selector(kva_from:) withObject:valueId];
}

// Attempts to read an NSString and returns nil if not one.
+ (nullable NSString *)readNSString:(nullable id)valueId {
    return [NSString kva_from:valueId];
}

// Attempts to read an NSObject and returns nil if not one.
+ (nullable NSObject *)readNSObject:(nullable id)valueId {
    return [valueId isKindOfClass:NSNull.self] ? nil : valueId;
}

// Converts an NSNumber to a double with fallback to a default value.
+ (double)convertNumberToDouble:(nullable NSNumber *)number defaultValue:(double)defaultValue {
    if(number != nil) {
        return [number doubleValue];
    }
    return defaultValue;
}

// Converts an NSNumber to a bool with fallback to a default value.
+ (BOOL)convertNumberToBool:(nullable NSNumber *)number defaultValue:(BOOL)defaultValue {
    if(number != nil) {
        return [number boolValue];
    }
    return defaultValue;
}

// Converts the deeplink result into an NSDictionary.
+ (nonnull NSDictionary *)convertDeeplinkToDictionary:(nonnull KVADeeplink *)deeplink {
    NSObject *object = [deeplink kva_asForContext:KVAContext.host];
    return [object isKindOfClass:NSDictionary.class] ? (NSDictionary *)object : @{};
}

// Converts the install attribution result into an NSDictionary.
+ (nonnull NSDictionary *)convertInstallAttributionToDictionary:(nonnull KVAAttributionResult *)installAttribution {
    if (KVATracker.shared.startedBool) {
        NSObject *object = [installAttribution kva_asForContext:KVAContext.host];
        return [object isKindOfClass:NSDictionary.class] ? (NSDictionary *)object : @{};
    } else {
        return @{
                @"retrieved": @(NO),
                @"raw": @{},
                @"attributed": @(NO),
                @"firstInstall": @(NO),
        };
    }
}

// Converts the config result into an NSDictionary.
+ (nonnull NSDictionary *)convertConfigToDictionary:(nonnull KVATrackerConfig *)config {
    return @{
            @"consentGdprApplies": @(config.consentGDPRAppliesBool),
    };
}

// Serialize an NSDictionary into a json serialized NSString.
+ (nullable NSString *)serializeJsonObject:(nullable NSDictionary *)dictionary {
    return [NSString kva_stringFromJSONObject:dictionary prettyPrintBool:NO];
}

// Parse a json serialized NSString into an NSArray.
+ (nullable NSArray *)parseJsonArray:(nullable NSString *)string {
    NSObject *object = [string kva_serializedJSONObjectWithPrintErrorsBool:YES];
    return ([object isKindOfClass:NSArray.class] ? (NSArray *) object : nil);
}

// Parse a json serialized NSString into an NSDictionary.
+ (nullable NSDictionary *)parseJsonObject:(nullable NSString *)string {
    NSObject *object = [string kva_serializedJSONObjectWithPrintErrorsBool:YES];
    return [object isKindOfClass:NSDictionary.class] ? (NSDictionary *) object : nil;
}

// Parse a NSString into a NSURL and logs a warning on failure.
+ (nullable NSURL *)parseNSURL:(nullable NSString *)string {
    NSURL *url = [NSURL URLWithString:string];
    if (url == nil && string.length > 0) {
        [KochavaTrackerUtil log:@"Warn: parseNSURL invalid input, not a valid URL"];
    }
    return url;
}

// Builds and sends an event given an event info dictionary.
+ (void)buildAndSendEvent:(nullable NSDictionary *)eventInfo {
    if(eventInfo == nil) {
        return;
    }
    NSString *name = [KochavaTrackerUtil readNSString:eventInfo[@"name"]];
    NSDictionary *data = [KochavaTrackerUtil readNSDictionary:eventInfo[@"data"]];
    NSString *iosAppStoreReceiptBase64String = [KochavaTrackerUtil readNSString:eventInfo[@"iosAppStoreReceiptBase64String"]];
    if (name.length > 0) {
        KVAEvent *event = [[KVAEvent alloc] initCustomWithEventName:name];
        if (data != nil) {
            event.infoDictionary = data;
        }
        if (iosAppStoreReceiptBase64String.length > 0) {
            event.appStoreReceiptBase64EncodedString = iosAppStoreReceiptBase64String;
        }
        [event send];
    } else {
        [KochavaTrackerUtil log:@"Warn: sendEventWithEvent invalid input"];
    }
}

@end

#pragma mark - Methods

@implementation KochavaTrackerPlugin

// Set the logging parameters before any other access to the SDK.
+ (void) initialize {
    KVALog.shared.osLogEnabledBool = false;
    KVALog.shared.printLinesIndividuallyBool = true;
}

// void executeAdvancedInstruction(string name, string value)
- (void)executeAdvancedInstruction:(nonnull CDVInvokedUrlCommand *)invokedUrlCommand {
    NSString *name = [KochavaTrackerUtil readNSString:invokedUrlCommand.arguments[0]];
    NSString *value = [KochavaTrackerUtil readNSString:invokedUrlCommand.arguments[1]];
    
    [KVATracker.shared.networking executeAdvancedInstructionWithUniversalIdentifier:name parameter:value prerequisiteTaskIdentifierArray:nil];
}

// void setLogLevel(LogLevel logLevel)
- (void)setLogLevel:(nonnull CDVInvokedUrlCommand *)invokedUrlCommand {
    NSString *logLevel = [KochavaTrackerUtil readNSString:invokedUrlCommand.arguments[0]];

    KVALog.shared.level = [KVALogLevel kva_from:logLevel];
}

// void setSleep(bool sleep)
- (void)setSleep:(nonnull CDVInvokedUrlCommand *)invokedUrlCommand {
    BOOL sleep = [KochavaTrackerUtil convertNumberToBool:[KochavaTrackerUtil readNSNumber:invokedUrlCommand.arguments[0]] defaultValue:false];

    KVATracker.shared.sleepBool = sleep;
}

// void setAppLimitAdTracking(bool appLimitAdTracking)
- (void)setAppLimitAdTracking:(nonnull CDVInvokedUrlCommand *)invokedUrlCommand {
    BOOL appLimitAdTracking = [KochavaTrackerUtil convertNumberToBool:[KochavaTrackerUtil readNSNumber:invokedUrlCommand.arguments[0]] defaultValue:false];
    
    KVATracker.shared.appLimitAdTracking.boolean = appLimitAdTracking;
}

// void registerCustomDeviceIdentifier(string name, string value)
- (void)registerCustomDeviceIdentifier:(nonnull CDVInvokedUrlCommand *)invokedUrlCommand {
    NSString *name = [KochavaTrackerUtil readNSString:invokedUrlCommand.arguments[0]];
    NSString *value = [KochavaTrackerUtil readNSString:invokedUrlCommand.arguments[1]];
    
    [KVATracker.shared.customIdentifiers registerWithName:name identifier:value];
}

// void registerCustomStringValue(string name, string value)
- (void)registerCustomStringValue:(nonnull CDVInvokedUrlCommand *)invokedUrlCommand {
    NSString *name = [KochavaTrackerUtil readNSString:invokedUrlCommand.arguments[0]];
    NSString *value = [KochavaTrackerUtil readNSString:invokedUrlCommand.arguments[1]];
    
    [KVACustomValue registerWithName:name value:value];
}

// void registerCustomBoolValue(string name, bool value)
- (void)registerCustomBoolValue:(nonnull CDVInvokedUrlCommand *)invokedUrlCommand {
    NSString *name = [KochavaTrackerUtil readNSString:invokedUrlCommand.arguments[0]];
    NSNumber *value = [KochavaTrackerUtil readNSNumber:invokedUrlCommand.arguments[1]];
    
    [KVACustomValue registerWithName:name value:value];
}

// void registerCustomNumberValue(string name, number value)
- (void)registerCustomNumberValue:(nonnull CDVInvokedUrlCommand *)invokedUrlCommand {
    NSString *name = [KochavaTrackerUtil readNSString:invokedUrlCommand.arguments[0]];
    NSNumber *value = [KochavaTrackerUtil readNSNumber:invokedUrlCommand.arguments[1]];
    
    [KVACustomValue registerWithName:name value:value];
}

// void registerIdentityLink(string name, string value)
- (void)registerIdentityLink:(nonnull CDVInvokedUrlCommand *)invokedUrlCommand {
    NSString *name = [KochavaTrackerUtil readNSString:invokedUrlCommand.arguments[0]];
    NSString *value = [KochavaTrackerUtil readNSString:invokedUrlCommand.arguments[1]];

    [KVATracker.shared.identityLink registerWithName:name identifier:value];
}

// void enableAndroidInstantApps(string instantAppGuid)
- (void)enableAndroidInstantApps:(nonnull CDVInvokedUrlCommand *)invokedUrlCommand {
    [KochavaTrackerUtil log:@"enableAndroidInstantApps API is not available on this platform."];
}

// void enableIosAppClips(string identifier)
- (void)enableIosAppClips:(nonnull CDVInvokedUrlCommand *)invokedUrlCommand {
    NSString *identifier = [KochavaTrackerUtil readNSString:invokedUrlCommand.arguments[0]];
    
    KVAAppGroups.shared.deviceAppGroupIdentifier = identifier;
}

// void enableIosAtt()
- (void)enableIosAtt:(nonnull CDVInvokedUrlCommand *)invokedUrlCommand {
    KVATracker.shared.appTrackingTransparency.enabledBool = true;
}

// void setIosAttAuthorizationWaitTime(double waitTime)
- (void)setIosAttAuthorizationWaitTime:(nonnull CDVInvokedUrlCommand *)invokedUrlCommand {
    double waitTime = [KochavaTrackerUtil convertNumberToDouble:[KochavaTrackerUtil readNSNumber:invokedUrlCommand.arguments[0]] defaultValue:30.0];
    
    KVATracker.shared.appTrackingTransparency.authorizationStatusWaitTimeInterval = waitTime;
}

// void setIosAttAuthorizationAutoRequest(bool autoRequest)
- (void)setIosAttAuthorizationAutoRequest:(nonnull CDVInvokedUrlCommand *)invokedUrlCommand {
    BOOL autoRequest = [KochavaTrackerUtil convertNumberToBool:[KochavaTrackerUtil readNSNumber:invokedUrlCommand.arguments[0]] defaultValue:true];
    
    KVATracker.shared.appTrackingTransparency.autoRequestTrackingAuthorizationBool = autoRequest;
}

// void registerPrivacyProfile(string name, string[] keys)
- (void)registerPrivacyProfile:(nonnull CDVInvokedUrlCommand *)invokedUrlCommand {
    NSString *name = [KochavaTrackerUtil readNSString:invokedUrlCommand.arguments[0]];
    NSArray *keys = [KochavaTrackerUtil readNSArray:invokedUrlCommand.arguments[1]];
    
    [KVAPrivacyProfile registerWithName:name payloadKeyStringArray:keys];
}

// void setPrivacyProfileEnabled(string name, bool enabled)
- (void)setPrivacyProfileEnabled:(nonnull CDVInvokedUrlCommand *)invokedUrlCommand {
    NSString *name = [KochavaTrackerUtil readNSString:invokedUrlCommand.arguments[0]];
    BOOL enabled = [KochavaTrackerUtil convertNumberToBool:[KochavaTrackerUtil readNSNumber:invokedUrlCommand.arguments[1]] defaultValue:true];
    
    [KVATracker.shared.privacy setEnabledBoolForProfileName:name enabledBool:enabled];
}

// void setInitCompletedListener(bool setListener)
- (void)setInitCompletedListener:(nonnull CDVInvokedUrlCommand *)invokedUrlCommand {
    BOOL setListener = [KochavaTrackerUtil convertNumberToBool:[KochavaTrackerUtil readNSNumber:invokedUrlCommand.arguments[0]] defaultValue:true];

    if(setListener) {
        KVATracker.shared.config.closure_didComplete = ^(KVATrackerConfig * _Nonnull config) {
            NSDictionary *configDictionary = [KochavaTrackerUtil convertConfigToDictionary:config];
            NSString *configString = [KochavaTrackerUtil serializeJsonObject:configDictionary] ?: @"{}";

            NSString *javaScriptString = [NSString stringWithFormat:@"window.kochavaTrackerInitCompleted.notificationCallback('%@');", configString];
            if ([self.webView isKindOfClass:[WKWebView class]])
            {
                WKWebView *webView = (WKWebView*)self.webView;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [webView evaluateJavaScript:javaScriptString completionHandler: nil];
                });
            }
        };
    } else {
        KVATracker.shared.config.closure_didComplete = nil;
    }
}

// void setIntelligentConsentGranted(bool granted)
- (void)setIntelligentConsentGranted:(nonnull CDVInvokedUrlCommand *)invokedUrlCommand {
    NSNumber *granted = [KochavaTrackerUtil readNSNumber:invokedUrlCommand.arguments[0]];
    
    KVATracker.shared.privacy.intelligentConsent.grantedBoolNumber = granted;
}

// bool getStarted()
- (void)getStarted:(nonnull CDVInvokedUrlCommand *)invokedUrlCommand {
    NSString *started = KVATracker.shared.startedBool ? @"true" : @"false";
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:started];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:invokedUrlCommand.callbackId];
}

// void start(string androidAppGuid, string iosAppGuid, string partnerName)
- (void)start:(nonnull CDVInvokedUrlCommand *)invokedUrlCommand {
    // arg 0 is androidAppGuid
    NSString *iosAppGuid = [KochavaTrackerUtil readNSString:invokedUrlCommand.arguments[1]];
    NSString *partnerName = [KochavaTrackerUtil readNSString:invokedUrlCommand.arguments[2]];

    if (iosAppGuid.length > 0) {
        [KVATracker.shared startWithAppGUIDString:iosAppGuid];
    } else if (partnerName.length > 0) {
        [KVATracker.shared startWithPartnerNameString:partnerName];
    } else {
        // Allow the native to log the error of no app guid.
        [KVATracker.shared startWithAppGUIDString:nil];
    }
}

// shutdown(bool deleteData)
- (void)shutdown:(nonnull CDVInvokedUrlCommand *)invokedUrlCommand {
    BOOL deleteData = [KochavaTrackerUtil convertNumberToBool:[KochavaTrackerUtil readNSNumber:invokedUrlCommand.arguments[0]] defaultValue:true];
    
    [KVATrackerProduct.shared shutdownWithDeleteLocalDataBool:deleteData];
}

// string getDeviceId()
- (void)getDeviceId:(nonnull CDVInvokedUrlCommand *)invokedUrlCommand {
    NSString *deviceId = @"";
    if(KVATracker.shared.startedBool) {
        deviceId = KVATracker.shared.deviceId.string ?: @"";
    }
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:deviceId];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:invokedUrlCommand.callbackId];
}

// InstallAttribution getInstallAttribution()
- (void)getInstallAttribution:(nonnull CDVInvokedUrlCommand *)invokedUrlCommand {
    NSDictionary *attributionDictionary = [KochavaTrackerUtil convertInstallAttributionToDictionary:KVATracker.shared.attribution.result];
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:attributionDictionary];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:invokedUrlCommand.callbackId];
}

//void retrieveInstallAttribution(Callback<InstallAttribution> callback)
- (void)retrieveInstallAttribution:(nonnull CDVInvokedUrlCommand *)invokedUrlCommand {
    [KVATracker.shared.attribution retrieveResultWithCompletionHandler:^(KVAAttributionResult * attribution) {
        NSDictionary *attributionDictionary = [KochavaTrackerUtil convertInstallAttributionToDictionary:attribution];
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:attributionDictionary];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:invokedUrlCommand.callbackId];
    }];
}

// void processDeeplink(string path, Callback<Deeplink> callback)
- (void)processDeeplink:(nonnull CDVInvokedUrlCommand *)invokedUrlCommand {
    NSURL *path = [KochavaTrackerUtil parseNSURL:[KochavaTrackerUtil readNSString:invokedUrlCommand.arguments[0]]];
    
    [KVADeeplink processWithURL:path closure_didComplete:^(KVADeeplink *_Nonnull deeplink) {
        NSDictionary *deeplinkDictionary = [KochavaTrackerUtil convertDeeplinkToDictionary:deeplink];
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:deeplinkDictionary];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:invokedUrlCommand.callbackId];
    }];
}

// void processDeeplinkWithOverrideTimeout(string path, double timeout, Callback<Deeplink> callback)
- (void)processDeeplinkWithOverrideTimeout:(nonnull CDVInvokedUrlCommand *)invokedUrlCommand {
    NSURL *path = [KochavaTrackerUtil parseNSURL:[KochavaTrackerUtil readNSString:invokedUrlCommand.arguments[0]]];
    double timeout = [KochavaTrackerUtil convertNumberToDouble:[KochavaTrackerUtil readNSNumber:invokedUrlCommand.arguments[1]] defaultValue:10];
    
    [KVADeeplink processWithURL:path timeoutTimeInterval:timeout closure_didComplete:^(KVADeeplink *_Nonnull deeplink) {
        NSDictionary *deeplinkDictionary = [KochavaTrackerUtil convertDeeplinkToDictionary:deeplink];
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:deeplinkDictionary];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:invokedUrlCommand.callbackId];
    }];
}

// void registerPushToken(string token)
- (void)registerPushToken:(nonnull CDVInvokedUrlCommand *)invokedUrlCommand {
    NSString *token = [KochavaTrackerUtil readNSString:invokedUrlCommand.arguments[0]];
    [KVAPushNotificationsToken registerWithDataHexString:token];
}

// void setPushEnabled(bool enabled)
- (void)setPushEnabled:(nonnull CDVInvokedUrlCommand *)invokedUrlCommand {
    BOOL enabled = [KochavaTrackerUtil convertNumberToBool:[KochavaTrackerUtil readNSNumber:invokedUrlCommand.arguments[0]] defaultValue:false];
    KVATracker.shared.pushNotifications.enabledBool = enabled;
}

// void registerDefaultEventStringParameter(string name, string value)
- (void)registerDefaultEventStringParameter:(nonnull CDVInvokedUrlCommand *)invokedUrlCommand {
    NSString *name = [KochavaTrackerUtil readNSString:invokedUrlCommand.arguments[0]];
    NSString *value = [KochavaTrackerUtil readNSString:invokedUrlCommand.arguments[1]];

    [KVAEventDefaultParameter registerWithName:name value:value];
}

// void registerDefaultEventBoolParameter(string name, bool value)
- (void)registerDefaultEventBoolParameter:(nonnull CDVInvokedUrlCommand *)invokedUrlCommand {
    NSString *name = [KochavaTrackerUtil readNSString:invokedUrlCommand.arguments[0]];
    NSNumber *value = [KochavaTrackerUtil readNSNumber:invokedUrlCommand.arguments[1]];

    [KVAEventDefaultParameter registerWithName:name value:value];
}

// void registerDefaultEventNumberParameter(string name, number value)
- (void)registerDefaultEventNumberParameter:(nonnull CDVInvokedUrlCommand *)invokedUrlCommand {
    NSString *name = [KochavaTrackerUtil readNSString:invokedUrlCommand.arguments[0]];
    NSNumber *value = [KochavaTrackerUtil readNSNumber:invokedUrlCommand.arguments[1]];

    [KVAEventDefaultParameter registerWithName:name value:value];
}

// void registerDefaultEventUserId(string value)
- (void)registerDefaultEventUserId:(nonnull CDVInvokedUrlCommand *)invokedUrlCommand {
    NSString *value = [KochavaTrackerUtil readNSString:invokedUrlCommand.arguments[0]];

    [KVAEventDefaultParameter registerWithUserIdString:value];
}

// void sendEvent(string name)
- (void)sendEvent:(nonnull CDVInvokedUrlCommand *)invokedUrlCommand {
    NSString *name = [KochavaTrackerUtil readNSString:invokedUrlCommand.arguments[0]];
    
    if(name.length > 0) {
        [KVAEvent sendCustomWithEventName:name];
    } else {
        [KochavaTrackerUtil log:@"Warn: sendEvent invalid input"];
    }
}

// void sendEventWithString(string name, string data)
- (void)sendEventWithString:(nonnull CDVInvokedUrlCommand *)invokedUrlCommand {
    NSString *name = [KochavaTrackerUtil readNSString:invokedUrlCommand.arguments[0]];
    NSString *data = [KochavaTrackerUtil readNSString:invokedUrlCommand.arguments[1]];
    
    if(name.length > 0) {
        [KVAEvent sendCustomWithEventName:name infoString:data];
    } else {
        [KochavaTrackerUtil log:@"Warn: sendEventWithString invalid input"];
    }
}

// void sendEventWithDictionary(string name, object data)
- (void)sendEventWithDictionary:(nonnull CDVInvokedUrlCommand *)invokedUrlCommand {
    NSString *name = [KochavaTrackerUtil readNSString:invokedUrlCommand.arguments[0]];
    NSDictionary *data = [KochavaTrackerUtil readNSDictionary:invokedUrlCommand.arguments[1]];
    
    if(name.length > 0) {
        [KVAEvent sendCustomWithEventName:name infoDictionary:data];
    } else {
        [KochavaTrackerUtil log:@"Warn: sendEventWithDictionary invalid input"];
    }
}

// void sendEventWithEvent(Event event)
- (void)sendEventWithEvent:(nonnull CDVInvokedUrlCommand *)invokedUrlCommand {
    NSDictionary *eventInfo = [KochavaTrackerUtil readNSDictionary:invokedUrlCommand.arguments[0]];
    
    [KochavaTrackerUtil buildAndSendEvent:eventInfo];
}

@end
