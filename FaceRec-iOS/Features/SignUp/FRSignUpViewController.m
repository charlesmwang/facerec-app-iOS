//
//  SignUpViewController.m
//  FaceRec-iOS
//
//  Created by Charles Wang on 2/25/14.
//  Copyright (c) 2014 Charles Wang. All rights reserved.
//

#import "FRSignUpViewController.h"
#import "FRSignUpNetworkOperation.h"
#import "FRActivityLoaderView.h"

static NSString * const kFRSignUpStoryboardID = @"FRSignUp";
static NSString * const kFRSignUpViewControllerIdentifier = @"FRSignUpViewController";

@interface FRSignUpViewController () <NSURLConnectionDelegate, UIAlertViewDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *firstNameField;
@property (weak, nonatomic) IBOutlet UITextField *lastNameField;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UITextField *confirmPasswordField;
@property (weak, nonatomic) IBOutlet UIButton *signUpButton;

@property (weak, nonatomic) IBOutlet UIView *contentView;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (strong, nonatomic) UIAlertView *alertView;

@end

@implementation FRSignUpViewController

+ (instancetype)viewController
{
    UIStoryboard *sb = [UIStoryboard storyboardWithName:kFRSignUpStoryboardID bundle:[NSBundle mainBundle]];
    return [sb instantiateViewControllerWithIdentifier:kFRSignUpViewControllerIdentifier];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    [self.contentView addGestureRecognizer:tap];
    [self.scrollView addGestureRecognizer:tap];
}

- (void)viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidRotate:)
                                                 name:UIKeyboardDidChangeFrameNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidHide:)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void) dismissKeyboard
{
    [self.usernameField resignFirstResponder];
    [self.emailField resignFirstResponder];
    [self.passwordField resignFirstResponder];
    [self.confirmPasswordField resignFirstResponder];
    [self.firstNameField resignFirstResponder];
    [self.lastNameField resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if(self.firstNameField == textField)
    {
        [self.lastNameField becomeFirstResponder];
    }
    else if(self.lastNameField == textField)
    {
        [self.emailField becomeFirstResponder];
    }
    else if(self.emailField == textField)
    {
        [self.usernameField becomeFirstResponder];
    }
    else if(self.usernameField == textField)
    {
        [self.passwordField becomeFirstResponder];
    }
    else if(self.passwordField == textField)
    {
        [self.confirmPasswordField becomeFirstResponder];
    }
    else if(self.confirmPasswordField == textField)
    {
        [self.confirmPasswordField resignFirstResponder];
        [self signUp:nil];
    }
    return YES;
}

- (IBAction)signUp:(id) sender
{
    [self createUser];
}

- (void)createUser
{
    NSError *validationError = [self performValidation];
    
    if(validationError)
    {
        
        return;
    }
    [FRActivityLoaderView presentInView:self.navigationController.view];
    __weak FRSignUpViewController *weakSelf = self;
    [FRSignUpNetworkOperation performSignUpWithFirstName:self.firstNameField.text
                                                lastName:self.lastNameField.text
                                                   email:self.emailField.text
                                                username:self.usernameField.text
                                                password:self.passwordField.text
                                                 success:^
    {
        NSLog(@"Account has been created!");
        [FRActivityLoaderView dismiss];
        [weakSelf dismissViewControllerAnimated:YES completion:NULL];
    }
                                                 failure:^(NSError *error)
    {
        [FRActivityLoaderView dismiss];
    }];
}

- (NSError *)performValidation
{
    return nil;
}

#pragma mark - Keyboard Events

- (void)keyboardDidRotate:(NSNotification *)notification
{
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    CGSize contentSize = self.scrollView.contentSize;
    
    contentSize.height = CGRectGetHeight(self.contentView.frame) + keyboardSize.height + 30;
    
    self.scrollView.contentSize = contentSize;
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    [self.scrollView setContentOffset:CGPointMake(0, -self.scrollView.contentInset.top) animated:YES];
}

- (void)keyboardDidHide:(NSNotification *)notification
{
    self.scrollView.contentSize = self.contentView.frame.size;
}
- (IBAction)dismissSignUp:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end
