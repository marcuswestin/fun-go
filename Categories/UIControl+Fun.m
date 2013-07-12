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

/* UI View
 *********/
@implementation UIView (Fun)
- (id)_addFunGesture:(Class)cls Key:(char const * const)Key selector:(SEL)selector handler:(id)handler {
    objc_setAssociatedObject(self, Key, handler, OBJC_ASSOCIATION_COPY_NONATOMIC);
    id instance = [[cls alloc] initWithTarget:self action:selector];
    [self addGestureRecognizer:instance];
    return instance;
}
// Tap Gesture
static char const * const KeyTapHandler = "Fun_TapHandler";
- (UITapGestureRecognizer*)onTap:(TapHandler)handler {
    return [self onTapNumber:1 withTouches:1 handler:handler];
}
- (UITapGestureRecognizer*)onTapNumber:(NSUInteger)numberOfTapsRequires withTouches:(NSUInteger)numberOfTouchesRequired handler:(TapHandler)handler {
    UITapGestureRecognizer* tap = [self _addFunGesture:UITapGestureRecognizer.class Key:KeyTapHandler selector:@selector(_handleFunTap:) handler:handler];
    tap.numberOfTapsRequired = numberOfTapsRequires;
    tap.numberOfTouchesRequired = numberOfTouchesRequired;
    return tap;
}
- (void) _handleFunTap:(UITapGestureRecognizer*)sender {
//    if (sender.state != UIGestureRecognizerStateEnded) { return; }
    ((TapHandler) objc_getAssociatedObject(self, KeyTapHandler))(sender);
}
// Pan Gesture
static char const * const KeyPanHandler = "Fun_PanHandler";
- (UIPanGestureRecognizer*)onPan:(PanHandler)handler {
    UIPanGestureRecognizer* pan = [self _addFunGesture:UIPanGestureRecognizer.class Key:KeyPanHandler selector:@selector(_handleFunPan:) handler:handler];
    return pan;
}
- (void) _handleFunPan:(UIPanGestureRecognizer*)sender {
    ((PanHandler) objc_getAssociatedObject(self, KeyPanHandler))(sender);
}
@end

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