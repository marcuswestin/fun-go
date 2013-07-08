//
//  UIControl+Fun.m
//  Dogo-iOS
//
//  Created by Marcus Westin on 6/27/13.
//  Copyright (c) 2013 Flutterby Labs Inc. All rights reserved.
//

#import "UIControl+Fun.h"
#import <objc/runtime.h>

static char const * const KeyOnEditingChanged = "OnEditingChanged";
static char const * const KeyOnTap = "OnTap";
static char const * const KeyHandlers = "Handlers";

@implementation UIControl (Fun)

- (void)onEditingChanged:(EventHandler)handler {
    [self on:UIControlEventEditingChanged handler:handler];
}
- (void)onTap:(EventHandler)handler {
    [self on:UIControlEventTouchUpInside handler:handler];
}
- (void)on:(UIControlEvents)controlEvents handler:(EventHandler)handler {
    UIControlHandler* controlHandler = [[UIControlHandler alloc] init];
    controlHandler.handler = handler;
    objc_setAssociatedObject(self, KeyHandlers, controlHandler, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self addTarget:controlHandler action:@selector(_handle:event:) forControlEvents:controlEvents];
}

@end

@implementation UIControlHandler
- (void)_handle:(id)target event:(UIEvent*)event {
    _handler(event);
}
@end
