//
//  NSObject+Fun.h
//  Dogo-iOS
//
//  Created by Marcus Westin on 6/25/13.
//  Copyright (c) 2013 Flutterby Labs Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (Fun)

- (NSString *)toJsonString;
- (NSData*)toJsonData;
- (NSString*)className;
+ (NSObject*)parseJsonData:(NSData*)jsonData;
+ (NSObject*)parseJsonString:(NSString*)jsonString;

@end
