//
//  DefaultStyles.h
//  ivyq
//
//  Created by Marcus Westin on 9/25/13.
//  Copyright (c) 2013 Flutterby Labs Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DefaultStyles : NSObject
- (void)applyTo:(UIView*)view;
@end

// UIView
@interface UIViewStyles : DefaultStyles
@property CGFloat width;
@property CGFloat height;
@property UIColor* backgroundColor;
@property CGFloat cornerRadius;
@property UIColor* borderColor;
@property CGFloat borderWidth;
@end
@interface UIView (DefaultStyles)
+ (UIViewStyles*)styles;
@end

// UIButton
@interface UIButtonStyles : UIViewStyles
@property UIColor* textColor;
@property UIFont* font;
@end
@interface UIButton (DefaultStyles)
+ (UIButtonStyles*)styles;
@end

// UITextField
@interface UITextFieldStyles : UIViewStyles
@property UIColor* textColor;
@property UIFont* font;
@property CGFloat pad;
@end
@interface UITextField (DefaultStyles);
+ (UITextFieldStyles*)styles;
@end

// UITextView
@interface UITextViewStyles : UIViewStyles
@property UIColor* textColor;
@property UIFont* font;
@end
@interface UITextView (DefaultStyles)
+ (UITextViewStyles*)styles;
@end

// UILabel
@interface UILabelStyles : UIViewStyles
@property UIColor* textColor;
@property UIFont* font;
@end
@interface UILabel (DefaultStyles);
+ (UILabelStyles*)styles;
@end
