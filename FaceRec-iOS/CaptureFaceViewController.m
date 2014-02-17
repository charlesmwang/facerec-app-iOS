//
//  CaptureFaceViewController.m
//  FaceRec-iOS
//
//  Created by Charles Wang on 2/15/14.
//  Copyright (c) 2014 Charles Wang. All rights reserved.
//

#import "CaptureFaceViewController.h"

@interface CaptureFaceViewController ()

@property (nonatomic) IBOutlet UIView *cameraView;
@property (nonatomic) UIImagePickerController *imagePickerController;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *returnButton;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *takePictureButton;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) IBOutlet UIScrollView* scrollView;
@property (nonatomic, strong) IBOutlet UIView* cropBox;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *sendButton;

@end

@implementation CaptureFaceViewController

@synthesize person, scrollView, cropBox;

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
    //[self showImagePickerForSourceType:UIImagePickerControllerSourceTypeCamera];
    NSLog(@"%@",[person firstName]);
    _imagePickerController = [[UIImagePickerController alloc] init];
    _imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
    _imagePickerController.delegate = self;
    _alertView = [[UIAlertView alloc] initWithTitle:@"Success" message:@"Image is sent to the server!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [_sendButton setEnabled:NO];
    self.title = [person fullname];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showImagePickerForSourceType:(UIImagePickerControllerSourceType)sourceType
{
    _imagePickerController.sourceType = sourceType;

    
    if (sourceType == UIImagePickerControllerSourceTypeCamera)
    {
        _imagePickerController.showsCameraControls = YES;
    }
    
    [self presentViewController:self.imagePickerController animated:YES completion:nil];
}

- (IBAction)cameraMode:(id)sender {
    [self showImagePickerForSourceType:UIImagePickerControllerSourceTypeCamera];
}

- (IBAction)openPhotoLibrary:(id)sender {
    [self showImagePickerForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}

// This method is called when an image has been chosen from the library or taken from the camera.
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
    self.imageView.image = image;
    [self dismissViewControllerAnimated:YES completion:nil];
    [_sendButton setEnabled:YES];
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

-(UIView *) viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

- (IBAction)sendFaceImage:(id)sender {

    cropBox.alpha = 0;
    UIGraphicsBeginImageContextWithOptions(cropBox.frame.size, NO, 0.0);
    CGContextRef c = UIGraphicsGetCurrentContext();
    CGContextConcatCTM(c, CGAffineTransformMakeTranslation(-cropBox.frame.origin.x, -cropBox.frame.origin.y));
    [self.view.layer renderInContext:c];
    UIImage *screenshot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    cropBox.alpha = 0.2;

    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                          [self imageWithImage:screenshot scaledToSize:CGSizeMake(92, 112)], @"image", @".jpg", @"imageformat", [[User CurrentUser] username], @"username", person, @"person", nil];
    
    NSDictionary *response;
    NSError *error;
    
    [FaceRecAPI addFace:dict response:&response error:&error];
    
    //If Success
    [_alertView show];
    
    _imageView.image = nil;
    [_sendButton setEnabled:NO];
    
}

- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    //UIGraphicsBeginImageContext(newSize);
    // In next line, pass 0.0 to use the current device's pixel scaling factor (and thus account for Retina resolution).
    // Pass 1.0 to force exact pixel size.
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

@end
