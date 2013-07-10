//
//  UIControl+Fun.h
//  Dogo-iOS
//
//  Created by Marcus Westin on 6/27/13.
//  Copyright (c) 2013 Flutterby Labs Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^EventHandler)(UIEvent* event);
typedef void (^Block)();

@interface UIControlHandler : NSObject
@property (strong) EventHandler handler;
@end

@interface UIControl (Fun)
- (void) onEditingChanged:(EventHandler)handler;
- (void) onTap:(EventHandler)handler;
- (void) on:(UIControlEvents)controlEvents handler:(EventHandler)handler;
@end


@interface UITextViewDelegate : NSObject <UITextViewDelegate>
@end
@interface UITextView (Fun) <UITextViewDelegate>
- (void) onUserEdit:(Block)handler;
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
