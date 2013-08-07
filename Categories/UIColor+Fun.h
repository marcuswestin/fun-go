//
//  UIColor+Fun.h
//  Dogo-iOS
//
//  Created by Marcus Westin on 6/25/13.
//  Copyright (c) 2013 Flutterby Labs Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#define WHITE [UIColor whiteColor]
#define YELLOW [UIColor yellowColor]
#define TRANSPARENT [UIColor clearColor]
#define BLACK [UIColor blackColor]
#define RED [UIColor redColor]
#define BLUE [UIColor blueColor]
#define RANDOM_COLOR [UIColor randomColor]
#define STEELBLUE [UIColor colorWithRed:70/256.f green:130/256.f blue:180/256.f alpha:1]
UIColor* rgba(NSUInteger r, NSUInteger g, NSUInteger b, CGFloat a);
UIColor* rgb(NSUInteger r, NSUInteger g, NSUInteger b);

@interface UIColor (Fun)

+ (instancetype) randomColor;

@end
