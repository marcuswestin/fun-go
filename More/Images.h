//
//  Images.h
//  Dogo-iOS
//
//  Created by Marcus Westin on 6/26/13.
//  Copyright (c) 2013 Flutterby Labs Inc. All rights reserved.
//

#import "FunBase.h"
#import "UIImage+Alpha.h"
#import "UIImage+Resize.h"
#import "UIImage+RoundedCorner.h"

@interface Images : FunBase

+ (void)load:(NSString*)url resize:(CGSize)size radius:(NSUInteger)radius callback:(ImageCallback)callback;
+ (void)load:(NSString*)url resize:(CGSize)size callback:(ImageCallback)callback;
+ (UIImage*)get:(NSString*)url resize:(CGSize)size radius:(NSUInteger)radius;

@end
