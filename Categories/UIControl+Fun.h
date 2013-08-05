//
//  UIControl+Fun.h
//  Dogo-iOS
//
//  Created by Marcus Westin on 6/27/13.
//  Copyright (c) 2013 Flutterby Labs Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FunTypes.h"

typedef void (^EventHandler)(UIEvent* event);

typedef void (^TapHandler)(UITapGestureRecognizer* sender);
typedef void (^PanHandler)(UIPanGestureRecognizer* sender);

@interface UIView (Fun)
- (UITapGestureRecognizer*) onTap:(TapHandler)handler;
- (UIPanGestureRecognizer*) onPan:(PanHandler)handler;
@end

@interface UIButton (Fun)
- (void)setTitle:(NSString *)title;
- (void)setTitleColor:(UIColor *)color;
@end

@interface UIControlHandler : NSObject
@property (strong) EventHandler handler;
@end

@interface UIControl (Fun)
- (void) onEditingChanged:(EventHandler)handler;
- (void) onTap:(EventHandler)handler;
- (void) on:(UIControlEvents)controlEvents handler:(EventHandler)handler;
@end

typedef BOOL (^TextViewShouldChangeBlock)(UITextView* textView, NSRange range, NSString* replacementText);
typedef void (^TextViewBlock)(UITextView* textView);
@interface UITextViewDelegate : NSObject <UITextViewDelegate>
@end
@interface UITextView (Fun) <UITextViewDelegate>
- (void) onTextDidChange:(TextViewBlock)handler;
- (void) onTextShouldChange:(TextViewShouldChangeBlock)handler;
- (void) onSelectionDidChange:(TextViewBlock)handler;
@end

// Prevent emojis:
//- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
//    
//    if (!(([text isEqualToString:@""]))) {//not a backspace
//        unichar unicodevalue = [text characterAtIndex:0];
//        if (unicodevalue == 55357) {
//            return NO;
//        }
//    }
//}
