//
//  FRCameraViewController.m
//  FaceRec-iOS
//
//  Created by Charles Wang on 1/29/14.
//  Copyright (c) 2014 Charles Wang. All rights reserved.
//

#import "FRCameraViewController.h"

#import "FRPerson.h"
#import "FRUser.h"

#import "FRCaptureFaceUtilities.h"
#import "FRFaceUtilities.h"

#import "UIImage+RotationMethods.h"
#import "UIImage+ConversionHelper.h"

typedef NS_ENUM(NSInteger, PHOTOS_EXIF)
{
    PHOTOS_EXIF_0ROW_TOP_0COL_LEFT          = 1, //   1  =  0th row is at the top, and 0th column is on the left (THE DEFAULT).
    PHOTOS_EXIF_0ROW_TOP_0COL_RIGHT         = 2, //   2  =  0th row is at the top, and 0th column is on the right.
    PHOTOS_EXIF_0ROW_BOTTOM_0COL_RIGHT      = 3, //   3  =  0th row is at the bottom, and 0th column is on the right.
    PHOTOS_EXIF_0ROW_BOTTOM_0COL_LEFT       = 4, //   4  =  0th row is at the bottom, and 0th column is on the left.
    PHOTOS_EXIF_0ROW_LEFT_0COL_TOP          = 5, //   5  =  0th row is on the left, and 0th column is the top.
    PHOTOS_EXIF_0ROW_RIGHT_0COL_TOP         = 6, //   6  =  0th row is on the right, and 0th column is the top.
    PHOTOS_EXIF_0ROW_RIGHT_0COL_BOTTOM      = 7, //   7  =  0th row is on the right, and 0th column is the bottom.
    PHOTOS_EXIF_0ROW_LEFT_0COL_BOTTOM       = 8  //   8  =  0th row is on the left, and 0th column is the bottom.
};

static const AVCaptureDevicePosition kDefaultCaptureDevicePosition = AVCaptureDevicePositionFront;

@interface FRCameraViewController () <AVCaptureVideoDataOutputSampleBufferDelegate>

@property (strong, readwrite, nonatomic) AVCaptureSession *session;
@property (strong, nonatomic) AVCaptureVideoPreviewLayer *previewLayer;
@property (assign, readwrite, nonatomic) AVCaptureDevicePosition currentCaptureDevicePosition;
@property (strong, nonatomic) AVCaptureDeviceInput *currentCaptureDeviceInput;

@property (strong, nonatomic) dispatch_queue_t videoDataOutputQueue;
@property (strong, nonatomic) AVCaptureVideoDataOutput *videoDataOutput;
@property (strong, nonatomic) CIDetector *faceDetector;
@property (strong, nonatomic) CIFaceFeature *faceFeature;
@property (strong, nonatomic) UIAlertView* alertView;

@end

@implementation FRCameraViewController


#pragma mark - View Controller Event Methods

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    [self.session stopRunning];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    UIDevice *device = [UIDevice currentDevice];
    [device beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRotateCamera:) name:UIDeviceOrientationDidChangeNotification object:device];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self setupRequiredComponents];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Setup

- (void)setupRequiredComponents
{
    [self setupCamera];
    [self setupFaceDetector];
}

- (void)setupCamera
{
    // Do any additional setup after loading the view.
    self.session = [[AVCaptureSession alloc] init];
    self.session.sessionPreset = AVCaptureSessionPresetMedium;
    AVCaptureDevice *device = [self camera:kDefaultCaptureDevicePosition];
    self.currentCaptureDevicePosition = kDefaultCaptureDevicePosition;
    NSError *error = nil;
    self.currentCaptureDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    [self.session addInput:self.currentCaptureDeviceInput];
    self.videoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
    [self.videoDataOutput setAlwaysDiscardsLateVideoFrames:YES];
    self.videoDataOutputQueue = dispatch_queue_create("VideoDataOutputQueue", DISPATCH_QUEUE_SERIAL);
    [self.videoDataOutput setSampleBufferDelegate:self queue:self.videoDataOutputQueue];
    [self.session addOutput:self.videoDataOutput];
}

- (void)setupPreview:(UIView *)preview
{
    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc]initWithSession:self.session];
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [preview.layer addSublayer:self.previewLayer];
    [self adjustPreviewLayerFrameForView:preview];
}

- (void)setupFaceDetector
{
    NSDictionary *detectorOptions = @{
                                      CIDetectorAccuracy : CIDetectorAccuracyHigh,
                                      CIDetectorTracking : @YES
                                      };
    
    self.faceDetector = [CIDetector detectorOfType:CIDetectorTypeFace context:nil options:detectorOptions];
}



#pragma mark - Camera Helper Methods

- (AVCaptureDevice *)camera:(AVCaptureDevicePosition) devicePosition
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices)
    {
        if ([device position] == devicePosition)
        {
            self.currentCaptureDevicePosition = devicePosition;
            return device;
        }
    }
    return nil;
}

