//
//  Encoder.h
//  Dogo-iOS
//
//  Created by Marcus Westin on 7/14/13.
//  Copyright (c) 2013 Flutterby Labs Inc. All rights reserved.
//

#import "FunBase.h"

@interface Encoder : FunBase
@property NSDictionary* fields;
@property NSDictionary* reverseFields;


+ makeWithFields:(NSDictionary*)fields;

- (NSDictionary*)encode:(NSDictionary*)data;
- (NSDictionary*)encodeFurther:(NSDictionary*)encodedData withProperties:(NSDictionary*)properties;
- (NSDictionary*)decode:(NSDictionary*)data;
- (NSDictionary*)decodeFurther:(NSDictionary*)decodedObj withData:(NSDictionary*)data;

@end
