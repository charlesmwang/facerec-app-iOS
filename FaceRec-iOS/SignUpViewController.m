//
//  SignUpViewController.m
//  FaceRec-iOS
//
//  Created by Charles Wang on 2/15/14.
//  Copyright (c) 2014 Charles Wang. All rights reserved.
//

#import "SignUpViewController.h"

@interface SignUpViewController ()

@end

@implementation SignUpViewController

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
    [scroller setScrollEnabled:YES];
    [scroller setContentSize:CGSizeMake(320, 600)];
    [scroller setContentOffset:CGPointMake(0,50) animated:NO];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    [scroller setContentOffset:CGPointMake(0,0) animated:YES];
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    [scroller setContentOffset:CGPointMake(0,textField.center.y-140) animated:YES];
}
- (IBAction)createAccount:(id)sender {
    NSLog(@"Button Pressed");
    [self processAccountCreationProcess];
}

-(void) processAccountCreationProcess{
    NSError *error;
    if([self validate_username:username_field.text error:&error]
       && [self validate_email:email_field.text error:&error]
        && [self validate_firstname:firstName_field.text error:&error]
         && [self validate_lastname:lastName_field.text error:&error]
          && [self validate_password:password_field.text confirm:cornfirmPassword_field.text error:&error]
       )
    {
        NSDictionary* dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                                        firstName_field.text, @"firstname",
                                        lastName_field.text, @"lastname",
                                        email_field.text, @"email",
                                        username_field.text, @"username",
                                        password_field.text, @"password",
                                        nil];
        NSDictionary *response;
        [FaceRecAPI createAccount:dict response:&response error:&error];
    }
    else
    {
        //Do error Handling
    }
}

//Add Validation
-(BOOL) validate_username:(NSString*) username error:(NSError**)error{
    return YES;
}

-(BOOL) validate_email:(NSString*) email error:(NSError**)error{
    return YES;
}

-(BOOL) validate_firstname:(NSString*) firstname error:(NSError**)error{
    return YES;
}

-(BOOL) validate_lastname:(NSString*) lastname error:(NSError**)error{
    return YES;
}

-(BOOL) validate_password:(NSString*) password confirm:(NSString*) confirm error:(NSError**)error{
    if([password isEqualToString:confirm])
    {
        return YES;
    }
    else
    {
        //Create Reason Here
        return NO;
    }
}

@end
