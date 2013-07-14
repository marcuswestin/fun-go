//
//  Encoder.m
//  Dogo-iOS
//
//  Created by Marcus Westin on 7/14/13.
//  Copyright (c) 2013 Flutterby Labs Inc. All rights reserved.
//

#import "Encoder.h"
#import "NSDictionary+Fun.h"

@implementation Encoder

+ (id)makeWithFields:(NSDictionary *)fields {
    Encoder* encoder = [[Encoder alloc] init];
    encoder.fields = fields;
    encoder.reverseFields = [fields reverse];
    return encoder;
}

- (NSDictionary *)encode:(NSDictionary *)data {
    return [self _addTo:@{} data:data fields:self.fields];
}
- (NSDictionary *)encodeFurther:(NSDictionary *)encodedData withProperties:(NSDictionary *)properties {
    return [self _addTo:encodedData data:properties fields:self.fields];
}

- (NSDictionary *)decode:(NSDictionary *)data {
    return [self _addTo:@{} data:data fields:self.reverseFields];
}
- (NSDictionary *)decodeFurther:(NSDictionary *)decodedObj withData:(NSDictionary *)data {
    return [self _addTo:decodedObj data:data fields:self.reverseFields];
}

- (NSDictionary*)_addTo:(NSDictionary*)obj data:(NSDictionary*)data fields:(NSDictionary*)fields {
    NSMutableDictionary* result = [obj mutableCopy];
    for (NSString* key in fields) {
        NSString* encodedKey = fields[key];
        if (data[key]) {
            result[encodedKey] = data[key];
        }
    }
    return result;
}

@end
