//
//  RecognitionViewController.h
//  FaceRec-iOS
//
//  Created by ZHAO QIAN on 2/5/14.
//  Copyright (c) 2014 Charles Wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface RecognitionViewController : UIViewController <AVCaptureVideoDataOutputSampleBufferDelegate>{


    //IBOutlet UIView *previewView;
	IBOutlet UISegmentedControl *camerasControl;
	//AVCaptureVideoPreviewLayer *previewLayer;
	//AVCaptureVideoDataOutput *videoDataOutput;
	BOOL detectFaces;
    BOOL timercontrol;
	//dispatch_queue_t videoDataOutputQueue;
	AVCaptureStillImageOutput *stillImageOutput;
	UIView *flashView;
	UIImage *square;
	BOOL isUsingFrontFacingCamera;
	//CIDetector *previewLayer;
	CGFloat beginGestureScale;
	CGFloat effectiveScale;
    //NSTimer *timer;
    UIAlertView* alertNameView;
    NSMutableString *m_string;


}


@property (strong, nonatomic) IBOutlet UIView *preview;
@property (nonatomic, strong) dispatch_queue_t videoDataOutputQueue;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic, strong) AVCaptureVideoDataOutput *videoDataOutput;
@property (nonatomic, strong) CIDetector *faceDetector;




- (IBAction)switchCameras:(id)sender;



@end
