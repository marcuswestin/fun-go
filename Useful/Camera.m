//
//  Camera.m
//  Dogo-iOS
//
//  Created by Marcus Westin on 7/9/13.
//  Copyright (c) 2013 Flutterby Labs Inc. All rights reserved.
//

#import "Camera.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import <AVFoundation/AVFoundation.h>

@implementation Camera

static Camera* camera;

+ (void)showCameraForPhotoInView:(UIView *)inView
                  device:(UIImagePickerControllerCameraDevice)device
               flashMode:(UIImagePickerControllerCameraFlashMode)flashMode
      showCameraControls:(BOOL)showCameraControls
             saveToAlbum:(BOOL)saveToAlbum
                callback:(CameraCaptureCallback)callback
{
    [self _showCameraInView:inView device:device flashMode:flashMode quality:0 maxDuration:0 showCameraControls:showCameraControls saveToAlbum:saveToAlbum callback:callback captureMode:UIImagePickerControllerCameraCaptureModePhoto];
}

+ (void)showCameraForVideoInView:(UIView *)inView
                          device:(UIImagePickerControllerCameraDevice)device
                       flashMode:(UIImagePickerControllerCameraFlashMode)flashMode
                         quality:(UIImagePickerControllerQualityType)quality
                     maxDuration:(NSTimeInterval)maxDuration
              showCameraControls:(BOOL)showCameraControls
                     saveToAlbum:(BOOL)saveToAlbum
                        callback:(CameraCaptureCallback)callback
{
    [self _showCameraInView:inView device:device flashMode:flashMode quality:quality maxDuration:maxDuration showCameraControls:showCameraControls saveToAlbum:saveToAlbum callback:callback captureMode:UIImagePickerControllerCameraCaptureModeVideo];
}

+ (void)_showCameraInView:(UIView *)inView
                  device:(UIImagePickerControllerCameraDevice)device
               flashMode:(UIImagePickerControllerCameraFlashMode)flashMode
                 quality:(UIImagePickerControllerQualityType)quality
             maxDuration:(NSTimeInterval)maxDuration
      showCameraControls:(BOOL)showCameraControls
             saveToAlbum:(BOOL)saveToAlbum
                callback:(CameraCaptureCallback)callback
             captureMode:(UIImagePickerControllerCameraCaptureMode)captureMode
{
    [Camera _reset:callback modalViewController:nil];
    camera.saveToAlbum = saveToAlbum;
    
    camera.picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    if ([UIImagePickerController isCameraDeviceAvailable:device]) {
        camera.picker.cameraDevice = device;
    }
    
    if (captureMode == UIImagePickerControllerCameraCaptureModeVideo) {
        camera.picker.videoQuality = quality;
        camera.picker.mediaTypes = @[(NSString*)kUTTypeMovie];
        camera.picker.videoMaximumDuration = maxDuration;
    }
    
    camera.picker.cameraCaptureMode = captureMode;
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
    camera.picker.delegate = camera;
    camera.callback = callback;
    camera.modalViewController = modalViewController;
}

/* Delegate
 **********/
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    if ([info[UIImagePickerControllerMediaType] isEqualToString:(NSString *)kUTTypeMovie]) {
        [self _handleCapturedVideo:info];
    } else {
        [self _handleCapturedPicture:info];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    self.callback(nil, nil);
}

- (void) _handleCapturedVideo:(NSDictionary*)info {
    NSURL* videoUrl = info[UIImagePickerControllerMediaURL];
    if (self.saveToAlbum) {
        UISaveVideoAtPathToSavedPhotosAlbum(videoUrl.path, nil, nil, nil);
    }
    
    AVAsset* videoAsset = [AVAsset assetWithURL:videoUrl];
    AVAssetTrack* videoTrack = [videoAsset tracksWithMediaType:AVMediaTypeVideo][0];
    CGSize videoSize = [videoTrack naturalSize];
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:videoAsset];
    CMTime cmDuration = playerItem.duration;
    float durationInSeconds = CMTimeGetSeconds(cmDuration);
    
    self.callback(nil, @{@"type":@"video",
                         @"path":videoUrl.path,
                         @"duration":[NSNumber numberWithFloat:durationInSeconds],
                         @"width":num(videoSize.width),
                         @"height":num(videoSize.height),
                         @"asset":videoAsset,
                         @"playerItem":playerItem });
}

- (void)_handleCapturedPicture:(NSDictionary*)info {
    if (self.saveToAlbum) {
        UIImageWriteToSavedPhotosAlbum(info[UIImagePickerControllerOriginalImage], nil, nil, nil);
    }
    UIImage* image = info[(self.picker.allowsEditing ? UIImagePickerControllerEditedImage : UIImagePickerControllerOriginalImage)];
    
    self.callback(nil, @{@"type":@"picture",
                         @"image":image });
}

+ (UIImage*)thumbnailForVideoResult:(NSDictionary*)videoResult atTime:(double)time {
    AVAsset* videoAsset = videoResult[@"asset"];
    float durationInSeconds = [videoResult[@"duration"] floatValue];
    AVPlayerItem *playerItem = videoResult[@"playerItem"];

    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:videoAsset];
    imageGenerator.appliesPreferredTrackTransform = YES;
    
    if (time > durationInSeconds) { time = durationInSeconds; }
    CMTime thumbTime = CMTimeMakeWithSeconds(time, playerItem.duration.timescale);
    
    NSError *error = nil;
    CGImageRef imageRef = [imageGenerator copyCGImageAtTime:thumbTime actualTime:NULL error:&error];
    if (error) { return nil; }
    UIImage *thumbImage = [[UIImage alloc] initWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    return thumbImage;
}

@end
