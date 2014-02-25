//
//  SignUpViewController.h
//  FaceRec-iOS
//
//  Created by Charles Wang on 2/25/14.
//  Copyright (c) 2014 Charles Wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FaceRecServer.h"

@interface SignUpViewController : UITableViewController <NSURLConnectionDelegate, UIAlertViewDelegate, UITextFieldDelegate>

@property (strong, nonatomic) UITextField *firstName_field;
@property (strong, nonatomic) UITextField *lastName_field;
@property (strong, nonatomic) UITextField *email_field;
@property (strong, nonatomic) UITextField *username_field;
@property (strong, nonatomic) UITextField *password_field;
@property (strong, nonatomic) UITextField *confirmPassword_field;
@property (strong, nonatomic) UIButton *signupButton;

@property (strong, nonatomic) NSMutableData *responseData;
@property (strong, nonatomic) NSHTTPURLResponse *headerResponse;
@property (strong, nonatomic) NSDictionary *jsonResponse;
@property (strong, nonatomic) UIAlertView *alertView;
@property (assign, nonatomic) BOOL isSuccess;

@end
