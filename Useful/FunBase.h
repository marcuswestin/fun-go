//
//  FunBase.h
//  Dogo-iOS
//
//  Created by Marcus Westin on 6/25/13.
//  Copyright (c) 2013 Flutterby Labs Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#define CLIP(X,min,max) MIN(MAX(X, min), max)
#define white [UIColor whiteColor]
#define yellow [UIColor yellowColor]
#define transparent [UIColor clearColor]
#define black [UIColor blackColor]

void error(NSError* err);
NSError* makeError(NSString* localMessage);

typedef void (^Block)();
typedef void (^Callback)(id err, id res);
typedef void (^DataCallback)(id err, NSData* data);

void after(CGFloat delayInSeconds, Block block);

NSString* concat(id arg1, ...);
NSNumber* num(int i);

@interface FunBase : NSObject

+ (void) setup;

@end
