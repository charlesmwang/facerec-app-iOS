//
//  FRCameraViewController.h
//  FaceRec-iOS
//
//  Created by Charles Wang on 11/12/14.
//  Copyright (c) 2014 Charles Wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface FRCameraViewController : UIViewController

@property (strong, readonly, nonatomic) AVCaptureSession *session;

- (void)setupPreview:(UIView *)preview;
- (NSArray *)extractFaceFeaturesFromImageBuffer:(CMSampleBufferRef)imageBuffer;
- (AVCaptureDevice *)camera:(AVCaptureDevicePosition) devicePosition;
- (void)adjustPreviewLayerFrameForView:(UIView *)view;
- (void)switchCamera;

@end
