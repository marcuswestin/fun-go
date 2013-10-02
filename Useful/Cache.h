//
//  Cache.h
//  Dogo-iOS
//
//  Created by Marcus Westin on 6/26/13.
//  Copyright (c) 2013 Flutterby Labs Inc. All rights reserved.
//

#import "FunBase.h"

@interface Cache : FunBase

+ (void)store:(NSString*)key data:(NSData*)data;
+ (void)store:(NSString*)key data:(NSData*)data cacheInMemory:(BOOL)cacheInMemory;
+ (NSData*)get:(NSString*)key;
+ (NSData*)get:(NSString*)key cacheInMemory:(BOOL)cacheInMemory;

@end
