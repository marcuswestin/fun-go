//
//  UIImage+Fun.h
//  PonyDebugger
//
//  Created by Marcus Westin on 9/2/13.
//
//

#import <UIKit/UIKit.h>

@interface UIImage (Fun)

+ (UIImage *)radialGradientWithSize:(CGSize)size fromColor:(UIColor*)fromColor toColor:(UIColor*)toColor x:(CGFloat)x y:(CGFloat)y radius:(CGFloat)radius;

@end

