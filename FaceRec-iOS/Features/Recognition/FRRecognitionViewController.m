//
//  FRRecognitionViewController.m
//  FaceRec-iOS
//
//  Created by Charles Wang on 1/29/14.
//  Copyright (c) 2014 Charles Wang. All rights reserved.
//

#import "FRRecognitionViewController.h"
#import "FRRecognizedPersonViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "SocketIOPacket.h"
#import "SocketIO.h"
#import "FRPerson.h"
#import "FRUser.h"
#import "FaceRecServer.h"
#import "FRPersonLabel.h"
#import "UIImage+RotationMethods.h"

@interface FRRecognitionViewController () <AVCaptureVideoDataOutputSampleBufferDelegate, SocketIODelegate, NSURLConnectionDelegate>

@property CVPixelBufferRef pixelBuffer;
@property CFDictionaryRef attachments;
@property CIImage *ciImage;
@property NSDictionary *imageOptions;


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
@property (assign, nonatomic) NSUInteger faceCounter;

@end

@implementation FRRecognitionViewController

@synthesize isUsingFrontFacingCamera, features, recognized;

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
    //handshake
    /*NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:
                                    [NSURL URLWithString:[[FaceRecServer Server] url]]];
    request.timeoutInterval = 20.0;
    request.HTTPMethod = @"GET";
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [[[NSURLConnection alloc] initWithRequest:request delegate:self] start];*/
    
    
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
    
    recognized = [[NSMutableDictionary alloc] init];
    _faceCounter = 0;
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
    if([features count] != _faceCounter)
    {
        dispatch_sync(dispatch_get_main_queue(), ^void{
        for(NSString* trackid in recognized)
        {
            FRPersonLabel *label = [recognized objectForKey:trackid];
            if(label)
            {
                [label removeFromSuperview];
            }
        }});
        [recognized removeAllObjects];
    }
    CMFormatDescriptionRef fdesc = CMSampleBufferGetFormatDescription(sampleBuffer);
    CGRect clap = CMVideoFormatDescriptionGetCleanAperture(fdesc, false /*originIsTopLeft == false*/);
    CGSize parentFrameSize = [_preview frame].size;
    NSString *gravity = [_previewLayer videoGravity];
    CGRect previewBox = [FRRecognitionViewController videoPreviewBoxForGravity:gravity
                                                                 frameSize:parentFrameSize
                                                              apertureSize:clap.size];
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
        
        if([features count] != _faceCounter || f.trackingFrameCount % 30 == 0)
        {
            CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], modifiedFaceBounds);
            UIImage *img = [UIImage imageWithCGImage:imageRef];
            CGImageRelease(imageRef);
            
            
            NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                                  [self imageToBase64:[img imageRotatedByDegrees:90]], @"image",
                                  @".jpg", @"imageformat",
                                  [[FRUser sharedInstance] username], @"username",
                                  [NSString stringWithFormat:@"%d",[f trackingID]],@"trackingID",
                                  nil];
            [_socket sendEvent:@"recognize" withData:dict];
            dict = nil;
            img = nil;
            imageRef = nil;
        }
        //Need to perform this in the main to update GUI stuff
        dispatch_sync(dispatch_get_main_queue(), ^void{
            FRPersonLabel *label = [recognized objectForKey:[NSString stringWithFormat:@"%d",[f trackingID]]];
            if(label)
            {
                CGRect faceRect = [f bounds];
                
                // flip preview width and height
                CGFloat temp = faceRect.size.width;
                faceRect.size.width = faceRect.size.height;
                faceRect.size.height = temp;
                temp = faceRect.origin.x;
                faceRect.origin.x = faceRect.origin.y;
                faceRect.origin.y = temp;
                // scale coordinates so they fit in the preview box, which may be scaled
                CGFloat widthScaleBy = previewBox.size.width / clap.size.height;
                CGFloat heightScaleBy = previewBox.size.height / clap.size.width;
                faceRect.size.width *= widthScaleBy;
                faceRect.size.height *= heightScaleBy;
                faceRect.origin.x *= widthScaleBy;
                faceRect.origin.y *= heightScaleBy;
                faceRect = CGRectOffset(faceRect, previewBox.origin.x + previewBox.size.width - faceRect.size.width - (faceRect.origin.x * 2) +100, previewBox.origin.y - 90);
                [label setCenter:CGPointMake(faceRect.origin.x, faceRect.origin.y)];
            }
        });
        image = nil;
    }
    if([features count] != _faceCounter)
    {
        _faceCounter = [features count];
    }
    _ciImage = nil;
    
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
        NSArray *data = [[packet dataAsJSON] objectForKey:@"args"];
        
        if(data && data.count > 0)
        {
            NSDictionary *json = [data objectAtIndex:0];
            
            if(!json)
                return;
            
            if([json objectForKey:@"trackingID"])
            {
                FRPersonLabel *label = [recognized objectForKey:[json objectForKey:@"trackingID"]];
                if(!label)
                {
                    label = [[FRPersonLabel alloc] initWithFrame:CGRectMake(170, 146, 200, 100)];
                }
                //FRPerson *p = [FRPerson new];
                //TODO
                //p.firstName = [json objectForKey:@"firstname"];
                //p.lastName = [json objectForKey:@"lastname"];
                //p.email = [json objectForKey:@"email"];
                if([json objectForKey:@"Facebook"]){
                    //[p.services setObject:[json objectForKey:@"Facebook"] forKey:@"Facebook"];
                }
                //label.person = p;
                label.text = [json objectForKey:@"name"];
                if(![self.preview.subviews containsObject:label])
                {
                    NSLog(@"New Label");
                    [self.preview addSubview:label];
                }
                [recognized setObject:label forKey:[json objectForKey:@"trackingID"]];
                label.userInteractionEnabled = YES;
                UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(labelTapped:)];
                [label addGestureRecognizer:tapGesture];
                
            }
        }
        
        
    }
    else if([packet.name isEqualToString:@"RecError"])
    {
        NSArray *data = [[packet dataAsJSON] objectForKey:@"args"];
        if(data && data.count > 0)
        {
            NSDictionary *json = [data objectAtIndex:0];
            
            if(!json)
                return;
            
            if([json objectForKey:@"trackingID"])
            {
                FRPersonLabel* label = [recognized objectForKey:[json objectForKey:@"trackingID"]];
                if(label)
                {
                    label.text = @"Cannot Find You!";
                    if(![self.preview.subviews containsObject:label])
                    {
                        [self.preview addSubview:label];
                    }
                    [recognized setObject:label forKey:[json objectForKey:@"trackingID"]];
                    label.userInteractionEnabled = NO;
                }
                else
                {
                    label = [[FRPersonLabel alloc] initWithFrame:CGRectMake(170, 146, 200, 100)];
                    label.text = @"Cannot Find You!";
                    [self.preview addSubview:label];
                    [recognized setObject:label forKey:[json objectForKey:@"trackingID"]];
                    label.userInteractionEnabled = NO;
                }
            }
        }
    }
}

