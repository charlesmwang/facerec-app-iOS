//
//  CaptureFaceViewController.h
//  FaceRec-iOS
//
//  Created by Charles Wang on 2/15/14.
//  Copyright (c) 2014 Charles Wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "Person.h"
#import "User.h"
#import "FaceRecServer.h"

@interface CaptureFaceViewController : UIViewController <AVCaptureVideoDataOutputSampleBufferDelegate, NSURLConnectionDelegate>

@property (strong, nonatomic) IBOutlet UIView *preview;
@property (nonatomic, strong) dispatch_queue_t videoDataOutputQueue;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic, strong) AVCaptureVideoDataOutput *videoDataOutput;
@property (nonatomic, strong) CIDetector *faceDetector;
@property (nonatomic, assign) BOOL isUsingFrontFacingCamera;
@property (nonatomic, strong) NSArray *features;
@property (nonatomic, strong) CIFaceFeature *faceFeature;
@property (nonatomic, strong) Person* person;
@property (nonatomic, strong) UIAlertView* alertView;
@property (strong, nonatomic) NSMutableData *responseData;
@property (strong, nonatomic) NSHTTPURLResponse *headerResponse;
@property (strong, nonatomic) NSDictionary *jsonResponse;
@property (assign, nonatomic) int fcounter;
@property (assign, nonatomic) int picTaken;
@property (strong, nonatomic) AVCaptureSession *session;
@end
