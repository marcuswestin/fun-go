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

+ (void)show:(NSString *)message {
    return;
    [Overlay hide];
    CGRect frame = [[UIScreen mainScreen] bounds];

    UILabel* label = [UILabel.appendTo(overlayWindow).sizeToFit.centerInSuperView apply];
    label.text = message;
    label.textColor = UIColor.whiteColor;

    overlayWindow = [[UIWindow alloc] initWithFrame:frame];
    overlayWindow.windowLevel = UIWindowLevelStatusBar + 1;
    overlayWindow.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.75];
    [overlayWindow setHidden:NO];
    
    [self _hideKeyboard];
}

+ (void)hide {
    return;
    if (!overlayWindow) { return; }
    [overlayWindow setHidden:YES];
    overlayWindow = nil;
}

+ (void)_hideKeyboard {
    UITextField* input = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    [input becomeFirstResponder];
    [input resignFirstResponder];
}

@end
