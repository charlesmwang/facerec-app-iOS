//
//  RecognitionViewController.m
//  FaceRec-iOS
//
//  Created by ZHAO QIAN on 2/5/14.
//  Copyright (c) 2014 Charles Wang. All rights reserved.
//

#import "RecognitionViewController.h"
#import <CoreImage/CoreImage.h>
#import <ImageIO/ImageIO.h>
//#import <AssertMacros.h>
//#import <AssetsLibrary/AssetsLibrary.h>
//
//static const NSString *AVCaptureStillImageIsCapturingStillImageContext = @"AVCaptureStillImageIsCapturingStillImageContext";
//
//static CGFloat DegreesToRadians(CGFloat degrees) {return degrees * M_PI / 180;};
//
//static void ReleaseCVPixelBuffer(void *pixel, const void *data, size_t size);
//static void ReleaseCVPixelBuffer(void *pixel, const void *data, size_t size)
//{
//	CVPixelBufferRef pixelBuffer = (CVPixelBufferRef)pixel;
//	CVPixelBufferUnlockBaseAddress( pixelBuffer, 0 );
//	CVPixelBufferRelease( pixelBuffer );
//}
//
//// create a CGImage with provided pixel buffer, pixel buffer must be uncompressed kCVPixelFormatType_32ARGB or kCVPixelFormatType_32BGRA
//static OSStatus CreateCGImageFromCVPixelBuffer(CVPixelBufferRef pixelBuffer, CGImageRef *imageOut);
//static OSStatus CreateCGImageFromCVPixelBuffer(CVPixelBufferRef pixelBuffer, CGImageRef *imageOut)
//{
//	OSStatus err = noErr;
//	OSType sourcePixelFormat;
//	size_t width, height, sourceRowBytes;
//	void *sourceBaseAddr = NULL;
//	CGBitmapInfo bitmapInfo;
//	CGColorSpaceRef colorspace = NULL;
//	CGDataProviderRef provider = NULL;
//	CGImageRef image = NULL;
//	
//	sourcePixelFormat = CVPixelBufferGetPixelFormatType( pixelBuffer );
//	if ( kCVPixelFormatType_32ARGB == sourcePixelFormat )
//		bitmapInfo = kCGBitmapByteOrder32Big | kCGImageAlphaNoneSkipFirst;
//	else if ( kCVPixelFormatType_32BGRA == sourcePixelFormat )
//		bitmapInfo = kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipFirst;
//	else
//		return -95014; // only uncompressed pixel formats
//	
//	sourceRowBytes = CVPixelBufferGetBytesPerRow( pixelBuffer );
//	width = CVPixelBufferGetWidth( pixelBuffer );
//	height = CVPixelBufferGetHeight( pixelBuffer );
//	
//	CVPixelBufferLockBaseAddress( pixelBuffer, 0 );
//	sourceBaseAddr = CVPixelBufferGetBaseAddress( pixelBuffer );
//	
//	colorspace = CGColorSpaceCreateDeviceRGB();
//    
//	CVPixelBufferRetain( pixelBuffer );
//	provider = CGDataProviderCreateWithData( (void *)pixelBuffer, sourceBaseAddr, sourceRowBytes * height, ReleaseCVPixelBuffer);
//	image = CGImageCreate(width, height, 8, 32, sourceRowBytes, colorspace, bitmapInfo, provider, NULL, true, kCGRenderingIntentDefault);
//	
//bail:
//	if ( err && image ) {
//		CGImageRelease( image );
//		image = NULL;
//	}
//	if ( provider ) CGDataProviderRelease( provider );
//	if ( colorspace ) CGColorSpaceRelease( colorspace );
//	*imageOut = image;
//	return err;
//}
//
//// utility used by newSquareOverlayedImageForFeatures for
//static CGContextRef CreateCGBitmapContextForSize(CGSize size);
//static CGContextRef CreateCGBitmapContextForSize(CGSize size)
//{
//    CGContextRef    context = NULL;
//    CGColorSpaceRef colorSpace;
//    int             bitmapBytesPerRow;
//	
//    bitmapBytesPerRow = (size.width * 4);
//	
//    colorSpace = CGColorSpaceCreateDeviceRGB();
//    context = CGBitmapContextCreate (NULL,
//									 size.width,
//									 size.height,
//									 8,      // bits per component
//									 bitmapBytesPerRow,
//									 colorSpace,
//									 kCGImageAlphaPremultipliedLast);
//	CGContextSetAllowsAntialiasing(context, NO);
//    CGColorSpaceRelease( colorSpace );
//    return context;
//}
//
//
//
//#pragma mark-
//
//@interface UIImage (RotationMethods)
//- (UIImage *)imageRotatedByDegrees:(CGFloat)degrees;
//@end
//
//@implementation UIImage (RotationMethods)
//
//- (UIImage *)imageRotatedByDegrees:(CGFloat)degrees
//{
//	// calculate the size of the rotated view's containing box for our drawing space
//	UIView *rotatedViewBox = [[UIView alloc] initWithFrame:CGRectMake(0,0,self.size.width, self.size.height)];
//	CGAffineTransform t = CGAffineTransformMakeRotation(DegreesToRadians(degrees));
//	rotatedViewBox.transform = t;
//	CGSize rotatedSize = rotatedViewBox.frame.size;
//	[rotatedViewBox release];
//	
//	// Create the bitmap context
//	UIGraphicsBeginImageContext(rotatedSize);
//	CGContextRef bitmap = UIGraphicsGetCurrentContext();
//	
//	// Move the origin to the middle of the image so we will rotate and scale around the center.
//	CGContextTranslateCTM(bitmap, rotatedSize.width/2, rotatedSize.height/2);
//	
//	//   // Rotate the image context
//	CGContextRotateCTM(bitmap, DegreesToRadians(degrees));
//	
//	// Now, draw the rotated/scaled image into the context
//	CGContextScaleCTM(bitmap, 1.0, -1.0);
//	CGContextDrawImage(bitmap, CGRectMake(-self.size.width / 2, -self.size.height / 2, self.size.width, self.size.height), [self CGImage]);
//	
//	UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
//	UIGraphicsEndImageContext();
//	return newImage;
//	
//}
//
//@end



