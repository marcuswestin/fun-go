//
//  JSON.h
//  Dogo-iOS
//
//  Created by Marcus Westin on 6/27/13.
//  Copyright (c) 2013 Flutterby Labs Inc. All rights reserved.
//

#import "FunBase.h"

@interface JSON : FunBase

+ (NSString*)toString:(id)obj;
+ (NSData*)toData:(id)obj;
+ (id)parseString:(NSString*)string;
+ (id)parseData:(NSData*)data;

@end
