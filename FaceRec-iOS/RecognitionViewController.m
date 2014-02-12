//
//  RecognitionViewController.m
//  FaceRec-iOS
//
//  Created by ZHAO QIAN on 2/5/14.
//  Copyright (c) 2014 Charles Wang. All rights reserved.
//

#import "RecognitionViewController.h"

@interface RecognitionViewController ()

@end

@implementation RecognitionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    AVCaptureSession *session = [[AVCaptureSession alloc]init];
    [session setSessionPreset:AVCaptureSessionPreset1280x720];
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *error = nil;
    AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    [session addInput:deviceInput];
    _videoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
    [_videoDataOutput setAlwaysDiscardsLateVideoFrames:YES];
    _videoDataOutputQueue = dispatch_queue_create("VideoDataOutputQueue", DISPATCH_QUEUE_SERIAL);
    [_videoDataOutput setSampleBufferDelegate:self queue:_videoDataOutputQueue];
    [session addOutput:_videoDataOutput];
    _previewLayer = [[AVCaptureVideoPreviewLayer alloc]initWithSession:session];
    [_previewLayer setVideoGravity:AVLayerVideoGravityResizeAspect];
    CALayer *rootLayer = [_preview layer];
    [rootLayer setMasksToBounds:YES];
    [_previewLayer setFrame:[rootLayer bounds]];
    [rootLayer addSublayer:_previewLayer];
    
    NSDictionary *detectorOptions = [[NSDictionary alloc] initWithObjectsAndKeys:CIDetectorAccuracyLow, CIDetectorAccuracy, @YES, CIDetectorTracking, nil];
    _faceDetector = [CIDetector detectorOfType:CIDetectorTypeFace context:nil options:detectorOptions];
    
    //_lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 200, self.view.bounds.size.width, 1)];
    //_lineView.backgroundColor = [UIColor whiteColor];
    //[self.view addSubview:_lineView];
    
    [session startRunning];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void) captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CFDictionaryRef attachments = CMCopyDictionaryOfAttachments(kCFAllocatorDefault, sampleBuffer, kCMAttachmentMode_ShouldPropagate);
    CIImage *ciImage = [[CIImage alloc] initWithCVPixelBuffer:pixelBuffer options:(__bridge NSDictionary *)attachments];
    
    NSArray *features = [_faceDetector featuresInImage:ciImage];
    
    NSLog(@"here");
    if([features count] > 0)
    {
        NSLog(@"Count:%d",[features count]);
        for(int i = 0; i < [features count]; i++)
        {
            NSLog(@"TrackingID: %d",[[features objectAtIndex:i] trackingID]);
            NSLog(@"FrameCount: %d",[[features objectAtIndex:i] trackingFrameCount]);
        }
        NSLog(@"----");
        //        _lineView.backgroundColor = [UIColor whiteColor];
        //        [self.view addSubview:_lineView];
    }
    
}

@end
