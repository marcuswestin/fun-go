//
//  ViewController.m
//  Dogo-iOS
//
//  Created by Marcus Westin on 6/26/13.
//  Copyright (c) 2013 Flutterby Labs Inc. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

@synthesize state;

+ (instancetype)make {
    return [self makeWithState:@{}];
}

+ (instancetype)makeWithState:(NSDictionary *)state {
    ViewController* viewController = [[self.class alloc] init];
    viewController.state = state ? state : @{};
    return viewController;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
