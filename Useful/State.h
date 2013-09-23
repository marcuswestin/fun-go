//
//  State.h
//  ivyq
//
//  Created by Marcus Westin on 9/22/13.
//  Copyright (c) 2013 Flutterby Labs Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface State : NSObject <NSCoding>
+ (instancetype) state;
+ (instancetype) fromDict:(NSDictionary*)dict;
@end

