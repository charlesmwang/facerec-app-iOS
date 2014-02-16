//
//  SignUpViewController.h
//  FaceRec-iOS
//
//  Created by Charles Wang on 2/15/14.
//  Copyright (c) 2014 Charles Wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FaceRecAPI.h"

@interface SignUpViewController : UIViewController <UITextFieldDelegate>
{
    IBOutlet UIScrollView *scroller;
    IBOutlet UITextField *firstName_field;
    IBOutlet UITextField *lastName_field;
    IBOutlet UITextField *email_field;
    IBOutlet UITextField *username_field;
    IBOutlet UITextField *password_field;
    IBOutlet UITextField *cornfirmPassword_field;
}
@end
