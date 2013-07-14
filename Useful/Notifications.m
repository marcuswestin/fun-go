//
//  Notifications.m
//  Dogo-iOS
//
//  Created by Marcus Westin on 7/13/13.
//  Copyright (c) 2013 Flutterby Labs Inc. All rights reserved.
//

#import "Notifications.h"

#if defined PLATFORM_OSX
#define NotificationTypes (UIRemoteNotificationTypeBadge)
#define PUSH_TYPE @"osx"
#define UIRemoteNotificationTypeAlert NSRemoteNotificationTypeAlert

#elif defined PLATFORM_IOS
#define NotificationTypes (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)
#define PUSH_TYPE @"ios"
#endif

@implementation Notifications

static Callback registerCallback;

+ (void)setup {
    [Events on:@"Application.didRegisterForRemoteNotificationsWithDeviceToken" callback:^(NSData* deviceToken) {
        NSString* tokenAsString = [deviceToken description];
        tokenAsString = [tokenAsString stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
        tokenAsString = [tokenAsString stringByReplacingOccurrencesOfString:@" " withString:@""];
        NSDictionary* info = @{ @"token":tokenAsString, @"type":PUSH_TYPE };
        registerCallback(nil, info);
        registerCallback = nil;
    }];
    [Events on:@"Application.didFailToRegisterForRemoteNotificationsWithError" callback:^(NSError* err) {
        registerCallback(err, nil);
        registerCallback = nil;
    }];
    [Events on:@"Application.didReceiveRemoteNotification" callback:^(NSDictionary* notification) {
        [Events emit:@"Notifications.notification" info:@{ @"notification":notification }];
    }];
    [Events on:@"Application.didLaunchWithNotification" callback:^(NSDictionary* notification) {
        [Events emit:@"Notifications.notification" info:@{ @"notification":notification,
                                                           @"didBringAppIntoForeground":num(1) }];
    }];
}

+ (void)register:(Callback)callback {
    registerCallback = callback;
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:NotificationTypes];
}

+ (NSDictionary*)status {
    UIRemoteNotificationType types = [UIApplication.sharedApplication enabledRemoteNotificationTypes];
    if (types == UIRemoteNotificationTypeNone) { return nil; }
    
    NSMutableDictionary* res = [NSMutableDictionary dictionary];
    if (types | UIRemoteNotificationTypeAlert) { res[@"alert"] = [NSNumber numberWithBool:YES]; }
    if (types | UIRemoteNotificationTypeBadge) { res[@"badge"] = [NSNumber numberWithBool:YES]; }
    if (types | UIRemoteNotificationTypeSound) { res[@"sound"] = [NSNumber numberWithBool:YES]; }
    return res;
}

+ (void)incrementBadgeNumber:(NSInteger)incrementBy {
    [self setBadgeNumber:[self getBadgeNumber] + incrementBy];
}

+ (void)decrementBadgeNumber:(NSInteger)decrementBy {
    [self setBadgeNumber:[self getBadgeNumber] - decrementBy];
}

/* Platform specific OSX
 ***********************/
#if defined PLATFORM_OSX
+ (NSInteger) getBadgeNumber { return 0; }
+ (void) setBadgeNumber:(NSInteger)number {}
//- (void) handleDidReceiveRemoteNotification:(NSNotification*)notification {
//    [self handlePushNotification:notification.userInfo[@"notification"] didBringAppToForeground:NO];
//}

/* Platform specific iOS
 ***********************/
#elif defined PLATFORM_IOS
+ (NSInteger) getBadgeNumber {
    return [[UIApplication sharedApplication] applicationIconBadgeNumber];
}
+ (void) setBadgeNumber:(NSInteger)number {
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:number];
}
//- (void) handleDidReceiveRemoteNotification:(NSNotification*)notification {
//    [self handlePushNotification:notification.userInfo[@"notification"] didBringAppToForeground:([UIApplication sharedApplication].applicationState != UIApplicationStateActive)];
//}
#endif

@end
