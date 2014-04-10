//
//  CaptureFaceViewController.m
//  FaceRec-iOS
//
//  Created by Charles Wang on 1/29/14.
//  Copyright (c) 2014 Charles Wang. All rights reserved.
//

#import "CaptureFaceViewController.h"

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

@interface CaptureFaceViewController ()

@property CVPixelBufferRef pixelBuffer;
@property CFDictionaryRef attachments;
@property CIImage *ciImage;
@property NSDictionary *imageOptions;
@end

@implementation CaptureFaceViewController

@synthesize isUsingFrontFacingCamera, features, headerResponse, responseData, jsonResponse, person, session;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //handshake
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:
                                    [NSURL URLWithString:[[FaceRecServer Server] url]]];
    request.timeoutInterval = 20.0;
    request.HTTPMethod = @"GET";
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [[[NSURLConnection alloc] initWithRequest:request delegate:self] start];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view.
    session = [[AVCaptureSession alloc]init];
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
    
    NSDictionary *detectorOptions = [[NSDictionary alloc] initWithObjectsAndKeys:CIDetectorAccuracyHigh, CIDetectorAccuracy, @YES, CIDetectorTracking, nil];
    _faceDetector = [CIDetector detectorOfType:CIDetectorTypeFace context:nil options:detectorOptions];
    
    isUsingFrontFacingCamera = YES;
    
    [session startRunning];
    

    responseData = [NSMutableData new];
    
    self.fcounter = 0;
    self.picTaken = 0;
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
    _attachments = nil;
    _imageOptions = nil;
    _pixelBuffer = nil;
    NSLog(@"MEMORY LEAKING");
}

- (void) captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    _pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    _attachments = CMCopyDictionaryOfAttachments(kCFAllocatorDefault, sampleBuffer, kCMAttachmentMode_ShouldPropagate);
    _ciImage = [[CIImage alloc] initWithCVPixelBuffer:_pixelBuffer options:(__bridge NSDictionary *)_attachments];
    _attachments = nil;
    _imageOptions = nil;
    _pixelBuffer = nil;
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
    
    _imageOptions = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:exifOrientation] forKey:CIDetectorImageOrientation];
    features = [_faceDetector featuresInImage:_ciImage options:_imageOptions];

    for(CIFaceFeature *f in features)
    {
        UIImage *image= [self makeUIImageFromCIImage:_ciImage];
        
        CGRect modifiedFaceBounds = f.bounds;
        modifiedFaceBounds.origin.y = image.size.height-f.bounds.size.height-f.bounds.origin.y;
        
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
        
        
        self.fcounter++;
        
        if(self.fcounter % 30 == 0)
        {
            [self sendFaceImage:[img imageRotatedByDegrees:90]];
            self.picTaken++;
            dispatch_sync(dispatch_get_main_queue(), ^void{
                self.title = [NSString stringWithFormat:@"Captured! (%d)", self.picTaken];
            });
            self.fcounter = 0;
        }
        else if(self.fcounter % 24 == 0)
        {
            dispatch_sync(dispatch_get_main_queue(), ^void{
                self.title = [NSString stringWithFormat:@"Capturing in 1"];
            });
        }
        else if(self.fcounter % 18 == 0)
        {
            dispatch_sync(dispatch_get_main_queue(), ^void{
                self.title = [NSString stringWithFormat:@"Capturing in 2"];
            });
        }
        else if(self.fcounter % 12 == 0)
        {
            dispatch_sync(dispatch_get_main_queue(), ^void{
                self.title = [NSString stringWithFormat:@"Capturing in 3"];
            });
        }
        else if(self.fcounter % 6 == 0)
        {
            dispatch_sync(dispatch_get_main_queue(), ^void{
                self.title = [NSString stringWithFormat:@"Capturing in 4"];
            });
        }

        imageRef = nil;
    }

    _ciImage = nil;
    
}


-(UIImage*)makeUIImageFromCIImage:(CIImage*)ciImage
{
    
    @autoreleasepool {
        // finally!
        UIImage * returnImage;
        
        CGImageRef processedCGImage = [[CIContext contextWithOptions:nil] createCGImage:ciImage fromRect:[ciImage extent]];
        
        returnImage = [UIImage imageWithCGImage:processedCGImage];
        CGImageRelease(processedCGImage);
        
        processedCGImage = nil;
        
        return returnImage;
    }
}


- (void)sendFaceImage: (UIImage*) img {
    
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                 [self imageToBase64:img], @"image", @".jpg", @"imageformat", [[User CurrentUser] username], @"username", person.email, @"email", nil];
    
    
    NSError* error;
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:
                                    [NSURL URLWithString:[[FaceRecServer Server] goToURL:@"/faces/add"]]];
    request.timeoutInterval = 20.0;
    request.HTTPMethod = @"POST";
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&error];
    request.HTTPBody = jsonData;
    [[[NSURLConnection alloc] initWithRequest:request delegate:self] start];
    
    //Clear Memory
    [dict removeAllObjects];
    dict = nil;
    request = nil;
    jsonData = nil;
    
}



- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    headerResponse = (NSHTTPURLResponse*) response;
    [responseData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [responseData appendData:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    // Return nil to indicate not necessary to store a cached response for this connection
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    if([headerResponse statusCode] == 201)
    {

    }
    else
    {
        NSError *error;
        jsonResponse = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&error];
        if(jsonResponse)
        {
        }
        else
        {
        }
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    
}

- (void) connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    SecTrustRef trust = challenge.protectionSpace.serverTrust;
    NSURLCredential *cred;
    cred = [NSURLCredential credentialForTrust:trust];
    [challenge.sender useCredential:cred forAuthenticationChallenge:challenge];
}

-(NSString*)imageToBase64:(UIImage*) image
{
    return [UIImageJPEGRepresentation(image, 1.0) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [session stopRunning];
}



@end
