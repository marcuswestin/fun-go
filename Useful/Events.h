//
//  Events.h
//  Dogo-iOS
//
//  Created by Marcus Westin on 6/26/13.
//  Copyright (c) 2013 Flutterby Labs Inc. All rights reserved.
//

#import "FunBase.h"

typedef void (^EventCallback)(id info);
typedef id EventSubscriber;

@interface Events : FunBase

+ (EventSubscriber)on:(NSString*)signal callback:(EventCallback)callback;
// Pass in e.g `self` for subscriber
+ (void)on:(NSString*)signal subscriber:(EventSubscriber)subscriber callback:(EventCallback)callback;
// Pass in e.g `self` for subscriber
+ (void)off:(NSString*)signal subscriber:(EventSubscriber)subscriber;
+ (void)fire:(NSString*)signal info:(id)info;
+ (void)fire:(NSString*)signal;

// Keyboard
+ (void)onKeyboardWillShowSubscriber:(EventSubscriber)subscriber callback:(EventCallback)callback;
+ (void)onKeyboardWillHideSubscriber:(EventSubscriber)subscriber callback:(EventCallback)callback;
+ (void)offKeyboardWillShowSubscriber:(EventSubscriber)subscriber;
+ (void)offKeyboardWillHideSubscriber:(EventSubscriber)subscriber;
@end