- (void) socketIO:(SocketIO *)socket didReceiveJSON:(SocketIOPacket *)packet
{
    NSLog(@"Here as well!");
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

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    _headerResponse = (NSHTTPURLResponse*) response;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {

}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    // Return nil to indicate not necessary to store a cached response for this connection
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {

    if([_headerResponse statusCode])
    {
        _socket = [[SocketIO alloc] initWithDelegate:self];
        _socket.useSecure = [[FaceRecServer Server] isUsingSSL];
        [_socket connectToHost:[[FaceRecServer Server] ip_address] onPort:[[FaceRecServer Server] port]];
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
    [_socket disconnect];
}

- (void)labelTapped:(UIGestureRecognizer*)recognizer
{
    // Only respond if we're in the ended state (similar to touchupinside)
    if( [recognizer state] == UIGestureRecognizerStateEnded )
    {
        // the label that was tapped
        FRPersonLabel* label = (FRPersonLabel*)[recognizer view];
        //NSLog(@"%@",label.person.firstName);
        [self.navigationController pushViewController:[FRRecognizedPersonViewController viewControllerWithPerson:label.person andfaceImage:nil] animated:YES];
    }
}

// find where the video box is positioned within the preview layer based on the video size and gravity
+ (CGRect)videoPreviewBoxForGravity:(NSString *)gravity frameSize:(CGSize)frameSize apertureSize:(CGSize)apertureSize
{
    CGFloat apertureRatio = apertureSize.height / apertureSize.width;
    CGFloat viewRatio = frameSize.width / frameSize.height;
    
    CGSize size = CGSizeZero;
    if ([gravity isEqualToString:AVLayerVideoGravityResizeAspectFill]) {
        if (viewRatio > apertureRatio) {
            size.width = frameSize.width;
            size.height = apertureSize.width * (frameSize.width / apertureSize.height);
        } else {
            size.width = apertureSize.height * (frameSize.height / apertureSize.width);
            size.height = frameSize.height;
        }
    } else if ([gravity isEqualToString:AVLayerVideoGravityResizeAspect]) {
        if (viewRatio > apertureRatio) {
            size.width = apertureSize.height * (frameSize.height / apertureSize.width);
            size.height = frameSize.height;
        } else {
            size.width = frameSize.width;
            size.height = apertureSize.width * (frameSize.width / apertureSize.height);
        }
    } else if ([gravity isEqualToString:AVLayerVideoGravityResize]) {
        size.width = frameSize.width;
        size.height = frameSize.height;
    }
    
    CGRect videoBox;
    videoBox.size = size;
    if (size.width < frameSize.width)
        videoBox.origin.x = (frameSize.width - size.width) / 2;
    else
        videoBox.origin.x = (size.width - frameSize.width) / 2;
    
    if ( size.height < frameSize.height )
        videoBox.origin.y = (frameSize.height - size.height) / 2;
    else
        videoBox.origin.y = (size.height - frameSize.height) / 2;
    
    return videoBox;
}

@end
