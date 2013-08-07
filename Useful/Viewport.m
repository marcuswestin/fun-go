//
//  Viewport.m
//  Dogo-iOS
//
//  Created by Marcus Westin on 7/7/13.
//  Copyright (c) 2013 Flutterby Labs Inc. All rights reserved.
//

#import "Viewport.h"

@implementation Viewport

static CGSize size;

+ (void)load {
    size = [[UIScreen mainScreen] bounds].size;
}

+ (CGFloat)resolution {
    return [UIScreen mainScreen].scale;
}

+ (CGFloat)height { return [Viewport size].height; }
+ (CGFloat)width { return [Viewport size].width; }
+ (CGSize)size { return size; }

+ (CGRect)bounds {
    return [[UIScreen mainScreen] bounds];
}

@end
