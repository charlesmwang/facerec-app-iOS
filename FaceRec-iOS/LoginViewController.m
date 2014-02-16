//
//  LoginViewController.m
//  FaceRec-iOS
//
//  Created by Charles Wang on 2/15/14.
//  Copyright (c) 2014 Charles Wang. All rights reserved.
//

#import "LoginViewController.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

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
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) proceedLoginProcess{
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:_username_field.text, @"username", _password_field.text, @"password", nil];
    NSDictionary* response;
    NSError* error;
    [FaceRecAPI login:dict response:&response error:&error];
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"iPhone_MainStoryboard" bundle:nil];
    UIViewController *viewController = [mainStoryboard instantiateInitialViewController];
    [self presentViewController:viewController animated:YES completion:nil];

}

- (IBAction)login:(id)sender {
    [self proceedLoginProcess];
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

@end
