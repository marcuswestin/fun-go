//
//  Log.h
//  Dogo-iOS
//
//  Created by Marcus Westin on 6/27/13.
//  Copyright (c) 2013 Flutterby Labs Inc. All rights reserved.
//

#import "FunBase.h"

@interface Log : FunBase

+ (void) event:(NSString*)event data:(NSDictionary*)data;
+ (id) error:(NSError*)error;

@end
