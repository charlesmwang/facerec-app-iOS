//
//  FRPersonRegistrationViewController.m
//  FaceRec-iOS
//
//  Created by Charles Wang on 2/15/14.
//  Copyright (c) 2014 Charles Wang. All rights reserved.
//

#import "FRPersonRegistrationViewController.h"
#import "FRPersonUtilities.h"

static NSString * const kFRPersonRegistrationViewControllerIdentifier = @"FRPersonRegistrationViewController";

@interface FRPersonRegistrationViewController () <UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UITextField *firstNameField;
@property (strong, nonatomic) IBOutlet UITextField *lastNameField;
@property (strong, nonatomic) IBOutlet UITextField *emailField;

@end

@implementation FRPersonRegistrationViewController

#pragma mark - View Controller Instatiator

+ (instancetype)viewController
{
    UIStoryboard *sb = [UIStoryboard storyboardWithName:kFRPersonStoryboardID bundle:[NSBundle mainBundle]];
    return [sb instantiateViewControllerWithIdentifier:kFRPersonRegistrationViewControllerIdentifier];
}

#pragma mark - UIViewController Event Methods

- (void)viewDidLoad
{
    [super viewDidLoad];
}

#pragma mark - UITextFieldDelegate

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - IBAction

- (IBAction)registerPerson:(id)sender
{

}


@end
