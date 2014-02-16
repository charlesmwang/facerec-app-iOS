//
//  RecognitionViewController.m
//  FaceRec-iOS
//
//  Created by Charles Wang on 1/29/14.
//  Copyright (c) 2014 Charles Wang. All rights reserved.
//

#import "RecognitionViewController.h"

static CGFloat DegreesToRadians(CGFloat degrees) {return degrees * M_PI / 180;};

@implementation UIImage (RotationMethods)

- (UIImage *)imageRotatedByDegrees:(CGFloat)degrees
{
    // calculate the size of the rotated view's containing box for our drawing space
    UIView *rotatedViewBox = [[UIView alloc] initWithFrame:CGRectMake(0,0,self.size.width, self.size.height)];
    CGAffineTransform t = CGAffineTransformMakeRotation(DegreesToRadians(degrees));
    rotatedViewBox.transform = t;
    CGSize rotatedSize = rotatedViewBox.frame.size;
    
    // Create the bitmap context
    UIGraphicsBeginImageContext(rotatedSize);
    CGContextRef bitmap = UIGraphicsGetCurrentContext();
    
    // Move the origin to the middle of the image so we will rotate and scale around the center.
    CGContextTranslateCTM(bitmap, rotatedSize.width/2, rotatedSize.height/2);
    
    //   // Rotate the image context
    CGContextRotateCTM(bitmap, DegreesToRadians(degrees));
    
    // Now, draw the rotated/scaled image into the context
    CGContextScaleCTM(bitmap, 1.0, -1.0);
    CGContextDrawImage(bitmap, CGRectMake(-self.size.width / 2, -self.size.height / 2, self.size.width, self.size.height), [self CGImage]);
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
    
}

@end

@interface RecognitionViewController ()

@end

@implementation RecognitionViewController

@synthesize isUsingFrontFacingCamera, features;

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
    //handshake
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://localhost:1337/"] cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:10];
    
    [request setHTTPMethod: @"GET"];
    
    NSError *requestError;
    NSURLResponse *urlResponse = nil;
    [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&requestError];
    
	// Do any additional setup after loading the view.
    _socket = [[SocketIO alloc] initWithDelegate:self];
    [_socket connectToHost:@"192.168.1.125" onPort:1337];
    //[socket sendMessage:@"hello world"];
    
    
	// Do any additional setup after loading the view.
    AVCaptureSession *session = [[AVCaptureSession alloc]init];
    [session setSessionPreset:AVCaptureSessionPreset640x480];
    //AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDevice *device = [self frontCamera];
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
    
    isUsingFrontFacingCamera = YES;
    
    [session startRunning];
}

- (AVCaptureDevice *)frontCamera {
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if ([device position] == AVCaptureDevicePositionFront) {
            return device;
        }
    }
    return nil;
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
    
    NSDictionary *imageOptions = nil;
    UIDeviceOrientation curDeviceOrientation = [[UIDevice currentDevice] orientation];
    int exifOrientation;
    
    enum {
        PHOTOS_EXIF_0ROW_TOP_0COL_LEFT          = 1, //   1  =  0th row is at the top, and 0th column is on the left (THE DEFAULT).
        PHOTOS_EXIF_0ROW_TOP_0COL_RIGHT         = 2, //   2  =  0th row is at the top, and 0th column is on the right.
        PHOTOS_EXIF_0ROW_BOTTOM_0COL_RIGHT      = 3, //   3  =  0th row is at the bottom, and 0th column is on the right.
        PHOTOS_EXIF_0ROW_BOTTOM_0COL_LEFT       = 4, //   4  =  0th row is at the bottom, and 0th column is on the left.
        PHOTOS_EXIF_0ROW_LEFT_0COL_TOP          = 5, //   5  =  0th row is on the left, and 0th column is the top.
        PHOTOS_EXIF_0ROW_RIGHT_0COL_TOP         = 6, //   6  =  0th row is on the right, and 0th column is the top.
        PHOTOS_EXIF_0ROW_RIGHT_0COL_BOTTOM      = 7, //   7  =  0th row is on the right, and 0th column is the bottom.
        PHOTOS_EXIF_0ROW_LEFT_0COL_BOTTOM       = 8  //   8  =  0th row is on the left, and 0th column is the bottom.
    };
    
    switch (curDeviceOrientation) {
        case UIDeviceOrientationPortraitUpsideDown:  // Device oriented vertically, home button on the top
            exifOrientation = PHOTOS_EXIF_0ROW_LEFT_0COL_BOTTOM;
            break;
        case UIDeviceOrientationLandscapeLeft:       // Device oriented horizontally, home button on the right
            if (isUsingFrontFacingCamera)
                exifOrientation = PHOTOS_EXIF_0ROW_BOTTOM_0COL_RIGHT;
            else
                exifOrientation = PHOTOS_EXIF_0ROW_TOP_0COL_LEFT;
            break;
        case UIDeviceOrientationLandscapeRight:      // Device oriented horizontally, home button on the left
            if (isUsingFrontFacingCamera)
                exifOrientation = PHOTOS_EXIF_0ROW_TOP_0COL_LEFT;
            else
                exifOrientation = PHOTOS_EXIF_0ROW_BOTTOM_0COL_RIGHT;
            break;
        case UIDeviceOrientationPortrait:            // Device oriented vertically, home button on the bottom
        default:
            exifOrientation = PHOTOS_EXIF_0ROW_RIGHT_0COL_TOP;
            break;
    }
    
