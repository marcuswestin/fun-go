//
//  UIColor+Fun.m
//  Dogo-iOS
//
//  Created by Marcus Westin on 6/25/13.
//  Copyright (c) 2013 Flutterby Labs Inc. All rights reserved.
//

#import "UIColor+Fun.h"

UIColor* rgba(NSUInteger r, NSUInteger g, NSUInteger b, CGFloat a) {
    return [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a];
}
UIColor* rgb(NSUInteger r, NSUInteger g, NSUInteger b) {
    return rgba(r, g, b, 1.0);
}

@implementation UIColor (Fun)

+ (instancetype)randomColor {
    CGFloat hue = ( arc4random() % 256 / 256.0 );  //  0.0 to 1.0
    CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from white
    CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from black
    return [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
}

- (CGFloat)alpha {
    CGFloat alpha;
    [self getWhite:nil alpha:&alpha];
    return alpha;
}

- (BOOL)hasTransparency {
    return !self.alpha;
}

@end
