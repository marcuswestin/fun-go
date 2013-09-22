//
//  ViewController.m
//  Dogo-iOS
//
//  Created by Marcus Westin on 6/26/13.
//  Copyright (c) 2013 Flutterby Labs Inc. All rights reserved.
//

#import "ViewController.h"
//#import <objc/runtime.h>

@implementation ViewController

- (instancetype)initWithState:(State *)state {
    self = [super init];
    [self performSelector:@selector(setState:) withObject:state];
    return self;
}

- (NSString*) restorationIdentifier {
    if (![self respondsToSelector:@selector(state)]) { return nil; }
    return NSStringFromClass(self.class);
}

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder {
    if (![self respondsToSelector:@selector(state)]) { return; }
    State* state = [self performSelector:@selector(state) withObject:nil];
    [state encodeWithCoder:coder];
}

@end
