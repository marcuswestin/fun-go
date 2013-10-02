//
//  JSON.m
//  Dogo-iOS
//
//  Created by Marcus Westin on 6/27/13.
//  Copyright (c) 2013 Flutterby Labs Inc. All rights reserved.
//

#import "JSON.h"
#import "Log.h"
#import "NSObject+Fun.h"

@implementation JSON

+ (NSData*)toData:(NSObject*)obj {
    return obj.toJsonData;
}

+ (NSString *)toString:(NSObject*)obj {
    return obj.toJsonString;
}

+ (id)parseData:(NSData *)data {
    return [NSObject parseJsonData:data];
}

+ (id)parseString:(NSString *)string {
    return [NSObject parseJsonString:string];
}

@end
