//
//  ViewController.m
//  Dogo-iOS
//
//  Created by Marcus Westin on 6/26/13.
//  Copyright (c) 2013 Flutterby Labs Inc. All rights reserved.
//

#import "ViewController.h"
#import "FunObjc.h"

@implementation ViewController {
    BOOL _didRender;
}

+ (instancetype)withoutState {
    return [[[self class] alloc] initWithState:nil];
}

- (instancetype)initWithState:(id<NSCoding>)state {
    if (self = [super initWithNibName:nil bundle:nil]) {
        self.state = state;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    [self decodeRestorableStateWithCoder:coder];
    return self;
}

- (NSString *)restorationIdentifier {
    return self.className;
}

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder {
    [super encodeRestorableStateWithCoder:coder];
    [coder encodeObject:self.title forKey:@"FunVCTitle"];
    [coder encodeObject:self.state forKey:@"FunVCState"];
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder {
    [super decodeRestorableStateWithCoder:coder];
    self.title = [coder decodeObjectForKey:@"FunVCTitle"];
    self.state = [coder decodeObjectForKey:@"FunVCState"];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (_didRender) { return; }
    _didRender = YES;
    self.view.backgroundColor = WHITE;
    [self beforeRender:animated];
    [self render:animated];
    [self afterRender:animated];
}

- (void)beforeRender:(BOOL)animated{} // Private hook - see e.g. ListViewController
- (void)render:(BOOL)animated {
    NSLog(@"%@ must implement - (void)render:(BOOL)animated{}", self.className);
    [NSException raise:@"NotImplemented" format:@"Please implement ViewController render:(BOOL)animated{}"];
}
- (void)afterRender:(BOOL)animated{} // Private hook - see e.g. ListViewController

- (void)pushViewController:(ViewController *)viewController {
    if ([self.parentViewController isKindOfClass:[UINavigationController class]]) {
        [(UINavigationController*)self.parentViewController pushViewController:viewController animated:YES];
    } else {
        [NSException raise:@"" format:@"pushViewController:animated: called on ViewController without a UINavigationController parent"];
    }
}

@end
