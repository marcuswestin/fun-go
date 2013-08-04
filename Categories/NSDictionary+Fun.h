//
//  NSDictionary+Fun.h
//  Dogo-iOS
//
//  Created by Marcus Westin on 6/26/13.
//  Copyright (c) 2013 Flutterby Labs Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^DictionaryIterateFn)(id val, id key);
typedef id (^DictionaryMapFn)(id val, id key);

@interface NSDictionary (Fun)

- (void)each:(DictionaryIterateFn)iterateFn;

- (NSArray*)array;
- (NSArray*)array:(DictionaryMapFn)mapFn;

- (NSDictionary*)map:(DictionaryMapFn)mapFn;

- (NSString *)toQueryString;

- (NSInteger)integerFor:(NSString*)property;
- (id)nullSafeObjectForKey:(NSString*)key;

- (NSDictionary*)reverse;

@end

