//
//  FunBase.m
//  Dogo-iOS
//
//  Created by Marcus Westin on 6/25/13.
//  Copyright (c) 2013 Flutterby Labs Inc. All rights reserved.
//

#import "FunBase.h"
#import "Overlay.h"
#import <objc/runtime.h>

NSRange NSRangeMake(NSUInteger location, NSUInteger length) {
    return (NSRange){ .location = location, .length = length };
}

NSString* NSStringFromRange(NSRange range) {
    return [NSString stringWithFormat:@"{ .location=%d, .length=%d }", range.location, range.length];
}

@implementation FunBase
@end
