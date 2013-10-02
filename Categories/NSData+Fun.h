//
//  NSData+Fun.h
//  Dogo-iOS
//
//  Created by Marcus Westin on 6/27/13.
//  Copyright (c) 2013 Flutterby Labs Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (Fun)

- (NSString*) toString;
- (id) toJsonObject;

@end
