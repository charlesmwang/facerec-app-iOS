//
//  LoginViewController.m
//  FaceRec-iOS
//
//  Created by Charles Wang on 2/15/14.
//  Copyright (c) 2014 Charles Wang. All rights reserved.
//

#import "LoginViewController.h"

@interface LoginViewController ()

@property KeychainItemWrapper *keychain;

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
    
    //Login Automatically
    _keychain = [[KeychainItemWrapper alloc] initWithIdentifier:@"FaceRecApp" accessGroup:nil];
    //[_keychain resetKeychainItem];
    NSString *username =[_keychain objectForKey:(__bridge id)(kSecAttrAccount)];
    NSString *password =[_keychain objectForKey:(__bridge id)(kSecValueData)];
    
    //If keychain is empty
    if([username isEqualToString:@""] && [password isEqualToString:@""])
    {
        NSLog(@"Cannot Autologin");
        NSLog(@"username: %@", username );
    }
    else
    {
        [self proceedLoginProcessWithUsername:username password:password];
        NSLog(@"username: %@, password: %@", username, password);
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) proceedLoginProcessWithUsername:(NSString*) username password:(NSString*) password{
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:username, @"username", password, @"password", nil];
    NSDictionary* response;
    NSError* error;
    [FaceRecAPI login:dict response:&response error:&error];
    
    //If Succeeded
    //if()
    {
        User *user = [[User alloc] initWithUsername:username token: [response objectForKey:@"access_token"]];
        NSLog(@"Access Token: %@", user.access_token);
        //Store username and password
        if(![_username_field.text isEqualToString:@""] && ![_password_field.text isEqualToString:@""])
        {
            [_keychain resetKeychainItem];
            [_keychain setObject:_username_field.text forKey:(__bridge id)(kSecAttrAccount)];
            [_keychain setObject:_password_field.text forKey:(__bridge id)(kSecValueData)];
        }
    }
    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"iPhone_MainStoryboard" bundle:nil];
    UIViewController *viewController = [mainStoryboard instantiateInitialViewController];
    [self presentViewController:viewController animated:YES completion:nil];

}

- (IBAction)login:(id)sender {
    [self proceedLoginProcessWithUsername:_username_field.text password: _password_field.text];
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

@end
