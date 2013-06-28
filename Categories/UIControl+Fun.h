//
//  UIControl+Fun.h
//  Dogo-iOS
//
//  Created by Marcus Westin on 6/27/13.
//  Copyright (c) 2013 Flutterby Labs Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^EventHandler)(UIEvent* event);

@interface UIControl (Fun)

- (void) onEditingChanged:(EventHandler)handler;

@end
