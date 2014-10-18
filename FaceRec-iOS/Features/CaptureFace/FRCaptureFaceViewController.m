//
//  FRCaptureFaceViewController.m
//  FaceRec-iOS
//
//  Created by Charles Wang on 1/29/14.
//  Copyright (c) 2014 Charles Wang. All rights reserved.
//

#import "FRCaptureFaceViewController.h"

#import <AVFoundation/AVFoundation.h>

#import "FRPerson.h"
#import "FRUser.h"

#import "FRCaptureFaceUtilities.h"
#import "FRFaceUtilities.h"

#import "UIImage+RotationMethods.h"
#import "UIImage+ConversionHelper.h"

static NSString *const kFRCaptureFaceViewControllerIdentifer = @"FRCaptureFaceViewController";

static NSString *const kFRCaptured = @"Captured";

@interface FRCaptureFaceViewController () <AVCaptureVideoDataOutputSampleBufferDelegate>

@property (weak, nonatomic) IBOutlet UIView *preview;

@property (nonatomic, strong) FRPerson* person;
@property (weak, atomic) IBOutlet UILabel *countDownLabel;
@property (weak, atomic) IBOutlet UILabel *photoTakenCountLabel;

@property (assign, nonatomic) NSUInteger fcounter;
@property (assign, nonatomic) NSUInteger picTaken;

@end

@implementation FRCaptureFaceViewController

#pragma mark - View Controller Instatiator

+ (instancetype)viewControllerWithPerson:(FRPerson *)person
{
    UIStoryboard *sb = [UIStoryboard storyboardWithName:kFRCaptureFaceStoryboardID bundle:[NSBundle mainBundle]];
    FRCaptureFaceViewController *vc = [sb instantiateViewControllerWithIdentifier:kFRCaptureFaceViewControllerIdentifer];
    vc.person = person;
    return vc;
}

#pragma mark - View Controller Event Methods


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self setupPreview:self.preview];
    [self.session startRunning];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate Delegate Method

- (void) captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{

    NSArray *features = [self extractFaceFeaturesFromImageBuffer:sampleBuffer];
    
    for (CIFaceFeature *f in features)
    {
        //UIImage *image = [UIImage createUIImageFromCIImage:ciImage];
        //CGRect modifiedFaceBounds = [self faceBoundFromFaceFeatureBounds:f.bounds faceImageSize:image.size];

        //CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], modifiedFaceBounds);
        //UIImage *img = [UIImage imageWithCGImage:imageRef];
        //CGImageRelease(imageRef);
        
        self.fcounter++;
        
        if(self.fcounter % 15 == 0)
        {
            //[self sendFaceImage:[img imageRotatedByDegrees:90]];
            self.picTaken++;
            dispatch_async(dispatch_get_main_queue(), ^void{
                [self changeCountDownLabelTextWithCount:0];
                [self changePhotoTakenCountLabelTextWithCount:self.picTaken];
            });
            self.fcounter = 0;
        }
        else if(self.fcounter % 12 == 0)
        {
            dispatch_async(dispatch_get_main_queue(), ^void{
                [self changeCountDownLabelTextWithCount:1];
            });
        }
        else if(self.fcounter % 9 == 0)
        {
            dispatch_async(dispatch_get_main_queue(), ^void{
                [self changeCountDownLabelTextWithCount:2];
            });
        }
        else if(self.fcounter % 6 == 0)
        {
            dispatch_async(dispatch_get_main_queue(), ^void{
                [self changeCountDownLabelTextWithCount:3];
            });
        }
        else if(self.fcounter % 3 == 0)
        {
            dispatch_async(dispatch_get_main_queue(), ^void{
                [self changeCountDownLabelTextWithCount:4];
            });
        }
        
    }
    
    //Cleanup
    sampleBuffer = NULL;
}

#pragma mark - Network Call Helper

- (void)sendFaceImage:(UIImage *)image
{
    
}

#pragma mark - IBAction

- (IBAction)toggleCamera:(id)sender
{
    [self switchCamera];
}

- (IBAction)returnToPreviousVC:(id)sender
{
    __weak FRCaptureFaceViewController *weakSelf = self;
    [self dismissViewControllerAnimated:YES completion:^{
        if(weakSelf && weakSelf.session)
        {
            [weakSelf.session stopRunning];
        }
    }];
}

#pragma mark - Notifications
- (void)didRotateCamera:(NSNotification *)notification
{
    [self adjustPreviewLayerFrameForView:self.preview];
}


- (void)changeCountDownLabelTextWithCount:(NSUInteger)count
{
    @synchronized(self.countDownLabel)
    {
        if (count == 0)
        {
            self.countDownLabel.text = kFRCaptured;
        }
        else
        {
            self.countDownLabel.text = [NSString stringWithFormat:@"%zd",count];
        }
    }
}

- (void)changePhotoTakenCountLabelTextWithCount:(NSUInteger)count
{
    @synchronized(self.photoTakenCountLabel)
    {
        self.photoTakenCountLabel.text = [NSString stringWithFormat:@"%zd",count];
    }
}


@end
