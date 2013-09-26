//
//  PhoneNumbers.m
//  Dogo-iOS
//
//  Created by Marcus Westin on 6/27/13.
//  Copyright (c) 2013 Flutterby Labs Inc. All rights reserved.
//

#import "PhoneNumbers.h"
#import "NSString+Fun.h"
#import "RMPhoneFormat.h"

@implementation PhoneNumbers

static NSString* locale;

+ (void)load {
    locale = [[NSLocale currentLocale] objectForKey:NSLocaleCountryCode];
}

+ (NSString *)format:(NSString *)phoneNumber {
    return [RMPhoneFormat.instance format:phoneNumber];
}

+ (BOOL)isValid:(NSString *)phoneNumber {
    return [RMPhoneFormat.instance isPhoneNumberValid:phoneNumber];
}

+ (NSString *)normalize:(NSString *)phoneNumber {
    NSString* normalized = [PhoneNumbers _normalize:phoneNumber];
    if (!normalized) { return nil; }
    return [PhoneNumbers isValid:normalized] ? normalized : nil;
}
+ (NSString *)_normalize:(NSString *)phoneNumber {
    if (!phoneNumber || !phoneNumber.length) { return nil; }

    NSString* normalized = [[[[phoneNumber
            stringByRemoving:@" "]
            stringByRemoving:@"-"]
            stringByRemoving:@"("]
            stringByRemoving:@")"];
    
    if (normalized.length == 0) {
        return nil;
    
    } else if ([normalized characterAtIndex:0] == '+') {
        return normalized;

    } else if ([locale isEqualToString:@"US"] && [normalized characterAtIndex:0] == '1') {
        // In the US, we should handle 1-412-423-8869 like +1-412-423-8669
        return [@"+" stringByAppendingString:normalized];
        
    } else {
        return [NSString stringWithFormat:@"+%@%@", RMPhoneFormat.instance.defaultCallingCode, normalized];
    }
}

+ (BOOL)isUSPhoneNumber:(NSString *)phoneNumber {
    NSRange range = [[PhoneNumbers normalize:phoneNumber] rangeOfString:@"+1"];
    return range.location == 0;
}

+ (void)autoFormat:(UITextField*)textField onValid:(void(^)(NSString* phoneNumber))handler {
    [textField onEditingChanged:^(UIEvent *event) {
        NSString* formatted = [PhoneNumbers format:textField.text];
        if (!formatted) { return; }
        textField.text = formatted;
        
        NSString* normalized = [PhoneNumbers normalize:formatted];
        if (!normalized) { return; }
        
        if (![PhoneNumbers isValid:normalized]) { return; }
        
        if ([PhoneNumbers isUSPhoneNumber:normalized] && normalized.length == 12) {
            handler(normalized);
        }

    }];
}

@end