imageOptions = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:exifOrientation] forKey:CIDetectorImageOrientation];
    UIImage *image= [self makeUIImageFromCIImage:ciImage];
    features = [_faceDetector featuresInImage:ciImage options:imageOptions];
    if([features count] > 0)
    {
        _faceFeature = [features objectAtIndex:0];

        CGRect modifiedFaceBounds = _faceFeature.bounds;
        modifiedFaceBounds.origin.y = image.size.height-_faceFeature.bounds.size.height-_faceFeature.bounds.origin.y;
        
        
        //NSLog(@"%f %f %f %f",faceRect.size.width,faceRect.size.height,faceRect.origin.x,faceRect.origin.y);
        //         CGRect modifiedFaceBounds = faceFeature.bounds;
        
        float xscale = 0.75;
        float xshift = (xscale - 1)/2 * modifiedFaceBounds.size.width;
        modifiedFaceBounds.size.width *= xscale;
        modifiedFaceBounds.origin.x -= xshift;
        
        float yscale = 0.62;
        float yshift = (yscale - 1)/2 * modifiedFaceBounds .size.height;
        modifiedFaceBounds.size.height *= yscale;
        modifiedFaceBounds.origin.y -= yshift;
        
        
        CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], modifiedFaceBounds);
        UIImage *img = [UIImage imageWithCGImage:imageRef];
        CGImageRelease(imageRef);
        
        if([_faceFeature trackingFrameCount] == 10)
        {
            //Person *person = [[Person alloc]initWithFirstName:@"Charles" LastName:@"Wang" Email:@"charles@cornell.edu"];
            NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                                  [FaceRecAPI imageToBase64:[img imageRotatedByDegrees:90]], @"image",
                                  @".jpg", @"imageformat",
                                  [[User CurrentUser] username], @"username",
                                  [NSString stringWithFormat:@"%d",[_faceFeature trackingID]],@"trackingID",
                                  nil];
            [_socket sendEvent:@"recognize" withData:dict];
            //NSDictionary *response;
            //NSError *error;
            
            //[FaceRecAPI addFace:dict response:&response error:&error];
        }
        
    }
    
}

- (void) socketIODidConnect:(SocketIO *)socket
{
    NSLog(@"YES!");
}

-(void) socketIO:(SocketIO *)socket didReceiveEvent:(SocketIOPacket *)packet
{
    if([packet.name isEqualToString:@"world"])
    {
        NSArray *data = [[packet dataAsJSON] objectForKey:@"args"];
        NSLog(@"%@",[data objectAtIndex:0]);
        NSDictionary *json = [data objectAtIndex:0];
        
        NSLog(@"Name: %@, Message %@",[json objectForKey:@"name"], [json objectForKey:@"message"]);
    }
    else if([packet.name isEqualToString:@"error"])
    {
        NSArray *data = [[packet dataAsJSON] objectForKey:@"args"];
        NSLog(@"%@",[data objectAtIndex:0]);
        NSDictionary *json = [data objectAtIndex:0];
        
        NSLog(@"Message %@",[json objectForKey:@"message"]);
    }
    else if([packet.name isEqualToString:@"identified"])
    {
        NSLog(@"HERE");
        NSArray *data = [[packet dataAsJSON] objectForKey:@"args"];
        NSLog(@"%@",[data objectAtIndex:0]);
        NSDictionary *json = [data objectAtIndex:0];
        
        NSLog(@"Name %@",[json objectForKey:@"name"]);
        self.title = [json objectForKey:@"name"];
    }
}

- (void) socketIO:(SocketIO *)socket didReceiveJSON:(SocketIOPacket *)packet
{
    NSLog(@"Here as well!");
}

- (IBAction)greeting:(id)sender {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:@"Charles" forKey:@"username"];
    [dict setObject:@"From iOS App" forKey:@"image"];
    [dict setObject:@".jpg" forKey:@"imageformat"];
    
    [_socket sendEvent:@"recognize" withData:dict];
}

-(UIImage*)makeUIImageFromCIImage:(CIImage*)ciImage
{

    // finally!
    UIImage * returnImage;
    
    CGImageRef processedCGImage = [[CIContext contextWithOptions:nil] createCGImage:ciImage fromRect:[ciImage extent]];
    
    returnImage = [UIImage imageWithCGImage:processedCGImage];
    CGImageRelease(processedCGImage);
    
    return returnImage;
}


@end
