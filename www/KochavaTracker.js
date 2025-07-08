//
//  KochavaTracker (Cordova)
//
//  Copyright (c) 2013 - 2023 Kochava, Inc. All rights reserved.
//

(function(cordova) {
 
    function InitCompletedNotification() {}

    // Event spawned when an init completed notification is received.
    InitCompletedNotification.prototype.notificationCallback = function(notification) {
        if(kochavaTrackerInitCompletedListener != null) {
            kochavaTrackerInitCompletedListener(JSON.parse(notification));
        }
    };

    // Setup handlers for the native notifications via an extra constructor.
    cordova.addConstructor(function() {
        if(!window) window = {};
        window.kochavaTrackerInitCompleted = new InitCompletedNotification();
    });

})(window.cordova || window.Cordova || window.PhoneGap);


// Internal function that sends a command to the native layer.
function cordovaExecCommand(command) {
    var args = Array.prototype.slice.call(arguments, 1);
    cordova.exec(function callback(data) { },
        function errorHandler(err) { },
        'KochavaTrackerPlugin',
        command,
        args
    );
}

// Internal function that sends a command to the native layer and includes a callback.
function cordovaExecCommandCallback(command, callback) {
    var args = Array.prototype.slice.call(arguments, 2);
    cordova.exec(callback,
        function errorHandler(err) { },
        'KochavaTrackerPlugin',
        command,
        args
    );
}

// Keep track of the event listener references
var kochavaTrackerInitCompletedListener = null;

