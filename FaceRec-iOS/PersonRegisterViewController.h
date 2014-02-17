//
//  PersonRegisterViewController.h
//  FaceRec-iOS
//
//  Created by Charles Wang on 2/15/14.
//  Copyright (c) 2014 Charles Wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CaptureFaceViewController.h"
#import "FaceRecAPI.h"
#import "FaceRecServer.h"
#import "Person.h"

@interface PersonRegisterViewController : UIViewController <UITextFieldDelegate, NSURLConnectionDelegate>
@property (strong, nonatomic) IBOutlet UITextField *firstname_field;
@property (strong, nonatomic) IBOutlet UITextField *lastname_field;
@property (strong, nonatomic) IBOutlet UITextField *email_field;

@property (strong, nonatomic) NSMutableData *responseData;
@property (strong, nonatomic) NSHTTPURLResponse *headerResponse;
@property (strong, nonatomic) NSDictionary *jsonResponse;

@property (strong, nonatomic) Person* person;

@property (strong, nonatomic) CaptureFaceViewController *captureFaceViewController;
@end
