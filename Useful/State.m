//
//  State.m
//  ivyq
//
//  Created by Marcus Westin on 9/22/13.
//  Copyright (c) 2013 Flutterby Labs Inc. All rights reserved.
//

#import "State.h"
#import <objc/runtime.h>
#import "Files.h"

@implementation State

+(instancetype)state {
    return [[self class] alloc];
}
+ (id)fromDict:(NSDictionary*)dict {
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

- (id)copy {
    return [[self class] fromDict:[self _dict]];
}

- (NSDictionary*)_dict {
    unsigned count;
    objc_property_t *properties = class_copyPropertyList([self class], &count);
    NSMutableArray *rv = [NSMutableArray arrayWithCapacity:count];
    for (unsigned i = 0; i < count; i++) {
        objc_property_t property = properties[i];
        NSString *name = [NSString stringWithUTF8String:property_getName(property)];
        [rv addObject:name];
    }
    free(properties);
    return [self dictionaryWithValuesForKeys:rv];
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[self _dict] forKey:@"FunStateDict"];
    NSString* className = self.className;
    [aCoder encodeObject:className forKey:@"FunStateClass"];
}
- (id)initWithCoder:(NSCoder *)aDecoder {
    NSString* className = [aDecoder decodeObjectForKey:@"FunStateClass"];
    Class class = NSClassFromString(className);
    NSDictionary* dict = [aDecoder decodeObjectForKey:@"FunStateDict"];
    return [[class alloc] initWithDict:dict];
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    NSLog(@"WARNING State class \"%@\" attempted to set value %@ for undefined key %@", self.className, value, key);
}

- (void)setNilValueForKey:(NSString *)key {
//    NSLog(@"Warning State class \"%@\" attempted to set nil value for key %@", self.className, key);
}

- (NSString*)className {
    return NSStringFromClass([self class]);
}

- (BOOL)archiveToDocument:(NSString *)archiveDocName {
    return [NSKeyedArchiver archiveRootObject:self toFile:[Files documentPath:archiveDocName]];
}

+ (State*)fromArchiveDocument:(NSString*)archiveDocName {
    return [NSKeyedUnarchiver unarchiveObjectWithFile:[Files documentPath:archiveDocName]];
}


@end
