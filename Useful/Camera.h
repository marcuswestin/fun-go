//
//  Camera.h
//  Dogo-iOS
//
//  Created by Marcus Westin on 7/9/13.
//  Copyright (c) 2013 Flutterby Labs Inc. All rights reserved.
//

#import "FunBase.h"

typedef void (^CameraCaptureCallback)(NSError* err, id result);

@interface Camera : FunBase
@property UIImagePickerController* picker;
@property (strong) CameraCaptureCallback callback;
@property UIViewController* modalViewController;


//+ (void)showModalVideoCaptureAnimated:(BOOL)animated
//                              quality:(UIImagePickerControllerQualityType)quality
//                             callback:(CameraCaptureCallback)callback;
//
//+ (void)showModalPictureCaptureAnimated:(BOOL)animated
//                               callback:(CameraCaptureCallback)callback;
//
+ (void)showModalPickerInViewController:(UIViewController*)viewController
                             sourceType:(UIImagePickerControllerSourceType)sourceType
                           allowEditing:(BOOL)allowEditing
                               animated:(BOOL)animated
                               callback:(CameraCaptureCallback)callback
;

+ (void)showCameraCaptureInView:(UIView *)inView
                         device:(UIImagePickerControllerCameraDevice)device
                      flashMode:(UIImagePickerControllerCameraFlashMode)flashMode
             showCameraControls:(BOOL)showCameraControls
                       callback:(CameraCaptureCallback)callback
;

+ (void)hide;

@end
