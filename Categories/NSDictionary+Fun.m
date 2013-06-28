//
//  NSDictionary+Fun.m
//  Dogo-iOS
//
//  Created by Marcus Westin on 6/26/13.
//  Copyright (c) 2013 Flutterby Labs Inc. All rights reserved.
//

#import "NSDictionary+Fun.h"

@implementation NSDictionary (Fun)

- (void)each:(DictionaryIterateFn)iterateFn {
    for (id key in self) {
        iterateFn(self[key], key);
    }
}

@end
