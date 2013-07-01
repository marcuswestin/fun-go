//
//  NSArray+Fun.h
//  Dogo-iOS
//
//  Created by Marcus Westin on 6/25/13.
//  Copyright (c) 2013 Flutterby Labs Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FunBase.h"

typedef id (^MapIntToId)(id val, NSUInteger i);
typedef void (^Iterate)(id val, NSUInteger i);
typedef BOOL (^Filter)(id val, NSUInteger i);

@interface NSArray (Fun)

- (void) each:(Iterate)iterateFn;
- (NSMutableArray*) map:(MapIntToId)mapper;
- (NSMutableArray*) filter:(Filter)filterFn;
- (id) pickOne:(Filter)pickFn;

- (NSString*)joinBy:(NSString*)joiner;
- (NSString*)joinedBySpace;
- (NSString*)joinedByComma;
- (NSString*)joinedByCommaSpace;
- (NSString*)joinedByCommaNewline;
@end
