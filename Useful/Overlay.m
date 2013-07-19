//
//  Overlay.m
//  Dogo-iOS
//
//  Created by Marcus Westin on 6/28/13.
//  Copyright (c) 2013 Flutterby Labs Inc. All rights reserved.
//

#import "Overlay.h"
#import "FunAll.h"

@implementation Overlay

static UIWindow* overlayWindow;
static UIWindow* previousWindow;

+ (UIWindow *)show {
    previousWindow = [UIApplication sharedApplication].keyWindow;
    overlayWindow = [[UIWindow alloc] initWithFrame:previousWindow.frame];
    overlayWindow.windowLevel = UIWindowLevelStatusBar + 1;
    overlayWindow.backgroundColor = [UIColor colorWithWhite:0 alpha:0.75];
    [overlayWindow makeKeyAndVisible];
    [overlayWindow onTap:^(UITapGestureRecognizer *sender) {
        [Overlay hide];
    }];
    return overlayWindow;
}

+ (UIWindow*)showMessage:(NSString *)message {
    [Overlay show];
    UILabel* label = [[UILabel alloc] initWithFrame:overlayWindow.frame];
    label.text = message;
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = WHITE;
    [overlayWindow addSubview:label];
    return overlayWindow;
}

+ (void)hide {
    if (!overlayWindow) { return; }
    [previousWindow makeKeyAndVisible];
    [overlayWindow setHidden:YES];
    overlayWindow = nil;
    previousWindow = nil;
}

@end