@interface RecognitionViewController (InternalMethods)
-(void) setupAVCapture;
-(void) teardownAVCapture;

@end

@implementation RecognitionViewController

//- (void)setupAVCapture
//{
//	NSError *error = nil;
//	
//	AVCaptureSession *session = [AVCaptureSession new];
//	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
//	    [session setSessionPreset:AVCaptureSessionPreset640x480];
//	else
//	    [session setSessionPreset:AVCaptureSessionPresetPhoto];
//	
//    // Select a video device, make an input
//	AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
//	AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
//	//require( error == nil, bail );
//	
//    isUsingFrontFacingCamera = NO;
//	if ( [session canAddInput:deviceInput] )
//		[session addInput:deviceInput];
//	
//    // Make a still image output
//	stillImageOutput = [AVCaptureStillImageOutput new];
//	[stillImageOutput addObserver:self forKeyPath:@"capturingStillImage" options:NSKeyValueObservingOptionNew context:AVCaptureStillImageIsCapturingStillImageContext];
//	if ( [session canAddOutput:stillImageOutput] )
//		[session addOutput:stillImageOutput];
//	
//    // Make a video data output
//	_videoDataOutput = [AVCaptureVideoDataOutput new];
//	
//    // we want BGRA, both CoreGraphics and OpenGL work well with 'BGRA'
//	NSDictionary *rgbOutputSettings = [NSDictionary dictionaryWithObject:
//									   [NSNumber numberWithInt:kCMPixelFormat_32BGRA] forKey:(id)kCVPixelBufferPixelFormatTypeKey];
//	[_videoDataOutput setVideoSettings:rgbOutputSettings];
//	[_videoDataOutput setAlwaysDiscardsLateVideoFrames:YES]; // discard if the data output queue is blocked (as we process the still image)
//    
//    // create a serial dispatch queue used for the sample buffer delegate as well as when a still image is captured
//    // a serial dispatch queue must be used to guarantee that video frames will be delivered in order
//    // see the header doc for setSampleBufferDelegate:queue: for more information
//	_videoDataOutputQueue = dispatch_queue_create("VideoDataOutputQueue", DISPATCH_QUEUE_SERIAL);
//	[_videoDataOutput setSampleBufferDelegate:self queue:_videoDataOutputQueue];
//	
//    if ( [session canAddOutput:_videoDataOutput] )
//		[session addOutput:_videoDataOutput];
//	[[_videoDataOutput connectionWithMediaType:AVMediaTypeVideo] setEnabled:NO];
//	
//	effectiveScale = 1.0;
//	_previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];
//	[_previewLayer setBackgroundColor:[[UIColor blackColor] CGColor]];
//	[_previewLayer setVideoGravity:AVLayerVideoGravityResizeAspect];
//	CALayer *rootLayer = [_preview layer];
//	[rootLayer setMasksToBounds:YES];
//	[_previewLayer setFrame:[rootLayer bounds]];
//	[rootLayer addSublayer:_previewLayer];
//	[session startRunning];
//    
//bail:
//	[session release];
//	if (error) {
//		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Failed with error %d", (int)[error code]]
//															message:[error localizedDescription]
//														   delegate:nil
//												  cancelButtonTitle:@"Dismiss"
//												  otherButtonTitles:nil];
//		[alertView show];
//		[alertView release];
//		[self teardownAVCapture];
//	}
//}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


//- (void)teardownAVCapture
//{
//	[_videoDataOutput release];
//	if (_videoDataOutputQueue)
//		dispatch_release(_videoDataOutputQueue);
//	[stillImageOutput removeObserver:self forKeyPath:@"isCapturingStillImage"];
//	[stillImageOutput release];
//	[_previewLayer removeFromSuperlayer];
//	[_previewLayer release];
//}
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

   // [self setupAVCapture];
    
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


- (IBAction)switchCameras:(id)sender {
    
    
    NSLog(@"test");
    AVCaptureDevicePosition desiredPosition;
	if (isUsingFrontFacingCamera)
		desiredPosition = AVCaptureDevicePositionBack;
	else
		desiredPosition = AVCaptureDevicePositionFront;
	
	for (AVCaptureDevice *d in [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo]) {
		if ([d position] == desiredPosition) {
			[[_previewLayer session] beginConfiguration];
			AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:d error:nil];
			for (AVCaptureInput *oldInput in [[_previewLayer session] inputs]) {
				[[_previewLayer session] removeInput:oldInput];
			}
			[[_previewLayer session] addInput:input];
			[[_previewLayer session] commitConfiguration];
			break;
		}
	}
	isUsingFrontFacingCamera = !isUsingFrontFacingCamera;
    
}
@end
