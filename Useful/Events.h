//
//  Events.h
//  Dogo-iOS
//
//  Created by Marcus Westin on 6/26/13.
//  Copyright (c) 2013 Flutterby Labs Inc. All rights reserved.
//

#import "FunBase.h"

typedef void (^EventCallback)(id info);
typedef id EventsRef;

@interface Events : FunBase

+ (EventsRef)on:(NSString*)signal callback:(EventCallback)callback;
+ (EventsRef)on:(NSString*)signal ref:(EventsRef)ref callback:(EventCallback)callback;
+ (void)off:(NSString*)signal ref:(EventsRef)ref;
+ (void)fire:(NSString*)signal info:(id)info;
+ (void)fire:(NSString*)signal;

@end