//
// Kochava Tracker SDK
//
// A lightweight and easy to integrate SDK, providing first-class integration with Kochava’s installation attribution and analytics platform.
// Getting Started: https://support.kochava.com/sdk-integration/cordova-sdk-integration/
//
var KochavaTracker = {
    // Singleton Instance
    instance: {
        // Internal State
        _internal: {
            registeredAndroidAppGuid: null,
            registeredIosAppGuid: null,
            registeredPartnerName: null
        },

        // Reserved function, only use if directed to by your Client Success Manager.
        executeAdvancedInstruction: function (name, value) {
            cordovaExecCommand('executeAdvancedInstruction', name, value);
        },
    
        // Set the log level. This should be set prior to starting the SDK.
        setLogLevel: function (logLevel) {
            cordovaExecCommand('setLogLevel', logLevel);
        },
    
        // Set the sleep state.
        setSleep: function (sleep) {
            cordovaExecCommand('setSleep', sleep);
        },
    
        // Set if app level advertising tracking should be limited.
        setAppLimitAdTracking: function (appLimitAdTracking) {
            cordovaExecCommand('setAppLimitAdTracking', appLimitAdTracking);
        },
    
        // Register a custom device identifier for install attribution.
        registerCustomDeviceIdentifier: function (name, value) {
            cordovaExecCommand('registerCustomDeviceIdentifier', name, value);
        },

        // Register a custom value to be included in SDK payloads.
        registerCustomStringValue: function (name, value) {
            cordovaExecCommand('registerCustomStringValue', name, value);
        },

        // Register a custom value to be included in SDK payloads.
        registerCustomBoolValue: function (name, value) {
            cordovaExecCommand('registerCustomBoolValue', name, value);
        },

        // Register a custom value to be included in SDK payloads.
        registerCustomNumberValue: function (name, value) {
            cordovaExecCommand('registerCustomNumberValue', name, value);
        },
    
        // Register an Identity Link that allows linking different identities together in the form of key and value pairs.
        registerIdentityLink: function (name, value) {
            cordovaExecCommand('registerIdentityLink', name, value);
        },
    
        // (Android Only) Enable the Instant App feature by setting the instant app guid.
        enableAndroidInstantApps: function (instantAppGuid) {
            cordovaExecCommand('enableAndroidInstantApps', instantAppGuid);
        },

        // (iOS Only) Enable App Clips by setting the Container App Group Identifier for App Clips data migration.
        enableIosAppClips: function (identifier) {
            cordovaExecCommand('enableIosAppClips', identifier);
        },

        // (iOS Only) Enable App Tracking Transparency.
        enableIosAtt: function () {
            cordovaExecCommand('enableIosAtt');
        },

        // (iOS Only) Set the amount of time in seconds to wait for App Tracking Transparency Authorization. Default 30 seconds.
        setIosAttAuthorizationWaitTime: function (waitTime) {
            cordovaExecCommand('setIosAttAuthorizationWaitTime', waitTime);
        },

        // (iOS Only) Set if the SDK should automatically request App Tracking Transparency Authorization on start. Default true.
        setIosAttAuthorizationAutoRequest: function (autoRequest) {
            cordovaExecCommand('setIosAttAuthorizationAutoRequest', autoRequest);
        },

        // Register a privacy profile, creating or overwriting an existing pofile.
        registerPrivacyProfile: function (name, keys) {
            cordovaExecCommand('registerPrivacyProfile', name, keys);
        },

        // Enable or disable an existing privacy profile.
        setPrivacyProfileEnabled: function (name, enabled) {
            cordovaExecCommand('setPrivacyProfileEnabled', name, enabled);
        },

        // Set the init completed callback listener.
        setInitCompletedListener: function(initCompletedListener) {
            kochavaTrackerInitCompletedListener = initCompletedListener;
            cordovaExecCommand('setInitCompletedListener', initCompletedListener != null);
        },

        // Set if consent has been explicitly opted in or out by the user.
        setIntelligentConsentGranted: function (granted) {
            cordovaExecCommand('setIntelligentConsentGranted', granted);
        },

        // Return if the SDK is currently started.
        getStarted: function () {
            return new Promise(function(resolve, reject) {
                cordovaExecCommandCallback('getStarted', function(data) {
                    resolve(data === 'true');
                });
            });
        },

        // Register the Android App GUID. Do this prior to calling Start.
        registerAndroidAppGuid: function (androidAppGuid) {
            this._internal.registeredAndroidAppGuid = androidAppGuid;
        },

        // Register the iOS App GUID. Do this prior to calling Start.
        registerIosAppGuid: function (iosAppGuid) {
            this._internal.registeredIosAppGuid = iosAppGuid;
        },

        // Register your Partner Name. Do this prior to calling Start.
        // NOTE: Only use this method if directed to by your Client Success Manager.
        registerPartnerName: function (partnerName) {
            this._internal.registeredPartnerName = partnerName;
        },

        // Start the SDK with the previously registered App GUID or Partner Name.
        start: function () {
            // Version data is updated by script. Do not change.
            var wrapper = {
                "name": "Cordova",
                "version": "3.7.0",
                "build_date": "2024-08-23T17:08:39Z"
            };
            cordovaExecCommand('executeAdvancedInstruction', "wrapper", JSON.stringify(wrapper));
            cordovaExecCommand('start', this._internal.registeredAndroidAppGuid, this._internal.registeredIosAppGuid, this._internal.registeredPartnerName);
        },

        // Shut down the SDK and optionally delete all local SDK data.
        // NOTE: Care should be taken when using this method as deleting the SDK data will make it reset back to a first install state.
        shutdown: function (deleteData) {
            this._internal.registeredAndroidAppGuid = null;
            this._internal.registeredIosAppGuid = null;
            this._internal.registeredPartnerName = null;
            kochavaTrackerInitCompletedListener = null;
            cordovaExecCommand('shutdown', deleteData);
        },

        // Return the Kochava Device ID.
        getDeviceId: function () {
            return new Promise(function(resolve, reject) {
                cordovaExecCommandCallback('getDeviceId', function(data) {
                    resolve(data);
                });
            });
        },

        // Return the currently retrieved install attribution data.
        getInstallAttribution: function () {
            return new Promise(function(resolve, reject) {
                cordovaExecCommandCallback('getInstallAttribution', function(data) {
                    resolve(data);
                });
            });
        },

        // Retrieve install attribution data from the server.
        retrieveInstallAttribution: function () {
            return new Promise(function(resolve, reject) {
                cordovaExecCommandCallback('retrieveInstallAttribution', function(data) {
                    resolve(data);
                });
            });
        },

        // Process a launch deeplink using the default 10 second timeout.
        processDeeplink: function (path) {
            return new Promise(function(resolve, reject) {
                cordovaExecCommandCallback('processDeeplink', function(data) {
                    resolve(data);
                }, path);
            });
        },

        // Process a launch deeplink using a custom timeout in seconds.
        processDeeplinkWithOverrideTimeout: function (path, timeout) {
            return new Promise(function(resolve, reject) {
                cordovaExecCommandCallback('processDeeplinkWithOverrideTimeout', function(data) {
                    resolve(data);
                }, path, timeout);
            });
        },

        // Register the push token.
        registerPushToken: function (token) {
            cordovaExecCommand('registerPushToken', token);
        },

        // Enable or disable the use of the push token.
        setPushEnabled: function (enabled) {
            cordovaExecCommand('setPushEnabled', enabled);
        },

        // Registers a default parameter on every event.
        registerDefaultEventStringParameter: function (name, value) {
            cordovaExecCommand('registerDefaultEventStringParameter', name, value);
        },

        // Registers a default parameter on every event.
        registerDefaultEventBoolParameter: function (name, value) {
            cordovaExecCommand('registerDefaultEventBoolParameter', name, value);
        },

        // Registers a default parameter on every event.
        registerDefaultEventNumberParameter: function (name, value) {
            cordovaExecCommand('registerDefaultEventNumberParameter', name, value);
        },

        // Registers a default user_id value on every event.
        registerDefaultEventUserId: function (value) {
            cordovaExecCommand('registerDefaultEventUserId', value);
        },

        // Send an event.
        sendEvent: function (name) {
            cordovaExecCommand('sendEvent', name);
        },

        // Send an event with string data.
        sendEventWithString: function (name, data) {
            cordovaExecCommand('sendEventWithString', name, data);
        },

        // Send an event with dictionary data.
        sendEventWithDictionary: function (name, data) {
            cordovaExecCommand('sendEventWithDictionary', name, data);
        },

        // Build and return an event using a Standard Event Type.
        buildEventWithEventType: function(eventType) {
            return this.buildEventWithEventName(eventType);
        },

        // Build and return an event using a custom name.
        buildEventWithEventName: function(eventName) {
            return {
                // Internal State
                _internal: {
                    name: eventName,
                    data: {},
                    iosAppStoreReceiptBase64String: null,
                    androidGooglePlayReceiptData: null,
                    androidGooglePlayReceiptSignature: null
                },
    
                // Send the event.
                send: function() {
                    cordovaExecCommand('sendEventWithEvent', this._internal);
                },
    
                // Set a custom key/value on the event where the type of the value is a string.
                setCustomStringValue: function(key, value) {
                    if(key && value && typeof(value) === "string") {
                        this._internal.data[key] = value;
                    }
                },
    
                // Set a custom key/value on the event where the type of the value is a boolean.
                setCustomBoolValue: function(key, value) {
                    if(key && value != null && typeof(value) === "boolean") {
                        this._internal.data[key] = value;
                    }
                },
    
                // Set a custom key/value on the event where the type of the value is a number.
                setCustomNumberValue: function(key, value) {
                    if(key && value != null && typeof(value) === "number") {
                        this._internal.data[key] = value;
                    }
                },
    
                // (Internal) Set a custom key/value on the event where the type of the value is a dictionary.
                _setCustomDictionaryValue: function(key, value) {
                    if(key && value != null && typeof(value) === "object") {
                        this._internal.data[key] = value;
                    }
                },
                
                // (Android Only) Set the receipt from the Android Google Play Store.
                setAndroidGooglePlayReceipt: function(data, signature) {
                    if(data && typeof(data) === "string" && signature && typeof(signature) === "string") {
                        this._internal.androidGooglePlayReceiptData = data;
                        this._internal.androidGooglePlayReceiptSignature = signature;
                    }
                },
    
                // (iOS Only) Set the receipt from the iOS Apple App Store.
                setIosAppStoreReceipt: function(base64String) {
                    if(base64String && typeof(base64String) === "string") {
                        this._internal.iosAppStoreReceiptBase64String = base64String;
                    }
                },
    
                //
                // Standard Event Parameters.
                //
                setAction:             function(value) { this.setCustomStringValue("action", value); },              // Type: string
                setBackground:         function(value) { this.setCustomBoolValue("background", value); },            // Type: bool
                setCheckoutAsGuest:    function(value) { this.setCustomStringValue("checkout_as_guest", value); },   // Type: string
                setCompleted:          function(value) { this.setCustomBoolValue("completed", value); },             // Type: bool
                setContentId:          function(value) { this.setCustomStringValue("content_id", value); },          // Type: string
                setContentType:        function(value) { this.setCustomStringValue("content_type", value); },        // Type: string
                setCurrency:           function(value) { this.setCustomStringValue("currency", value); },            // Type: string
                setDate:               function(value) { this.setCustomStringValue("date", value); },                // Type: string
                setDescription:        function(value) { this.setCustomStringValue("description", value); },         // Type: string
                setDestination:        function(value) { this.setCustomStringValue("destination", value); },         // Type: string
                setDuration:           function(value) { this.setCustomNumberValue("duration", value); },            // Type: number
                setEndDate:            function(value) { this.setCustomStringValue("end_date", value); },            // Type: string
                setItemAddedFrom:      function(value) { this.setCustomStringValue("item_added_from", value); },     // Type: string
                setLevel:              function(value) { this.setCustomStringValue("level", value); },               // Type: string
                setMaxRatingValue:     function(value) { this.setCustomNumberValue("max_rating_value", value); },    // Type: number
                setName:               function(value) { this.setCustomStringValue("name", value); },                // Type: string
                setOrderId:            function(value) { this.setCustomStringValue("order_id", value); },            // Type: string
                setOrigin:             function(value) { this.setCustomStringValue("origin", value); },              // Type: string
                setPayload:            function(value) { this._setCustomDictionaryValue("payload", value); },        // Type: dictionary
                setPrice:              function(value) { this.setCustomNumberValue("price", value); },               // Type: number
                setQuantity:           function(value) { this.setCustomNumberValue("quantity", value); },            // Type: number
                setRatingValue:        function(value) { this.setCustomNumberValue("rating_value", value); },        // Type: number
                setReceiptId:          function(value) { this.setCustomStringValue("receipt_id", value); },          // Type: string
                setReferralFrom:       function(value) { this.setCustomStringValue("referral_from", value); },       // Type: string
                setRegistrationMethod: function(value) { this.setCustomStringValue("registration_method", value); }, // Type: string
                setResults:            function(value) { this.setCustomStringValue("results", value); },             // Type: string
                setScore:              function(value) { this.setCustomStringValue("score", value); },               // Type: string
                setSearchTerm:         function(value) { this.setCustomStringValue("search_term", value); },         // Type: string
                setSource:             function(value) { this.setCustomStringValue("source", value); },              // Type: string
                setSpatialX:           function(value) { this.setCustomNumberValue("spatial_x", value); },           // Type: number
                setSpatialY:           function(value) { this.setCustomNumberValue("spatial_y", value); },           // Type: number
                setSpatialZ:           function(value) { this.setCustomNumberValue("spatial_z", value); },           // Type: number
                setStartDate:          function(value) { this.setCustomStringValue("start_date", value); },          // Type: string
                setSuccess:            function(value) { this.setCustomStringValue("success", value); },             // Type: string
                setUri:                function(value) { this.setCustomStringValue("uri", value); },                 // Type: string
                setUserId:             function(value) { this.setCustomStringValue("user_id", value); },             // Type: string
                setUserName:           function(value) { this.setCustomStringValue("user_name", value); },           // Type: string
                setValidated:          function(value) { this.setCustomStringValue("validated", value); },           // Type: string
                
                //
                // Ad LTV Event Parameters
                //
                setAdCampaignId:       function(value) { this.setCustomStringValue("ad_campaign_id", value); },      // Type: string
                setAdCampaignName:     function(value) { this.setCustomStringValue("ad_campaign_name", value); },    // Type: string
                setAdDeviceType:       function(value) { this.setCustomStringValue("device_type", value); },         // Type: string
                setAdGroupId:          function(value) { this.setCustomStringValue("ad_group_id", value); },         // Type: string
                setAdGroupName:        function(value) { this.setCustomStringValue("ad_group_name", value); },       // Type: string
                setAdMediationName:    function(value) { this.setCustomStringValue("ad_mediation_name", value); },   // Type: string
                setAdNetworkName:      function(value) { this.setCustomStringValue("ad_network_name", value); },     // Type: string
                setAdPlacement:        function(value) { this.setCustomStringValue("placement", value); },           // Type: string
                setAdSize:             function(value) { this.setCustomStringValue("ad_size", value); },             // Type: string
                setAdType:             function(value) { this.setCustomStringValue("ad_type", value); }              // Type: string
            }
        }
    }
};

module.exports = KochavaTracker;
