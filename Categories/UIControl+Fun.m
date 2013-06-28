//
//  UIControl+Fun.m
//  Dogo-iOS
//
//  Created by Marcus Westin on 6/27/13.
//  Copyright (c) 2013 Flutterby Labs Inc. All rights reserved.
//

#import "UIControl+Fun.h"
#import <objc/runtime.h>

static char const * const KeyOnEditingChanged = "";

@implementation UIControl (Fun)

- (void)onEditingChanged:(EventHandler)handler {
    objc_setAssociatedObject(self, KeyOnEditingChanged, handler, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self addTarget:self action:@selector(_handleEditingChanged:event:) forControlEvents:UIControlEventEditingChanged];
}

- (void)_handleEditingChanged:(id)target event:(UIEvent*)event {
    EventHandler handler = objc_getAssociatedObject(self, KeyOnEditingChanged);
    handler(event);
}

@end
