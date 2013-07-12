//
//  Camera.m
//  Dogo-iOS
//
//  Created by Marcus Westin on 7/9/13.
//  Copyright (c) 2013 Flutterby Labs Inc. All rights reserved.
//

#import "Camera.h"

@implementation Camera

static Camera* camera;

+ (void)showCameraCaptureInView:(UIView *)inView
                         device:(UIImagePickerControllerCameraDevice)device
                      flashMode:(UIImagePickerControllerCameraFlashMode)flashMode
             showCameraControls:(BOOL)showCameraControls
                       callback:(CameraCaptureCallback)callback
{
    [Camera _reset:callback modalViewController:nil];
    
    camera.picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    if ([UIImagePickerController isCameraDeviceAvailable:device]) {
        camera.picker.cameraDevice = device;
    }
    camera.picker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
    camera.picker.cameraFlashMode = flashMode;
    camera.picker.showsCameraControls = showCameraControls;
    
    camera.picker.view.frame = CGRectMake(0, 0, inView.frame.size.width, inView.frame.size.height);
    [inView addSubview:camera.picker.view];
}

+ (void)showModalPickerInViewController:(UIViewController*)viewController
                             sourceType:(UIImagePickerControllerSourceType)sourceType
                           allowEditing:(BOOL)allowEditing
                               animated:(BOOL)animated
                               callback:(CameraCaptureCallback)callback
{
    [Camera _reset:callback modalViewController:viewController];
    
    camera.picker.sourceType = sourceType;
    camera.picker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:sourceType];
    camera.picker.allowsEditing = allowEditing;
    
    [viewController presentViewController:camera.picker animated:animated completion:nil];
}

+ (void)hide {
    if (!camera) { return; }
    
    if (camera.modalViewController) {
        [camera.modalViewController dismissViewControllerAnimated:YES completion:nil];
    } else {
        [camera.picker.view removeFromSuperview];
    }

    camera = nil;
}

/* Internal
 **********/
+ (void) _reset:(CameraCaptureCallback)callback modalViewController:(UIViewController*)modalViewController {
    if (camera) { [Camera hide]; }
    
    camera = [[Camera alloc] init];
    camera.picker = [[UIImagePickerController alloc] init];
    camera.callback = callback;
    camera.modalViewController = modalViewController;
}

@end
