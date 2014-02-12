//
//  RecognitionViewController.h
//  FaceRec-iOS
//
//  Created by ZHAO QIAN on 2/5/14.
//  Copyright (c) 2014 Charles Wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface RecognitionViewController : UIViewController <AVCaptureVideoDataOutputSampleBufferDelegate>


@property (strong, nonatomic) IBOutlet UIView *preview;
@property (nonatomic, strong) dispatch_queue_t videoDataOutputQueue;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic, strong) AVCaptureVideoDataOutput *videoDataOutput;
@property (nonatomic, strong) CIDetector *faceDetector;


@end
