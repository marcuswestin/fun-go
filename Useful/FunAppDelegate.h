//
//  FunAppDelegate.h
//  Dogo-iOS
//
//  Created by Marcus Westin on 7/13/13.
//  Copyright (c) 2013 Flutterby Labs Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewController.h"

@protocol FunApp <NSObject>
- (void)interfaceWillLoad;
- (ViewController*)rootViewControllerForFreshLoad;
- (void)interfaceDidLoad;
@end

@interface FunAppDelegate : UIResponder<UIApplicationDelegate, FunApp>

@property (strong, nonatomic) UIWindow *window;

@end
