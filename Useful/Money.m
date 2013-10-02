//
//  Money.m
//  IvyQ
//
//  Created by Marcus Westin on 9/4/13.
//  Copyright (c) 2013 Flutterby Labs Inc. All rights reserved.
//

#import "Money.h"

@implementation Money

+ (NSString *)formatCents:(NSInteger)cents {
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle: NSNumberFormatterCurrencyStyle];
    float dollars = cents / 100;
    return [numberFormatter stringFromNumber:[NSNumber numberWithFloat:dollars]];
}

@end
