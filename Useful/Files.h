//
//  FunFiles.h
//  Dogo-iOS
//
//  Created by Marcus Westin on 6/25/13.
//  Copyright (c) 2013 Flutterby Labs Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FunBase.h"

@interface Files : FunBase

+ (id)readJsonDocument:(NSString*)filename;
+ (void)writeJsonDocument:(NSString*)filename data:(id)data;
+ (NSData*)readDocument:(NSString*)filename;
+ (NSData*)readCache:(NSString*)filename;
+ (BOOL)writeDocument:(NSString*)filename data:(NSData*)data;
+ (BOOL)writeCache:(NSString*)filename data:(NSData*)data;
+ (NSString*)cachePath:(NSString*)filename;
+ (NSString*)documentPath:(NSString*)filename;

@end
