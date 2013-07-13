//
//  FunBase.m
//  Dogo-iOS
//
//  Created by Marcus Westin on 6/25/13.
//  Copyright (c) 2013 Flutterby Labs Inc. All rights reserved.
//

#import "FunBase.h"
#import "Overlay.h"
#import <objc/runtime.h>

@implementation FunBase

static bool hasSetup = NO;

+ (void)setup {
    if (hasSetup) { return; }
    hasSetup = YES;
    
    NSLog(@"FunBase setup: Start!");
    clock_t start = clock();
    
    int numClasses = objc_getClassList(NULL, 0);
    Class *classes = NULL;
    
    classes = (__unsafe_unretained Class *)malloc(sizeof(Class) * numClasses);
    numClasses = objc_getClassList(classes, numClasses);
    
    for (NSInteger i = 0; i < numClasses; i++) {
        Class superClass = classes[i];
        do {
            superClass = class_getSuperclass(superClass);
        } while(superClass && superClass != FunBase.class);
        
        if (superClass == nil) {
            continue;
        }
        
        NSLog(@"FunBase setup: %s", class_getName(classes[i]));
        [classes[i] setup];
    }
    
    free(classes);

    double executionTime = (double)(clock()-start) / CLOCKS_PER_SEC;
    NSLog(@"FunBase setup: Done! Took %f(s)", executionTime);
}

@end
