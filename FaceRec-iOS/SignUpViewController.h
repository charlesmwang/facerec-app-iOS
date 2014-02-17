//
//  SignUpViewController.h
//  FaceRec-iOS
//
//  Created by Charles Wang on 2/15/14.
//  Copyright (c) 2014 Charles Wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FaceRecServer.h"

@interface SignUpViewController : UIViewController <UITextFieldDelegate, NSURLConnectionDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) IBOutlet UIScrollView *scroller;
@property (strong, nonatomic) IBOutlet UITextField *firstName_field;
@property (strong, nonatomic) IBOutlet UITextField *lastName_field;
@property (strong, nonatomic) IBOutlet UITextField *email_field;
@property (strong, nonatomic) IBOutlet UITextField *username_field;
@property (strong, nonatomic) IBOutlet UITextField *password_field;
@property (strong, nonatomic) IBOutlet UITextField *cornfirmPassword_field;
@property (strong, nonatomic) NSMutableData *responseData;
@property (strong, nonatomic) NSHTTPURLResponse *headerResponse;
@property (strong, nonatomic) NSDictionary *jsonResponse;
@property (strong, nonatomic) UIAlertView *alertView;
@property (assign, nonatomic) BOOL isSuccess;

@end
