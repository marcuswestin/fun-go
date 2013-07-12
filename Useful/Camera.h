//
//  Camera.h
//  Dogo-iOS
//
//  Created by Marcus Westin on 7/9/13.
//  Copyright (c) 2013 Flutterby Labs Inc. All rights reserved.
//

#import "FunBase.h"

typedef void (^CameraCaptureCallback)(NSError* err, NSDictionary* result);

@interface Camera : FunBase <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property UIImagePickerController* picker;
@property (strong) CameraCaptureCallback callback;
@property UIViewController* modalViewController;
@property BOOL saveToAlbum;
@property BOOL allowsEditing;

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

+ (void)showCameraForPhotoInView:(UIView *)inView
                         device:(UIImagePickerControllerCameraDevice)device
                      flashMode:(UIImagePickerControllerCameraFlashMode)flashMode
             showCameraControls:(BOOL)showCameraControls
                    saveToAlbum:(BOOL)saveToAlbum
                       callback:(CameraCaptureCallback)callback
;

+ (void)showCameraForVideoInView:(UIView *)inView
                          device:(UIImagePickerControllerCameraDevice)device
                       flashMode:(UIImagePickerControllerCameraFlashMode)flashMode
                         quality:(UIImagePickerControllerQualityType)quality
                     maxDuration:(NSTimeInterval)maxDuration
              showCameraControls:(BOOL)showCameraControls
                     saveToAlbum:(BOOL)saveToAlbum
                        callback:(CameraCaptureCallback)callback
;

+ (void)hide;

+ (UIImage*)thumbnailForVideoResult:(NSDictionary*)videoResult atTime:(double)time;

@end
