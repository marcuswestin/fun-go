//
//  UIControl+Fun.m
//  Dogo-iOS
//
//  Created by Marcus Westin on 6/27/13.
//  Copyright (c) 2013 Flutterby Labs Inc. All rights reserved.
//

#import "UIControl+Fun.h"
#import "NSArray+Fun.h"
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

/* UIButton
 **********/
@implementation UIButton (Fun)
- (void)setTitle:(NSString *)title {
    [self setTitle:title forState:UIControlStateNormal];
}
- (void)setTitleColor:(UIColor *)color {
    [self setTitleColor:color forState:UIControlStateNormal];
}
@end

/* UIControls
 ************/
@implementation UIControlHandler
- (void)_handle:(id)target event:(UIEvent*)event {
    _handler(event);
}
@end
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

/* UITextViews
 *************/
@implementation UITextView (Fun)

static char const * const KeyTextDidChange = "FunKeyTextDidChange";
- (void)onTextDidChange:(TextViewBlock)handler {
    [self _addHandlerForKey:KeyTextDidChange handler:handler];
}
- (void)textViewDidChange:(UITextView *)textView {
    [[self _handlersForKey:KeyTextDidChange] each:^(TextViewBlock handler, NSUInteger i) {
        handler(textView);
    }];
}

static char const * const KeyTextShouldChance = "FunKeyTextShouldChange";
- (void)onTextShouldChange:(TextViewShouldChangeBlock)handler {
    [self _addHandlerForKey:KeyTextShouldChance handler:handler];
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    __block BOOL shouldChange = YES;
    [[self _handlersForKey:KeyTextShouldChance] each:^(TextViewShouldChangeBlock val, NSUInteger i) {
        shouldChange = val(textView, range, text) && shouldChange;
    }];
    return shouldChange;
}

static char const * const KeySelectionChange = "FunKeySelectionChange";
- (void)onSelectionDidChange:(TextViewBlock)handler {
    [self _addHandlerForKey:KeySelectionChange handler:handler];
}
- (void)textViewDidChangeSelection:(UITextView *)textView {
    [[self _handlersForKey:KeySelectionChange] each:^(TextViewBlock handler, NSUInteger i) {
        handler(textView);
    }];
}

- (void) _addHandlerForKey:(char const * const)Key handler:(id)handler {
    if (self.delegate && self.delegate != self) {
        [NSException raise:@"BadDelegate" format:@"Delegate already set"];
    }
    self.delegate = self;
    NSMutableArray* handlers = objc_getAssociatedObject(self, Key);
    if (!handlers) { handlers = [NSMutableArray array]; }
    [handlers addObject:handler];
    objc_setAssociatedObject(self, Key, handlers, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (NSArray*)_handlersForKey:(char const * const)Key {
    return objc_getAssociatedObject(self, Key);
}

@end