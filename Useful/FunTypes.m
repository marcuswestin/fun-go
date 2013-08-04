//
//  FunTypes.m
//  Dogo-iOS
//
//  Created by Marcus Westin on 7/13/13.
//  Copyright (c) 2013 Flutterby Labs Inc. All rights reserved.
//

#import "FunTypes.h"
#import <AudioToolbox/AudioToolbox.h>
#import "Overlay.h"
#import "Viewport.h"

#include <stdio.h>

void error(NSError* err) {
    if (!err) { return; }
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString* message = err.localizedDescription;
        NSLog(@"ERROR %@ %@", message, err);
        UITextView* view = [UITextView.appendTo([Overlay show]).w(Viewport.width) render];
        [view setText:message];
        view.backgroundColor = TRANSPARENT;
        view.textColor = RED;
        [view sizeToFit];
        [view centerInSuperview];
    });
}

UIColor* rgba(NSUInteger r, NSUInteger g, NSUInteger b, CGFloat a) {
    return [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a];
}
UIColor* rgb(NSUInteger r, NSUInteger g, NSUInteger b) {
    return rgba(r, g, b, 1.0);
}

void after(CGFloat delayInSeconds, Block block) {
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), block);
}

void vibrateDevice() {
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}

NSString* concat(NSString* firstArg, ...) {
    NSMutableString *result = [NSMutableString string];
    va_list args;
    va_start(args, firstArg);
    for (NSString *arg = firstArg; arg != nil; arg = va_arg(args, NSString*)) {
        [result appendString:arg];
    }
    va_end(args);
    return result;
}

NSNumber* num(NSInteger i) { return [NSNumber numberWithInt:i]; }

NSError* makeError(NSString* localMessage) {
    return [NSError errorWithDomain:@"Global" code:1 userInfo:@{ NSLocalizedDescriptionKey:localMessage }];
}
