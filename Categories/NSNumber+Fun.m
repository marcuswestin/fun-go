//
//  NSNumber+Fun.m
//  ivyq
//
//  Created by Marcus Westin on 9/6/13.
//  Copyright (c) 2013 Flutterby Labs Inc. All rights reserved.
//

#import "NSNumber+Fun.h"

@implementation NSNumber (Fun)

- (NSNumber *)numberByAdding:(float)amount {
    return [NSNumber numberWithFloat:self.floatValue + amount];
}

@end
