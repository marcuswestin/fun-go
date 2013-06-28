//
//  Events.h
//  Dogo-iOS
//
//  Created by Marcus Westin on 6/26/13.
//  Copyright (c) 2013 Flutterby Labs Inc. All rights reserved.
//

#import "FunBase.h"

typedef void (^EventCallback)(id info);

@interface Events : FunBase

+ (void)on:(NSString*)signal callback:(EventCallback)callback;
+ (void)emit:(NSString*)signal info:(id)info;
+ (void)emit:(NSString*)signal;

@end
