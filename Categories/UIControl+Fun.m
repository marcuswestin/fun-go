//
//  UIControl+Fun.m
//  Dogo-iOS
//
//  Created by Marcus Westin on 6/27/13.
//  Copyright (c) 2013 Flutterby Labs Inc. All rights reserved.
//

#import "UIControl+Fun.h"
#import <objc/runtime.h>

static char const * const KeyOnEditingChanged = "Fun_OnEditingChanged";
static char const * const KeyOnTap = "Fun_OnTap";
static char const * const KeyHandlers = "Fun_Handlers";
static char const * const KeyBlock = "Fun_Block";

/* UIControls
 ************/
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

/* UITextViews
 *************/
@implementation UITextView (Fun)
- (void)onUserEdit:(Block)handlerBlock {
    if (!self.delegate) { self.delegate = self; }
    objc_setAssociatedObject(self, KeyBlock, handlerBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void)textViewDidChange:(UITextView *)textView {
    Block handlerBlock = objc_getAssociatedObject(self, KeyBlock);
    handlerBlock();
}
@end