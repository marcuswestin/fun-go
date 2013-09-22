//
//  State.m
//  ivyq
//
//  Created by Marcus Westin on 9/22/13.
//  Copyright (c) 2013 Flutterby Labs Inc. All rights reserved.
//

#import "State.h"
#import <objc/runtime.h>

@implementation State

+(instancetype)state {
    return [[self class] alloc];
}
+ (instancetype)stateFromDict:(NSDictionary*)dict {
    if ([dict isKindOfClass:State.class]) {
        return (State*)dict;
    } else {
        id instance = [[[self class] alloc] initWithDict:dict];
        return instance;
    }
}
- (instancetype)initWithDict:(NSDictionary*)dict {
    [self setValuesForKeysWithDictionary:dict];
    return self;
}
- (void)encodeWithCoder:(NSCoder *)aCoder {
    unsigned count;
    objc_property_t *properties = class_copyPropertyList([self class], &count);
    NSMutableArray *rv = [NSMutableArray arrayWithCapacity:count];
    for (unsigned i = 0; i < count; i++) {
        objc_property_t property = properties[i];
        NSString *name = [NSString stringWithUTF8String:property_getName(property)];
        [rv addObject:name];
    }
    free(properties);
    
    NSDictionary* dict = [self dictionaryWithValuesForKeys:rv];
    [aCoder encodeObject:dict forKey:@"baseDataStateDict"];
}
- (id)initWithCoder:(NSCoder *)aDecoder {
    NSDictionary* dict = [aDecoder decodeObjectForKey:@"baseDataStateDict"];
    return [self initWithDict:dict];
}

@end