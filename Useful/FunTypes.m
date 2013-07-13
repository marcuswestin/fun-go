//
//  FunTypes.m
//  Dogo-iOS
//
//  Created by Marcus Westin on 7/13/13.
//  Copyright (c) 2013 Flutterby Labs Inc. All rights reserved.
//

#import "FunTypes.h"

#include <stdio.h>

void error(NSError* err) {
    if (!err) { return; }
    NSLog(@"ERROR %@", err);
}

void after(CGFloat delayInSeconds, Block block) {
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), block);
}

NSString* concat(NSString* firstArg, ...) {
    NSMutableString *result = [NSMutableString string];
    va_list args;
    va_start(args, firstArg);
    for (NSString *arg = firstArg; arg != nil; arg = va_arg(args, NSString*)) {
        [result appendString:arg];
    }
    va_end(args);
    return result;
}

NSNumber* num(NSInteger i) { return [NSNumber numberWithInt:i]; }

NSError* makeError(NSString* localMessage) {
    return [NSError errorWithDomain:@"Global" code:1 userInfo:@{ NSLocalizedDescriptionKey:localMessage }];
}
