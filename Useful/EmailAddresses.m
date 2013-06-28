//
//  EmailAddresses.m
//  Dogo-iOS
//
//  Created by Marcus Westin on 6/28/13.
//  Copyright (c) 2013 Flutterby Labs Inc. All rights reserved.
//

#import "EmailAddresses.h"

@implementation EmailAddresses

+ (NSString *)normalize:(NSString *)email {
    return email.lowercaseString;
}

@end
