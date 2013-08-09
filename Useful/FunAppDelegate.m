//
//  FunAppDelegate.m
//  Dogo-iOS
//
//  Created by Marcus Westin on 7/13/13.
//  Copyright (c) 2013 Flutterby Labs Inc. All rights reserved.
//

#import "FunAppDelegate.h"
#import "FunBase.h"
#import "Events.h"

@implementation FunAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    _window = [[UIWindow alloc] initWithFrame:[self _appRect]];
    _window.backgroundColor = rgb(250,252,255);
    [self start];
    
    [_window makeKeyAndVisible];

    [self handleLaunchNotification:[launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey]];

    return YES;
}

- (void)start {
    [NSException raise:@"NotImplemented" format:@"You should implement FunAppDelegate start"];
}

- (CGRect) _appRect {
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    return screenBounds;
    //    CGRect viewRect;
    //    if (UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation)) {
    //        viewRect = screenBounds;
    //        NSString *version = [[UIDevice currentDevice] systemVersion];
    //        BOOL isBefore7 = [version floatValue] < 7.0;
    //
    //        if (isBefore7) {
    //            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent];
    //        }
    //        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    //    } else {
    //        viewRect = CGRectMake(0, 0, screenBounds.size.height, screenBounds.size.width);
    //    }
    
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [Events fire:@"Application.didRegisterForRemoteNotificationsWithDeviceToken" info:deviceToken];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)err {
    [Events fire:@"Application.didFailToRegisterForRemoteNotificationsWithError" info:err];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)notification {
    [Events fire:@"Application.didReceiveRemoteNotification" info:notification];
}

- (void)handleLaunchNotification:(NSDictionary*)launchNotification {
    if (launchNotification) {
        [Events fire:@"Application.didLaunchWithNotification" info:launchNotification];
    }
}

@end
