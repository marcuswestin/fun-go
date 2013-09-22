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
        view.editable = NO;
        [view sizeToFit];
        [view center];
    });
}

void after(NSTimeInterval delayInSeconds, Block block) {
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), block);
}

void every(NSTimeInterval intervalInSeconds, Block block) {
    after(intervalInSeconds, ^{
        block();
        every(intervalInSeconds, block);
    });
}

void asyncDefault(Block block) {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), block);
}
void asyncHigh(Block block) {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), block);
}
void asyncLow(Block block) {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), block);
}
void asyncMain(Block block) {
    dispatch_async(dispatch_get_main_queue(), block);
}
void asyncBackground(Block block) {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), block);
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

NSNumber* num(int i) { return [NSNumber numberWithInt:i]; }
NSNumber* numf(float f) { return [NSNumber numberWithFloat:f]; }

void repeat(NSUInteger times, NSUIntegerBlock block) {
    for (NSUInteger i=0; i<times; i++) {
        block(i);
    }
}

NSError* makeError(NSString* localMessage) {
    return [NSError errorWithDomain:@"Global" code:1 userInfo:@{ NSLocalizedDescriptionKey:localMessage }];
}
