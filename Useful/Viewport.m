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

+ (void)setup {
    size = [[UIScreen mainScreen] bounds].size;
}

+ (CGFloat)resolution {
    return [UIScreen mainScreen].scale;
}

+ (NSUInteger)height { return [Viewport size].height; }
+ (NSUInteger)width { return [Viewport size].width; }
+ (CGSize)size { return size; }

@end
