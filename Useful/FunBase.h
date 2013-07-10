//
//  FunBase.h
//  Dogo-iOS
//
//  Created by Marcus Westin on 6/25/13.
//  Copyright (c) 2013 Flutterby Labs Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#define CLIP(X,min,max) MIN(MAX(X, min), max)
static UIColor* white;

void error(NSError* err);
NSError* makeError(NSString* localMessage);

typedef void (^Callback)(id err, id res);
typedef void (^DataCallback)(id err, NSData* data);

NSString* concat(id arg1, ...);
NSNumber* num(int i);

@interface FunBase : NSObject

+ (void) setup;

@end
