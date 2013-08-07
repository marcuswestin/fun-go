//
//  Viewport.h
//  Dogo-iOS
//
//  Created by Marcus Westin on 7/7/13.
//  Copyright (c) 2013 Flutterby Labs Inc. All rights reserved.
//

#import "FunBase.h"

@interface Viewport : FunBase

+ (CGFloat)height;
+ (CGFloat)width;
+ (CGSize)size;
+ (CGFloat)resolution;
+ (CGRect)bounds;

@end
