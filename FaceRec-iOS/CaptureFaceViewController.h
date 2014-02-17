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
#import "FaceRecAPI.h"
#import "User.h"

@interface CaptureFaceViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIScrollViewDelegate, NSURLConnectionDelegate>

@property (nonatomic, strong) Person* person;
@property (nonatomic, strong) UIAlertView* alertView;
@property (strong, nonatomic) NSMutableData *responseData;
@property (strong, nonatomic) NSHTTPURLResponse *headerResponse;
@property (strong, nonatomic) NSDictionary *jsonResponse;

@end
