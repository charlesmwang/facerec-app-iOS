//
//  FRLoginViewController.m
//  FaceRec-iOS
//
//  Created by Charles Wang on 2/15/14.
//  Copyright (c) 2014 Charles Wang. All rights reserved.
//

#import "FRLoginViewController.h"

#import "FRUser.h"

#import "Server.h"
#import "FaceRecServer.h"

#import "FRLoginNetworkOperation.h"
#import "FRLoginUtilities.h"

#import "FRMainMenuViewController.h"
#import "FRServerListViewController.h"
#import "FRSignUpViewController.h"

#import "FRActivityLoaderView.h"

static NSString * const kFRLoginViewControllerIdentifier = @"FRLoginViewController";

@interface FRLoginViewController ()<UITextFieldDelegate, FRServerListViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UILabel *serverAddressLabel;
@property (weak, nonatomic) IBOutlet UILabel *serverNameLabel;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (strong, nonatomic) UIAlertView* alertView;
@property (strong, nonatomic) Server *selectedServer;

@end

@implementation FRLoginViewController

#pragma mark - ViewController Instantiator

+ (instancetype)viewController
{
    UIStoryboard *sb = [UIStoryboard storyboardWithName:kFRLoginStoryboardID bundle:nil];
    return [sb instantiateViewControllerWithIdentifier:kFRLoginViewControllerIdentifier];
}

#pragma mark - UIViewController Events

- (void)viewDidLoad
{
    [super viewDidLoad];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard:)];
    [self.contentView addGestureRecognizer:tapGesture];
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

#pragma mark - UIAlertView Lazy Instantiation

- (UIAlertView *)alertView
{
    if(!_alertView)
    {
        _alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Error" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    }
    return _alertView;
}

#pragma mark - IBAction

- (IBAction)login:(id)sender
{
    [self proceedLoginProcessWithUsername:self.usernameField.text password:self.passwordField.text];
}

- (IBAction)showServers:(id)sender
{
    FRServerListViewController *serverListVC = [FRServerListViewController viewController];
    serverListVC.delegate = self;
    [self.navigationController pushViewController:serverListVC animated:YES];
}

- (IBAction)showSignUp:(id)sender
{
    [self.navigationController presentViewController:[FRSignUpViewController viewController] animated:YES completion:NULL];
}

#pragma mark - UITextField Delegate

-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
    if(textField == self.usernameField)
    {
        [self.passwordField becomeFirstResponder];
    }
    else if(textField == self.passwordField)
    {
        [textField resignFirstResponder];
        [self login:nil];
    }
    return YES;
}

#pragma mark - FRServerListViewController Delegate

- (void)serverList:(FRServerListViewController *)viewController selectedServer:(Server *)server
{
    self.selectedServer = server;
}

#pragma mark - Setters

- (void)setSelectedServer:(Server *)selectedServer
{
    _selectedServer = selectedServer;
    self.serverNameLabel.text = _selectedServer.name;
    self.serverAddressLabel.text = _selectedServer.ip_address;
}

#pragma mark - Login Operations

- (void)proceedLoginProcessWithUsername:(NSString*) username password:(NSString*) password{
    
    [FRActivityLoaderView presentInView:self.navigationController.view];
    
    __weak FRLoginViewController *weakSelf = self;
    [FRLoginNetworkOperation performLoginWithUsername:username
                                             password:password
                                              success:^(FRAccessToken *accessToken)
     {
         [FRActivityLoaderView dismiss];
         [[FRUser sharedInstance] loggedInWithUsername:username accessToken:accessToken];
         UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:[FRMainMenuViewController viewController]];
         [weakSelf presentViewController:navController animated:YES completion:NULL];
         
     }
                                              failure:^(NSError *error)
     {
         dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
             [FRActivityLoaderView dismiss];
//             UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:[FRMainMenuViewController viewController]];
//             [weakSelf presentViewController:navController animated:YES completion:NULL];
             NSLog(@"Failed");
         });
     }];
    
}

#pragma mark - Tap Gesture Events

- (void)dismissKeyboard:(id)sender
{
    [self.usernameField resignFirstResponder];
    [self.passwordField resignFirstResponder];
}

#pragma mark - Keyboard Events

- (void)keyboardDidRotate:(NSNotification *)notification
{
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    CGSize contentSize = self.scrollView.contentSize;
    
    contentSize.height = CGRectGetHeight(self.contentView.frame) + keyboardSize.height;
    
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

@end
