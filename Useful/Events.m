//
//  Events.m
//  Dogo-iOS
//
//  Created by Marcus Westin on 6/26/13.
//  Copyright (c) 2013 Flutterby Labs Inc. All rights reserved.
//

#import "Events.h"

@implementation Events

static NSMutableDictionary* signals;
static NSInteger unique = 1;
static const NSString* RefKey = @"Sub";
static const NSString* CbKey = @"Cb";
static Events* instance;

+ (void)load {
    signals = [NSMutableDictionary dictionary];
    instance = [[Events alloc] init];
}

- (id)init {
    [self _keyboardSetup];
    return self;
}

#pragma mark - API

+ (EventSubscriber)on:(NSString *)signal callback:(EventCallback)callback {
    id subscriber = num(unique += 1);
    [self on:signal subscriber:subscriber callback:callback];
    return subscriber;
}

+ (void)on:(NSString *)signal subscriber:(EventSubscriber)subscriber callback:(EventCallback)callback {
    if (!signals[signal]) {
        signals[signal] = [NSMutableArray array];
    }
    [signals[signal] addObject:@{RefKey:subscriber, CbKey:callback}];
}

+ (void)off:(NSString *)signal subscriber:(EventSubscriber)subscriber {
    NSMutableArray* callbacks = signals[signal];
    for (NSDictionary* obj in callbacks) {
        if (obj[RefKey] == subscriber) {
            [callbacks removeObject:obj];
            break;
        }
    }
}

+ (void)fire:(NSString *)signal {
    [Events fire:signal info:nil];
}

+ (void)fire:(NSString *)signal info:(id)info {
    NSArray* callbacks = [signals[signal] copy];
    dispatch_async(dispatch_get_main_queue(), ^{
        if (info) {
            NSLog(@"@ Event %@, Info: %@", signal, info);
        } else {
            NSLog(@"@ Event %@", signal);
        }
        for (NSDictionary* obj in callbacks) {
            EventCallback callback = obj[CbKey];
            callback(info);
        }
    });
}

#pragma mark - Keyboard events

+ (void)onKeyboardWillShowSubscriber:(EventSubscriber)subscriber callback:(EventCallback)callback {
    [Events on:@"KeyboardWillShow" subscriber:subscriber callback:callback];
}

+ (void)onKeyboardWillHideSubscriber:(EventSubscriber)subscriber callback:(EventCallback)callback {
    [Events on:@"KeyboardWillHide" subscriber:subscriber callback:callback];
}

+ (void)offKeyboardWillShowSubscriber:(EventSubscriber)subscriber {
    [Events off:@"KeyboardWillShow" subscriber:subscriber];
}

+ (void)offKeyboardWillHideSubscriber:(EventSubscriber)subscriber {
    [Events off:@"KeyboardWillHide" subscriber:subscriber];
}

- (void)_keyboardSetup {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)_keyboardWillShow:(NSNotification*)notification {
    [Events fire:@"KeyboardWillShow" info:[self _keyboardInfo:notification]];
}

- (void)_keyboardWillHide:(NSNotification*)notification {
    [Events fire:@"KeyboardWillHide" info:[self _keyboardInfo:notification]];
}

- (NSDictionary*)_keyboardInfo:(NSNotification*)notification {
    NSDictionary* userInfo = notification.userInfo;
    return @{
             @"duration": userInfo[UIKeyboardAnimationDurationUserInfoKey],
             @"curve": userInfo[UIKeyboardAnimationCurveUserInfoKey]
             };
}

@end
