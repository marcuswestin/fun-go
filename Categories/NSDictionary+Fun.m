//
//  NSDictionary+Fun.m
//  Dogo-iOS
//
//  Created by Marcus Westin on 6/26/13.
//  Copyright (c) 2013 Flutterby Labs Inc. All rights reserved.
//

#import "NSDictionary+Fun.h"
#import "NSArray+Fun.h"
#import "NSString+Fun.h"

@implementation NSDictionary (Fun)

- (void)each:(DictionaryIterateFn)iterateFn {
    for (id key in self) {
        iterateFn(self[key], key);
    }
}

- (NSArray *)array:(DictionaryMapFn)mapFn {
    NSMutableArray* arr = [NSMutableArray arrayWithCapacity:self.count];
    for (id key in self) {
        [arr addObject:mapFn(self[key], key)];
    }
    return arr;
}

- (NSArray *)array {
    return [self array:^id(id val, id key) {
        return val;
    }];
}

- (NSDictionary *)map:(DictionaryMapFn)mapFn {
    NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithCapacity:self.count];
    for (id key in self) {
        dict[key] = mapFn(self[key], key);
    }
    return dict;
}

- (NSString *)toQueryString {
    NSMutableArray* arr = [NSMutableArray arrayWithCapacity:self.count];
    [self enumerateKeysAndObjectsUsingBlock:^(NSString* key, id value, BOOL *stop) {
        [arr addObject:[NSString stringWithFormat:@"%@=%@", key.encodedURIComponent, [value stringValue].encodedURIComponent]];
    }];
    return [arr joinBy:@"&"];
}

- (NSInteger)integerFor:(NSString *)property {
    id val = self[property];
    return (val == [NSNull null] ? 0 : [val integerValue]);
}

- (id)nullSafeObjectForKey:(NSString*)key {
    id val = self[key];
    return (val && val != [NSNull null] ? val : nil);
}

- (NSDictionary *)reverse {
    NSMutableDictionary* res = [NSMutableDictionary dictionaryWithCapacity:self.count];
    for (id key in self) {
        id val = self[key];
        if (res[val]) {
            [NSException raise:@"DuplicateKey" format:@"Duplicate value in NSDictionary.reverse"];
            return nil;
        }
        res[val] = key;
    }
    return res;
}

@end
