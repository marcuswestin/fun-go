//
//  Events.m
//  Dogo-iOS
//
//  Created by Marcus Westin on 6/26/13.
//  Copyright (c) 2013 Flutterby Labs Inc. All rights reserved.
//

#import "Events.h"

@implementation Events

static NSMutableDictionary* signals;

+ (void)setup {
    signals = [NSMutableDictionary dictionary];
}

+ (void)on:(NSString *)signal callback:(EventCallback)callback {
    if (!signals[signal]) {
        signals[signal] = [NSMutableArray array];
    }
    [signals[signal] addObject:callback];
}

+ (void)emit:(NSString *)signal {
    [Events emit:signal info:nil];
}

+ (void)emit:(NSString *)signal info:(id)info {
    NSLog(@"Emit %@ %@", signal, info);
    for (EventCallback callback in signals[signal]) {
        callback(info);
    }
}
@end
