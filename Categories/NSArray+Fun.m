//
//  NSArray+Fun.m
//  Dogo-iOS
//
//  Created by Marcus Westin on 6/25/13.
//  Copyright (c) 2013 Flutterby Labs Inc. All rights reserved.
//

#import "NSArray+Fun.h"

@implementation NSArray (Fun)

- (NSMutableArray*) map:(MapIntToId)mapFn {
    NSMutableArray* results = [NSMutableArray arrayWithCapacity:self.count];
    [self each:^(id val, NSUInteger i) {
        [results addObject:mapFn(val, i)];
    }];
    return results;
}

- (void) each:(Iterate)iterateFn {
    NSUInteger length = [self count];
    for (NSUInteger i=0; i<length; i++) {
        iterateFn(self[i], i);
    }
}

- (NSMutableArray *)filter:(Filter)filterFn {
    NSMutableArray* results = [NSMutableArray array];
    [self each:^(id val, NSUInteger i) {
        if (!filterFn(val, i)) { return; }
        [results addObject:val];
    }];
    return results;
}

- (id)pickOne:(Filter)pickFn {
    NSUInteger length = [self count];
    for (NSUInteger i=0; i<length; i++) {
        if (pickFn(self[i], i)) { return self[i]; }
    }
    return nil;
}

- (NSString*) joinBy:(NSString*)joiner {
    return [self componentsJoinedByString:joiner];
}

- (NSString *)joinedByComma {
    return [self joinBy:@","];
}

- (NSString *)joinedBySpace {
    return [self joinBy:@" "];
}

- (NSString *)joinedByCommaSpace {
    return [self joinBy:@", "];
}


@end
