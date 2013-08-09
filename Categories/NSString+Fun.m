//
//  NSString+Fun.m
//  Dogo-iOS
//
//  Created by Marcus Westin on 6/25/13.
//  Copyright (c) 2013 Flutterby Labs Inc. All rights reserved.
//

#import "NSString+Fun.h"

@implementation NSString (Fun)

- (NSArray *)splitByComma {
    return [self split:@","];
}

- (NSArray *)split:(NSString *)splitter {
    return [self componentsSeparatedByString:splitter];
}

- (NSData *)toData {
    return [self dataUsingEncoding:NSUTF8StringEncoding];
}

- (NSString *)stringByRemoving:(NSString *)needles {
    return [self stringByReplacingOccurrencesOfString:needles withString:@""];
}

- (NSString *)encodedURIComponent {
    return (__bridge NSString*) CFURLCreateStringByAddingPercentEscapes(NULL, (__bridge CFStringRef)self, NULL,
                                                                        (CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ", kCFStringEncodingUTF8 );
}

- (NSString *)stringByTrimmingWhitespace {
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" \n\t\r"]];
}

@end
