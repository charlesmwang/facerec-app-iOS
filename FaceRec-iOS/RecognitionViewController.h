//
//  RecognitionViewController.h
//  FaceRec-iOS
//
//  Created by Charles Wang on 1/29/14.
//  Copyright (c) 2014 Charles Wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "SocketIOPacket.h"
#import "SocketIO.h"
#import "Person.h"
#import "User.h"
#import "FaceRecServer.h"

@interface RecognitionViewController : UIViewController <AVCaptureVideoDataOutputSampleBufferDelegate, SocketIODelegate, NSURLConnectionDelegate>
@property (strong, nonatomic) IBOutlet UIView *preview;
@property (nonatomic, strong) dispatch_queue_t videoDataOutputQueue;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic, strong) AVCaptureVideoDataOutput *videoDataOutput;
@property (nonatomic, strong) CIDetector *faceDetector;
@property(nonatomic, strong) SocketIO* socket;
@property (nonatomic, assign) BOOL isUsingFrontFacingCamera;
@property (nonatomic, strong) NSArray *features;
@property (nonatomic, strong) CIFaceFeature *faceFeature;
@property (strong, nonatomic) NSHTTPURLResponse *headerResponse;
@property (strong, nonatomic) NSMutableDictionary *recognized;
@property (assign, nonatomic) int faceCounter;

@end
