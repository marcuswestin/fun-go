//
//  Notifications.h
//  Dogo-iOS
//
//  Created by Marcus Westin on 7/13/13.
//  Copyright (c) 2013 Flutterby Labs Inc. All rights reserved.
//

#import "FunBase.h"
#import "Events.h"

typedef NSDictionary* Notification;

@interface Notifications : FunBase
+ (void) register:(Callback)callback;
+ (NSDictionary*) status;
+ (NSInteger) getBadgeNumber;
+ (void) setBadgeNumber:(NSInteger)number;
+ (void) incrementBadgeNumber:(NSInteger)incrementBy;
+ (void) decrementBadgeNumber:(NSInteger)decrementBy;
@end
