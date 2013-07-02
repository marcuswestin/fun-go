//
//  Videos.h
//  Dogo-iOS
//
//  Created by Marcus Westin on 7/1/13.
//  Copyright (c) 2013 Flutterby Labs Inc. All rights reserved.
//

#import "FunBase.h"

@interface Videos : FunBase

+ (instancetype)playVideo:(NSString*)url fromView:(UIView*)view callback:(Callback)callback;

@end
