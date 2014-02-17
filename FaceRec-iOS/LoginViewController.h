//
//  LoginViewController.h
//  FaceRec-iOS
//
//  Created by Charles Wang on 2/15/14.
//  Copyright (c) 2014 Charles Wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FaceRecAPI.h"
#import "Person.h"
#import "KeychainItemWrapper.h"
#import "User.h"
#import "AppDelegate.h"
#import "Server.h"
#import "FaceRecServer.h"

@interface LoginViewController : UIViewController <UITextFieldDelegate, NSURLConnectionDelegate>
@property (strong, nonatomic) IBOutlet UITextField *username_field;
@property (strong, nonatomic) IBOutlet UITextField *password_field;
@property (strong, nonatomic) UIAlertView* alertView;
@property (strong, nonatomic) NSMutableData *responseData;
@property (strong, nonatomic) NSHTTPURLResponse *headerResponse;
@property (strong, nonatomic) NSDictionary *jsonResponse;
@property (strong, nonatomic) AppDelegate* appDelegate;
@property (nonatomic) BOOL autologin;
@end