- (void)adjustPreviewLayerFrameForView:(UIView *)view
{
    UIDevice *device = [UIDevice currentDevice];
    AVCaptureConnection *previewLayerConnection = self.previewLayer.connection;
    
    switch ([device orientation])
    {
        case UIDeviceOrientationPortrait:
            previewLayerConnection.videoOrientation = AVCaptureVideoOrientationPortrait;
            break;
        case UIDeviceOrientationLandscapeLeft:
            previewLayerConnection.videoOrientation = AVCaptureVideoOrientationLandscapeRight;
            break;
        case UIDeviceOrientationLandscapeRight:
            previewLayerConnection.videoOrientation = AVCaptureVideoOrientationLandscapeLeft;
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            previewLayerConnection.videoOrientation = AVCaptureVideoOrientationPortraitUpsideDown;
            break;
        default:
            break;
    }
    
    self.previewLayer.frame = view.bounds;
}


#pragma mark - Camera Helper

- (void)switchCamera
{
    [self.session beginConfiguration];
    AVCaptureDevice *device;
    switch (self.currentCaptureDevicePosition)
    {
        case AVCaptureDevicePositionFront:
            device = [self camera:AVCaptureDevicePositionBack];
            break;
        case AVCaptureDevicePositionBack:
            device = [self camera:AVCaptureDevicePositionFront];
            break;
        default:
            break;
    }
    NSError *error;
    [self.session removeInput:self.currentCaptureDeviceInput];
    self.currentCaptureDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    [self.session addInput:self.currentCaptureDeviceInput];
    [self.session commitConfiguration];
}


#pragma mark - Notifications
- (void)didRotateCamera:(NSNotification *)notification
{

}

#pragma mark - Helper Methods

- (NSInteger)determineExifOrientationByDeviceOrientation
{
    UIDeviceOrientation deviceOrientation = [[UIDevice currentDevice] orientation];
    NSInteger exifOrientation = 0;
    switch (deviceOrientation)
    {
        case UIDeviceOrientationPortraitUpsideDown:  // Device oriented vertically, home button on the top
        {
            exifOrientation = PHOTOS_EXIF_0ROW_LEFT_0COL_BOTTOM;
            break;
        }
        case UIDeviceOrientationLandscapeLeft:       // Device oriented horizontally, home button on the right
        {
            if (self.currentCaptureDevicePosition == AVCaptureDevicePositionFront)
            {
                exifOrientation = PHOTOS_EXIF_0ROW_BOTTOM_0COL_RIGHT;
            }
            else
            {
                exifOrientation = PHOTOS_EXIF_0ROW_TOP_0COL_LEFT;
            }
            break;
        }
        case UIDeviceOrientationLandscapeRight:      // Device oriented horizontally, home button on the left
        {
            if (self.currentCaptureDevicePosition == AVCaptureDevicePositionFront)
            {
                exifOrientation = PHOTOS_EXIF_0ROW_TOP_0COL_LEFT;
            }
            else
            {
                exifOrientation = PHOTOS_EXIF_0ROW_BOTTOM_0COL_RIGHT;
            }
            break;
        }
        case UIDeviceOrientationPortrait:            // Device oriented vertically, home button on the bottom
        default:
        {
            exifOrientation = PHOTOS_EXIF_0ROW_RIGHT_0COL_TOP;
            break;
        }
    }
    return exifOrientation;
}

- (CGRect)faceBoundFromFaceFeatureBounds:(CGRect)faceFeatureBounds faceImageSize:(CGSize)imageSize
{
    CGRect modifiedFaceBounds = faceFeatureBounds;
    modifiedFaceBounds.origin.y = imageSize.height-faceFeatureBounds.size.height-faceFeatureBounds.origin.y;
    
    CGFloat xscale = 0.75f;
    CGFloat xshift = (xscale - 1.0f)/2.0f * modifiedFaceBounds.size.width;
    modifiedFaceBounds.size.width *= xscale;
    modifiedFaceBounds.origin.x -= xshift;
    
    CGFloat yscale = 0.62f;
    CGFloat yshift = (yscale - 1.0f)/2.0f * modifiedFaceBounds.size.height;
    modifiedFaceBounds.size.height *= yscale;
    modifiedFaceBounds.origin.y -= yshift;
    
    return modifiedFaceBounds;
}

- (CIImage *)createCIImageFromImageBuffer:(CMSampleBufferRef)imageBuffer
{
    CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(imageBuffer);
    CFDictionaryRef attachments = CMCopyDictionaryOfAttachments(kCFAllocatorDefault, imageBuffer, kCMAttachmentMode_ShouldPropagate);
    NSDictionary *dAttachments = (NSDictionary *)CFBridgingRelease(attachments);
    CIImage *ciImage = [[CIImage alloc] initWithCVPixelBuffer:pixelBuffer options:dAttachments];
    
    //Cleanup
    attachments = NULL;
    pixelBuffer = NULL;
    
    return ciImage;
}

- (NSArray *)extractFaceFeaturesFromImageBuffer:(CMSampleBufferRef)imageBuffer
{
    CIImage *ciImage = [self createCIImageFromImageBuffer:imageBuffer];
    NSInteger exifOrientation = [self determineExifOrientationByDeviceOrientation];
    
    NSDictionary *imageOptions = @{
                                   CIDetectorImageOrientation:@(exifOrientation)
                                   };
    
    return [self.faceDetector featuresInImage:ciImage options:imageOptions];
}


@end
