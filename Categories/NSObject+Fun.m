//
//  NSObject+Fun.m
//  Dogo-iOS
//
//  Created by Marcus Westin on 6/25/13.
//  Copyright (c) 2013 Flutterby Labs Inc. All rights reserved.
//

#import "NSObject+Fun.h"
#import "NSString+Fun.h"
#import "Log.h"

@implementation NSObject (Fun)

- (NSString *)toQueryString {
    return (__bridge NSString*) CFURLCreateStringByAddingPercentEscapes(NULL, (__bridge CFStringRef)self, NULL,
                                                                        (CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ", kCFStringEncodingUTF8 );
}

- (NSString *)toJsonString {
    return [[NSString alloc] initWithData:self.toJsonData encoding:NSUTF8StringEncoding];
}

- (NSData*)toJsonData {
    NSError* err;
    NSData* data = [NSJSONSerialization dataWithJSONObject:self options:NSJSONWritingPrettyPrinted error:&err];
    if (err) { return [Log error:err]; }
    return data;
}

+ (NSObject *)parseJsonData:(NSData *)jsonData {
    NSError* err;
    id result = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:&err];
    if (err) { return [Log error:err]; }
    return result;
}

+ (NSObject *)parseJsonString:(NSString *)jsonString {
    return [NSObject parseJsonData:jsonString.toData];
}

@end
