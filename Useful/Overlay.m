//
//  Overlay.m
//  Dogo-iOS
//
//  Created by Marcus Westin on 6/28/13.
//  Copyright (c) 2013 Flutterby Labs Inc. All rights reserved.
//

#import "Overlay.h"
#import "FunAll.h"

@implementation Overlay

static UIWindow* overlayWindow;
static UIWindow* previousWindow;

+ (UIWindow *)show {
    [Overlay hide];
    previousWindow = [UIApplication sharedApplication].keyWindow;
    previousWindow.opaque = YES;
    
    overlayWindow = [[UIWindow alloc] initWithFrame:previousWindow.frame];
    overlayWindow.windowLevel = UIWindowLevelStatusBar + 1;
    [overlayWindow makeKeyAndVisible];
    [overlayWindow onTap:^(UITapGestureRecognizer *sender) {
        [Overlay hide];
    }];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage* blur = [Overlay snapshotUnderlayWithBlur:fuzzyBlurBlur];
        dispatch_async(dispatch_get_main_queue(), ^{
            UIImageView* blurView = [[UIImageView alloc] initWithFrame:CGRectInset(overlayWindow.bounds, -20, -20)];
            blurView.image = blur;
            blurView.alpha = 0;
            [overlayWindow insertSubview:blurView atIndex:0];
            [UIView animateWithDuration:0.3 animations:^{
                blurView.alpha = 1;
            }];
        });
    });
    
    return overlayWindow;
}

//static CGFloat pixelatedBlurScale = 0.5;
//static CGFloat pixelatedBlurBlur = 1.5;
static CGFloat fuzzyBlurScale = 0.125;
static CGFloat fuzzyBlurBlur = 2.0;

+ (UIImage *)snapshotUnderlayWithBlur:(CGFloat)radius {
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *inputImage = [CIImage imageWithCGImage:[previousWindow captureToImageWithScale:fuzzyBlurScale].CGImage];
    
    CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur"];
    [filter setValue:inputImage forKey:kCIInputImageKey];
    [filter setValue:[NSNumber numberWithFloat:radius] forKey:@"inputRadius"];
    CIImage *result = [filter valueForKey:kCIOutputImageKey];
    
    // CIGaussianBlur has a tendency to shrink the image a little,
    // this ensures it matches up exactly to the bounds of our original image
    CGImageRef cgImage = [context createCGImage:result fromRect:[inputImage extent]];
    return [UIImage imageWithCGImage:cgImage];

}

+ (UIWindow*)showMessage:(NSString *)message {
    [Overlay show];
    UILabel* label = [[UILabel alloc] initWithFrame:overlayWindow.frame];
    label.text = message;
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = WHITE;
    [overlayWindow addSubview:label];
    return overlayWindow;
}

+ (void)hide {
    if (!overlayWindow) { return; }
    UIWindow* _overlayWindow = overlayWindow;
    UIWindow* _previousWindow = previousWindow;
    overlayWindow = nil;
    previousWindow = nil;

    [UIView animateWithDuration:0.25 animations:^{
        _overlayWindow.alpha = 0;
    } completion:^(BOOL finished) {
        [_overlayWindow setHidden:YES];
        [_previousWindow makeKeyAndVisible];
    }];
}

@end
