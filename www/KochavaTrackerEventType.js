//
//  KochavaTracker (Cordova)
//
//  Copyright (c) 2013 - 2023 Kochava, Inc. All rights reserved.
//

//
// Standard Event Types
//
// For standard parameters and expected usage see: https://support.kochava.com/reference-information/post-install-event-examples/
//
var KochavaTrackerEventType = {
    Achievement:          "Achievement",
    AddToCart:            "Add to Cart",
    AddToWishList:        "Add to Wish List",
    CheckoutStart:        "Checkout Start",
    LevelComplete:        "Level Complete",
    Purchase:             "Purchase",
    Rating:               "Rating",
    RegistrationComplete: "Registration Complete",
    Search:               "Search",
    TutorialComplete:     "Tutorial Complete",
    View:                 "View",
    AdView:               "Ad View",
    PushReceived:         "Push Received",
    PushOpened:           "Push Opened",
    ConsentGranted:       "Consent Granted",
    Deeplink:             "_Deeplink",
    AdClick:              "Ad Click",
    StartTrial:           "Start Trial",
    Subscribe:            "Subscribe"
};

module.exports = KochavaTrackerEventType;