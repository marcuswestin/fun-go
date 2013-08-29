//
//  FunBase.h
//  Dogo-iOS
//
//  Created by Marcus Westin on 6/25/13.
//  Copyright (c) 2013 Flutterby Labs Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

NSRange NSRangeMake(NSUInteger location, NSUInteger length);
NSString* NSStringFromRange(NSRange range);

@interface FunBase : NSObject
@end

#import "FunObjc.h"
